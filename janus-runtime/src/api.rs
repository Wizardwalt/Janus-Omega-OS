//! HTTP/WebSocket API server.

use crate::{executor::PluginExecutor, hardware::HardwareManager, state::StateManager};
use anyhow::Result;
use axum::{
    extract::{Path, State as AxumState},
    http::StatusCode,
    response::Json,
    routing::{get, post},
    Router,
};
use janus_core::{AuditEntry, Config, StateKey};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tower_http::cors::CorsLayer;
use tracing::info;

#[derive(Clone)]
pub struct ApiState {
    config: Config,
    state_manager: Arc<StateManager>,
    executor: Arc<PluginExecutor>,
    hardware: Arc<HardwareManager>,
}

#[derive(Serialize, Deserialize)]
struct HealthResponse {
    status: String,
    version: String,
    plugins: usize,
}

#[derive(Deserialize)]
struct BootstrapRequest {
    organization_name: String,
    email: String,
    password: String,
}

#[derive(Deserialize)]
struct LoginRequest {
    email: String,
    password: String,
}

#[derive(Serialize)]
struct LoginResponse {
    session_token: String,
    expires_at: String,
    user_id: String,
    organization_id: String,
    role: String,
}

#[derive(Serialize)]
struct BootstrapResponse {
    organization_id: String,
    user_id: String,
    email: String,
    role: String,
}

#[derive(Serialize, Deserialize)]
struct ExecuteRequest {
    plugin: String,
    args: serde_json::Value,
}

#[derive(Serialize, Deserialize)]
struct StateRequest {
    namespace: String,
    key: String,
    value: serde_json::Value,
}

#[derive(Serialize, Deserialize)]
struct ApiResponse<T> {
    status: String,
    data: Option<T>,
    error: Option<String>,
}

pub struct ApiServer {
    config: Config,
    state_manager: Arc<StateManager>,
    executor: Arc<PluginExecutor>,
    hardware: Arc<HardwareManager>,
}

impl ApiServer {
    pub fn new(
        config: Config,
        state_manager: StateManager,
        executor: PluginExecutor,
        hardware: Arc<HardwareManager>,
    ) -> Self {
        Self {
            config,
            state_manager: Arc::new(state_manager),
            executor: Arc::new(executor),
            hardware,
        }
    }

    pub async fn start(self) -> Result<()> {
        let api_state = ApiState {
            config: self.config.clone(),
            state_manager: self.state_manager,
            executor: self.executor,
            hardware: self.hardware,
        };

        let app = Router::new()
            .route("/health", get(health))
            .route("/auth/bootstrap", post(bootstrap))
            .route("/auth/login", post(login))
            .route("/execute", post(execute))
            .route("/plugins", get(list_plugins))
            .route("/state/:namespace/:key", get(get_state).post(set_state))
            .route("/audit/logs", get(get_audit_logs))
            .layer(CorsLayer::permissive())
            .with_state(api_state);

        let bind_addr = format!("{}:{}", self.config.web_bind, self.config.web_port);
        let listener = tokio::net::TcpListener::bind(&bind_addr).await?;
        info!("API server listening on {}", bind_addr);

        axum::serve(listener, app).await?;
        Ok(())
    }
}

async fn health(AxumState(state): AxumState<ApiState>) -> Json<HealthResponse> {
    Json(HealthResponse {
        status: "ok".to_string(),
        version: janus_core::VERSION.to_string(),
        plugins: state.executor.plugin_count(),
    })
}

async fn login(
    AxumState(state): AxumState<ApiState>,
    Json(request): Json<LoginRequest>,
) -> (StatusCode, Json<ApiResponse<LoginResponse>>) {
    match state.state_manager.login(request.email, request.password).await {
        Ok(session) => (
            StatusCode::OK,
            Json(ApiResponse {
                status: "success".to_string(),
                data: Some(LoginResponse {
                    session_token: session.token,
                    expires_at: session.expires_at.to_rfc3339(),
                    user_id: session.account.id,
                    organization_id: session.account.organization_id,
                    role: session.account.role.as_str().to_string(),
                }),
                error: None,
            }),
        ),
        Err(error) => (
            StatusCode::UNAUTHORIZED,
            Json(ApiResponse {
                status: "error".to_string(),
                data: None,
                error: Some(error.to_string()),
            }),
        ),
    }
}

async fn bootstrap(
    AxumState(state): AxumState<ApiState>,
    Json(request): Json<BootstrapRequest>,
) -> (StatusCode, Json<ApiResponse<BootstrapResponse>>) {
    match state
        .state_manager
        .bootstrap_first_admin(request.organization_name, request.email, request.password)
        .await
    {
        Ok((organization, account)) => (
            StatusCode::CREATED,
            Json(ApiResponse {
                status: "success".to_string(),
                data: Some(BootstrapResponse {
                    organization_id: organization.id,
                    user_id: account.id,
                    email: account.email,
                    role: account.role.as_str().to_string(),
                }),
                error: None,
            }),
        ),
        Err(error) => (
            StatusCode::BAD_REQUEST,
            Json(ApiResponse {
                status: "error".to_string(),
                data: None,
                error: Some(error.to_string()),
            }),
        ),
    }
}

async fn execute(
    AxumState(state): AxumState<ApiState>,
    Json(req): Json<ExecuteRequest>,
) -> (StatusCode, Json<ApiResponse<serde_json::Value>>) {
    match state.executor.execute(&req.plugin, req.args).await {
        Ok(data) => (
            StatusCode::OK,
            Json(ApiResponse {
                status: "success".to_string(),
                data: Some(data),
                error: None,
            }),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse {
                status: "error".to_string(),
                data: None,
                error: Some(e.to_string()),
            }),
        ),
    }
}

async fn list_plugins(
    AxumState(state): AxumState<ApiState>,
) -> (StatusCode, Json<ApiResponse<Vec<String>>>) {
    match state.executor.list_plugins().await {
        Ok(plugins) => (
            StatusCode::OK,
            Json(ApiResponse {
                status: "success".to_string(),
                data: Some(plugins),
                error: None,
            }),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse {
                status: "error".to_string(),
                data: None,
                error: Some(e.to_string()),
            }),
        ),
    }
}

async fn get_state(
    AxumState(state): AxumState<ApiState>,
    Path((namespace, key)): Path<(String, String)>,
) -> (StatusCode, Json<ApiResponse<serde_json::Value>>) {
    let state_key = StateKey::new(namespace, key);
    match state.state_manager.get(&state_key).await {
        Ok(Some(value)) => (
            StatusCode::OK,
            Json(ApiResponse {
                status: "success".to_string(),
                data: Some(value),
                error: None,
            }),
        ),
        Ok(None) => (
            StatusCode::NOT_FOUND,
            Json(ApiResponse {
                status: "not_found".to_string(),
                data: None,
                error: None,
            }),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse {
                status: "error".to_string(),
                data: None,
                error: Some(e.to_string()),
            }),
        ),
    }
}

async fn set_state(
    AxumState(state): AxumState<ApiState>,
    Path((namespace, key)): Path<(String, String)>,
    Json(req): Json<serde_json::Value>,
) -> (StatusCode, Json<ApiResponse<()>>) {
    let state_key = StateKey::new(namespace, key);
    match state.state_manager.update_state(&state_key, req).await {
        Ok(_) => (
            StatusCode::OK,
            Json(ApiResponse {
                status: "success".to_string(),
                data: Some(()),
                error: None,
            }),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse {
                status: "error".to_string(),
                data: None,
                error: Some(e.to_string()),
            }),
        ),
    }
}

async fn get_audit_logs(
    AxumState(_state): AxumState<ApiState>,
) -> (StatusCode, Json<ApiResponse<Vec<String>>>) {
    (
        StatusCode::OK,
        Json(ApiResponse {
            status: "success".to_string(),
            data: Some(vec![]),
            error: None,
        }),
    )
}
