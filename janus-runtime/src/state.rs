//! State management and persistence.

use anyhow::Result;
use janus_core::{Config, SystemState};
use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::debug;

/// State manager with persistence layer.
pub struct StateManager {
    config: Config,
    state: Arc<RwLock<SystemState>>,
}

impl StateManager {
    /// Create new state manager
    pub async fn new(config: &Config) -> Result<Self> {
        debug!("Initializing state manager with DB: {}", config.db_path.display());
        Ok(Self {
            config: config.clone(),
            state: Arc::new(RwLock::new(SystemState::new())),
        })
    }

    /// Get current state
    pub async fn get_state(&self) -> Result<SystemState> {
        Ok(self.state.read().await.clone())
    }

    /// Update state
    pub async fn update_state(&self, key: &janus_core::StateKey, value: serde_json::Value) -> Result<()> {
        self.state.write().await.set(key, value);
        // TODO: Persist to database
        Ok(())
    }
}
