//! # Janus TUI
//!
//! Terminal User Interface for maintenance, debugging, and recovery operations.
//! Provides access to system state, plugin management, and Lua REPL.

use anyhow::Result;
use clap::Parser;
use std::path::PathBuf;
use tracing::info;

mod repl;
mod ui;

#[derive(Parser, Debug)]
#[command(name = "janus-tui")]
#[command(about = "Janus maintenance terminal UI", long_about = None)]
struct Args {
    /// Database path
    #[arg(short, long, value_name = "FILE")]
    db: Option<PathBuf>,

    /// Connect to remote runtime
    #[arg(short = 'r', long, value_name = "ADDR:PORT")]
    remote: Option<String>,

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

    tracing_subscriber::fmt().with_env_filter(filter).init();

    info!("Janus TUI v{} starting", janus_core::VERSION);

    // Start UI
    ui::run(args.db, args.remote).await?;

    Ok(())
}
