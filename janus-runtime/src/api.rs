//! HTTP/WebSocket API server.

use crate::{executor::PluginExecutor, hardware::HardwareManager, state::StateManager};
use anyhow::Result;
use axum::{
    extract::{Path, State as AxumState},
    http::{HeaderMap, StatusCode},
    response::Json,
    routing::{get, post},
    Router,
};
use janus_core::{AuditEntry, Config, EngagementScope, LicensedFeature, SignedLicense, StateKey};
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

#[derive(Deserialize)]
struct EngagementCreateRequest {
    authorization_reference: String,
    starts_at: chrono::DateTime<chrono::Utc>,
    ends_at: chrono::DateTime<chrono::Utc>,
    approved_assets: Vec<String>,
    #[serde(default)]
    approved_evidence_paths: Vec<String>,
    approved_features: Vec<LicensedFeature>,
    #[serde(default = "default_active")]
    active: bool,
}

#[derive(Serialize)]
struct EngagementResponse {
    engagement_id: String,
    organization_id: String,
    active: bool,
}

fn default_active() -> bool { true }

#[derive(Deserialize)]
struct LicenseImportRequest {
    license: SignedLicense,
}

#[derive(Serialize)]
struct CurrentUserResponse {
    user_id: String,
    organization_id: String,
    email: String,
    role: String,
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
    /// Certified module identifier, normally the plugin ID.
    plugin: String,
    /// Active customer engagement authorizing this execution.
    engagement_id: String,
    /// Exact approved customer asset or evidence location.
    target_asset: String,
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
            .route("/auth/me", get(current_user))
            .route("/auth/logout", post(logout))
            .route("/licenses/import", post(import_license))
            .route("/engagements", post(create_engagement))
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

async fn create_engagement(
    AxumState(state): AxumState<ApiState>,
    headers: HeaderMap,
    Json(request): Json<EngagementCreateRequest>,
) -> (StatusCode, Json<ApiResponse<EngagementResponse>>) {
    let account = match authenticated_account(&state.state_manager, &headers).await {
        Ok(account) => account,
        Err(error) => return unauthorized_response(error),
    };
    let scope = EngagementScope {
        approved_assets: request.approved_assets,
        approved_evidence_paths: request.approved_evidence_paths,
        approved_features: request.approved_features,
    };
    match state.state_manager.create_engagement(
        &account, request.authorization_reference, request.starts_at, request.ends_at, scope, request.active,
    ).await {
        Ok(engagement) => (StatusCode::CREATED, Json(ApiResponse {
            status: "success".into(),
            data: Some(EngagementResponse { engagement_id: engagement.id, organization_id: engagement.organization_id, active: engagement.active }),
            error: None,
        })),
        Err(error) => (StatusCode::BAD_REQUEST, Json(ApiResponse { status: "error".into(), data: None, error: Some(error.to_string()) })),
    }
}

async fn import_license(
    AxumState(state): AxumState<ApiState>,
    headers: HeaderMap,
    Json(request): Json<LicenseImportRequest>,
) -> (StatusCode, Json<ApiResponse<()>>) {
    let account = match authenticated_account(&state.state_manager, &headers).await {
        Ok(account) => account,
        Err(error) => return unauthorized_response(error),
    };
    match state.state_manager.import_license(&account, request.license).await {
        Ok(()) => (StatusCode::CREATED, Json(ApiResponse { status: "success".into(), data: Some(()), error: None })),
        Err(error) => (StatusCode::FORBIDDEN, Json(ApiResponse { status: "error".into(), data: None, error: Some(error.to_string()) })),
    }
}

async fn current_user(
    AxumState(state): AxumState<ApiState>,
    headers: HeaderMap,
) -> (StatusCode, Json<ApiResponse<CurrentUserResponse>>) {
    match authenticated_account(&state.state_manager, &headers).await {
        Ok(account) => (StatusCode::OK, Json(ApiResponse {
            status: "success".into(),
            data: Some(CurrentUserResponse { user_id: account.id, organization_id: account.organization_id, email: account.email, role: account.role.as_str().into() }),
            error: None,
        })),
        Err(error) => unauthorized_response(error),
    }
}

async fn logout(
    AxumState(state): AxumState<ApiState>,
    headers: HeaderMap,
) -> (StatusCode, Json<ApiResponse<()>>) {
    let token = match bearer_token(&headers) {
        Ok(token) => token,
        Err(error) => return unauthorized_response(error),
    };
    match state.state_manager.logout(token).await {
        Ok(()) => (StatusCode::OK, Json(ApiResponse { status: "success".into(), data: Some(()), error: None })),
        Err(error) => unauthorized_response(error),
    }
}

fn bearer_token(headers: &HeaderMap) -> Result<&str, anyhow::Error> {
    let value = headers.get("authorization").and_then(|value| value.to_str().ok())
        .ok_or_else(|| anyhow::anyhow!("missing authorization bearer token"))?;
    value.strip_prefix("Bearer ").ok_or_else(|| anyhow::anyhow!("invalid authorization scheme"))
}

async fn authenticated_account(state_manager: &StateManager, headers: &HeaderMap) -> Result<janus_core::UserAccount> {
    state_manager.authenticate_session(bearer_token(headers)?).await
}

fn unauthorized_response<T>(error: anyhow::Error) -> (StatusCode, Json<ApiResponse<T>>) {
    (StatusCode::UNAUTHORIZED, Json(ApiResponse { status: "error".into(), data: None, error: Some(error.to_string()) }))
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
    headers: HeaderMap,
    Json(req): Json<ExecuteRequest>,
) -> (StatusCode, Json<ApiResponse<serde_json::Value>>) {
    let account = match authenticated_account(&state.state_manager, &headers).await {
        Ok(account) => account,
        Err(error) => return unauthorized_response(error),
    };
    if !account.role.may_request_execution() {
        return (
            StatusCode::FORBIDDEN,
            Json(ApiResponse {
                status: "error".to_string(),
                data: None,
                error: Some("role is not allowed to request execution".to_string()),
            }),
        );
    }
    let module_sha256 = match state.executor.plugin_sha256(&req.plugin) {
        Ok(hash) => hash,
        Err(error) => return (StatusCode::NOT_FOUND, Json(ApiResponse { status: "error".into(), data: None, error: Some(error.to_string()) })),
    };
    if let Err(error) = state.state_manager.authorize_production_execution(
        &account, &req.engagement_id, &req.target_asset, &req.plugin, &module_sha256,
    ).await {
        return (StatusCode::FORBIDDEN, Json(ApiResponse { status: "error".into(), data: None, error: Some(error.to_string()) }));
    }

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
