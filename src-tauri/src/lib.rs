// src-tauri/src/lib.rs
// Core library for Janus Omega OS

pub mod state_manager;
pub mod plugin_sandbox;
pub mod ollama_bridge;
pub mod crypto;
pub mod hardware;
pub mod threat_detection;
pub mod error;

pub use state_manager::StateManager;
pub use plugin_sandbox::PluginSandbox;
pub use ollama_bridge::OllamaBridge;
pub use error::{Error, Result};

/// Initialize all core systems
pub async fn initialize() -> Result<()> {
    log::info!("Initializing Janus Omega OS...");
    
    // Initialize state manager
    StateManager::init().await?;
    
    // Initialize plugin sandbox
    PluginSandbox::init().await?;
    
    // Initialize Ollama bridge
    OllamaBridge::init().await?;
    
    log::info!("Janus Omega OS initialized successfully");
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_initialization() {
        assert!(initialize().await.is_ok());
    }
}
