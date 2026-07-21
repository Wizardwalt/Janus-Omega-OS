//! # Janus Runtime
//!
//! Core runtime daemon providing:
//! - Plugin execution environment (Lua-based)
//! - HTTP/WebSocket API server
//! - State management and persistence (SQLite)
//! - Audit logging
//! - Hardware abstraction layer

use anyhow::Result;
use clap::Parser;
use janus_core::Config;
use std::path::PathBuf;
use tracing::info;

mod api;
mod executor;
mod state;

/// Janus Runtime CLI arguments
#[derive(Parser, Debug)]
#[command(name = "janus-runtime")]
#[command(about = "Janus OS runtime daemon", long_about = None)]
struct Args {
    /// Configuration file path
    #[arg(short, long, value_name = "FILE")]
    config: Option<PathBuf>,

    /// Plugin directory
    #[arg(short = 'p', long, value_name = "DIR")]
    plugin_dir: Option<PathBuf>,

    /// Database path
    #[arg(short = 'd', long, value_name = "FILE")]
    db_path: Option<PathBuf>,

    /// Web API bind address
    #[arg(short = 'b', long, value_name = "ADDR")]
    bind: Option<String>,

    /// Web API port
    #[arg(short = 'P', long, value_name = "PORT")]
    port: Option<u16>,

    /// Log level
    #[arg(long, value_name = "LEVEL", default_value = "info")]
    log_level: String,
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

    info!("Janus Runtime v{} starting", janus_core::VERSION);

    // Load configuration
    let mut config = Config::load()?;

    // Override with CLI arguments
    if let Some(plugin_dir) = args.plugin_dir {
        config.plugin_dir = plugin_dir;
    }
    if let Some(db_path) = args.db_path {
        config.db_path = db_path;
    }
    if let Some(bind) = args.bind {
        config.web_bind = bind;
    }
    if let Some(port) = args.port {
        config.web_port = port;
    }

    config.validate()?;

    info!("Configuration loaded: {:?}", config);

    // Initialize state manager
    let state_mgr = state::StateManager::new(&config).await?;
    info!("State manager initialized");

    // Initialize plugin executor
    let executor = executor::PluginExecutor::new(&config).await?;
    info!("Plugin executor initialized");

    // Start API server
    let api_server = api::ApiServer::new(config.clone(), state_mgr, executor);
    api_server.start().await?;

    Ok(())
}
