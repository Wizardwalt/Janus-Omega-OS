//! Terminal UI components and layout.

use anyhow::Result;
use std::path::PathBuf;
use tracing::debug;

/// Run the TUI
pub async fn run(_db_path: Option<PathBuf>, _remote: Option<String>) -> Result<()> {
    debug!("Initializing TUI");

    // Placeholder: would initialize ratatui backend and render loop
    println!("Janus TUI - Maintenance Interface");
    println!("(Placeholder implementation)");

    Ok(())
}
