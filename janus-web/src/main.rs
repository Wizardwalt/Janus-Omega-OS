//! # Janus Web
//!
//! Web dashboard and API frontend for Janus ecosystem.
//! Provides browser-based control panel and monitoring interface.

use anyhow::Result;
use axum::{
    extract::State as AxumState,
    http::StatusCode,
    response::Html,
    routing::get,
    Router,
};
use clap::Parser;
use janus_core::Config;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use tower_http::cors::CorsLayer;
use tracing::info;

mod dashboard;

#[derive(Parser, Debug)]
#[command(name = "janus-web")]
#[command(about = "Janus web dashboard", long_about = None)]
struct Args {
    /// Web server bind address
    #[arg(short, long, default_value = "127.0.0.1")]
    bind: String,

    /// Web server port
    #[arg(short, long, default_value = "3000")]
    port: u16,

    /// Runtime API address
    #[arg(short = 'r', long, default_value = "http://127.0.0.1:8080")]
    runtime_api: String,

    /// Log level
    #[arg(long, value_name = "LEVEL", default_value = "info")]
    log_level: String,
}

#[derive(Clone)]
struct AppState {
    runtime_api: String,
}

#[derive(Serialize, Deserialize)]
struct DashboardData {
    status: String,
    version: String,
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Args::parse();

    // Initialize logging
    let filter = tracing_subscriber::EnvFilter::try_from_default_env()
        .or_else(|_| tracing_subscriber::EnvFilter::try_new(&args.log_level))?;

    tracing_subscriber::fmt()
        .with_env_filter(filter)
        .init();

    info!("Janus Web v{} starting", janus_core::VERSION);

    let app_state = AppState {
        runtime_api: args.runtime_api,
    };

    let app = Router::new()
        .route("/", get(index))
        .route("/api/dashboard", get(get_dashboard))
        .layer(CorsLayer::permissive())
        .with_state(app_state);

    let bind_addr = format!("{}:{}", args.bind, args.port);
    let listener = tokio::net::TcpListener::bind(&bind_addr).await?;
    info!("Web dashboard listening on {}", bind_addr);

    axum::serve(listener, app).await?;
    Ok(())
}

async fn index() -> Html<&'static str> {
    Html(
        r#"
<!DOCTYPE html>
<html>
<head>
    <title>Janus Control Panel</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            font-family: monospace;
            background: #0a0a0a;
            color: #00ff00;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        h1 { text-align: center; }
        .status { border: 1px solid #00ff00; padding: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚡ JANUS CONTROL PANEL ⚡</h1>
        <div class="status">
            <p>System Ready</p>
        </div>
    </div>
</body>
</html>
"#,
    )
}

async fn get_dashboard(
    AxumState(_state): AxumState<AppState>,
) -> (StatusCode, axum::response::Json<DashboardData>) {
    (
        StatusCode::OK,
        axum::response::Json(DashboardData {
            status: "ok".to_string(),
            version: janus_core::VERSION.to_string(),
        }),
    )
}
