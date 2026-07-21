//! State management and persistence.

use crate::database::Database;
use anyhow::Result;
use janus_core::{Config, StateKey, SystemState};
use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::debug;

/// State manager with persistence layer.
pub struct StateManager {
    config: Config,
    state: Arc<RwLock<SystemState>>,
    db: Arc<Database>,
}

impl StateManager {
    /// Create new state manager
    pub async fn new(config: &Config, db: Arc<Database>) -> Result<Self> {
        debug!("Initializing state manager with DB: {}", config.db_path.display());
        let state = db.load_all_state()?;
        Ok(Self {
            config: config.clone(),
            state: Arc::new(RwLock::new(state)),
            db,
        })
    }

    /// Get current state
    pub async fn get_state(&self) -> Result<SystemState> {
        Ok(self.state.read().await.clone())
    }

    /// Get single state value
    pub async fn get(&self, key: &StateKey) -> Result<Option<serde_json::Value>> {
        Ok(self.state.read().await.get(key).cloned())
    }

    /// Update state
    pub async fn update_state(&self, key: &StateKey, value: serde_json::Value) -> Result<()> {
        self.state.write().await.set(key, value.clone());
        self.db.set_state(key, &value)?;
        Ok(())
    }

    /// Remove state value
    pub async fn remove(&self, key: &StateKey) -> Result<Option<serde_json::Value>> {
        let removed = self.state.write().await.remove(key);
        if removed.is_some() {
            self.db.remove_state(key)?;
        }
        Ok(removed)
    }
}
