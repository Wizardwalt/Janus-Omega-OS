//! HTTP/WebSocket API server.

use crate::{executor::PluginExecutor, state::StateManager};
use anyhow::Result;
use axum::{
    extract::State as AxumState,
    http::StatusCode,
    response::Json,
    routing::{get, post},
    Router,
};
use janus_core::Config;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tower_http::cors::CorsLayer;
use tracing::info;

#[derive(Clone)]
pub struct ApiState {
    config: Config,
    state_manager: Arc<StateManager>,
    executor: Arc<PluginExecutor>,
}

#[derive(Serialize, Deserialize)]
struct HealthResponse {
    status: String,
    version: String,
}

#[derive(Serialize, Deserialize)]
struct ExecuteRequest {
    plugin: String,
    args: serde_json::Value,
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
}

impl ApiServer {
    pub fn new(config: Config, state_manager: StateManager, executor: PluginExecutor) -> Self {
        Self {
            config,
            state_manager: Arc::new(state_manager),
            executor: Arc::new(executor),
        }
    }

    pub async fn start(self) -> Result<()> {
        let api_state = ApiState {
            config: self.config.clone(),
            state_manager: self.state_manager,
            executor: self.executor,
        };

        let app = Router::new()
            .route("/health", get(health))
            .route("/execute", post(execute))
            .route("/plugins", get(list_plugins))
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
    })
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
