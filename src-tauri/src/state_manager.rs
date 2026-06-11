// src-tauri/src/state_manager.rs
// Secure RAM state snapshot and recovery daemon with AES-256-GCM encryption

use std::{fs, path::PathBuf, sync::Arc, thread, time::Duration};
use chrono::Utc;
use serde::{Serialize, Deserialize};
use tokio::sync::RwLock;
use crate::crypto::Cipher;
use crate::error::{Error, Result};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SystemState {
    pub timestamp: i64,
    pub lua_context: String,
    pub system_status: String,
    pub battery_level: f32,
    pub network_status: bool,
    pub active_modules: Vec<String>,
}

impl Default for SystemState {
    fn default() -> Self {
        SystemState {
            timestamp: Utc::now().timestamp(),
            lua_context: "{}".to_string(),
            system_status: "initialized".to_string(),
            battery_level: 100.0,
            network_status: false,
            active_modules: vec![],
        }
    }
}

pub struct StateManager {
    cipher: Cipher,
    state_dir: PathBuf,
    current_state: Arc<RwLock<SystemState>>,
}

impl StateManager {
    /// Initialize state manager with encryption key
    pub async fn init() -> Result<Self> {
        let state_dir = PathBuf::from("/var/janus/state");
        fs::create_dir_all(&state_dir)
            .map_err(|e| Error::StateManager(format!("Failed to create state dir: {}", e)))?;

        let cipher = Cipher::generate();
        let current_state = Arc::new(RwLock::new(SystemState::default()));

        Ok(StateManager {
            cipher,
            state_dir,
            current_state,
        })
    }

    /// Load state manager with existing key
    pub async fn with_key(key: &[u8; 32]) -> Result<Self> {
        let state_dir = PathBuf::from("/var/janus/state");
        fs::create_dir_all(&state_dir)
            .map_err(|e| Error::StateManager(format!("Failed to create state dir: {}", e)))?;

        let cipher = Cipher::from_key(key);
        let current_state = Arc::new(RwLock::new(SystemState::default()));

        Ok(StateManager {
            cipher,
            state_dir,
            current_state,
        })
    }

    /// Update current state
    pub async fn update_state(&self, state: SystemState) -> Result<()> {
        let mut current = self.current_state.write().await;
        *current = state;
        Ok(())
    }

    /// Get current state
    pub async fn get_state(&self) -> Result<SystemState> {
        let state = self.current_state.read().await;
        Ok(state.clone())
    }

    /// Take encrypted snapshot of current state
    pub async fn snapshot(&self) -> Result<String> {
        let state = self.current_state.read().await;
        let json = serde_json::to_string(&*state)
            .map_err(|e| Error::StateManager(format!("Failed to serialize state: {}", e)))?;

        let encrypted = self.cipher.encrypt(json.as_bytes())?;
        let timestamp = Utc::now().timestamp();
        let path = self.state_dir.join(format!("snap_{}.bin", timestamp));

        fs::write(&path, &encrypted)
            .map_err(|e| Error::StateManager(format!("Failed to write snapshot: {}", e)))?;

        log::info!("State snapshot saved: {:?}", path);
        Ok(path.to_string_lossy().to_string())
    }

    /// Restore state from latest snapshot
    pub async fn restore(&self) -> Result<SystemState> {
        let mut latest_file: Option<PathBuf> = None;
        let mut latest_time = 0i64;

        if let Ok(entries) = fs::read_dir(&self.state_dir) {
            for entry in entries.flatten() {
                if let Ok(metadata) = entry.metadata() {
                    if let Ok(modified) = metadata.modified() {
                        if let Ok(duration) = modified.duration_since(std::time::UNIX_EPOCH) {
                            let timestamp = duration.as_secs() as i64;
                            if timestamp > latest_time {
                                latest_time = timestamp;
                                latest_file = Some(entry.path());
                            }
                        }
                    }
                }
            }
        }

        if let Some(path) = latest_file {
            let encrypted_data = fs::read(&path)
                .map_err(|e| Error::StateManager(format!("Failed to read snapshot: {}", e)))?;
            let decrypted = self.cipher.decrypt(&encrypted_data)?;
            let json_str = String::from_utf8(decrypted)
                .map_err(|e| Error::StateManager(format!("Invalid UTF-8: {}", e)))?;
            let state: SystemState = serde_json::from_str(&json_str)
                .map_err(|e| Error::StateManager(format!("Failed to deserialize state: {}", e)))?;

            log::info!("State restored from: {:?}", path);
            Ok(state)
        } else {
            Err(Error::StateManager(
                "No state snapshots found".to_string(),
            ))
        }
    }

    /// Start background snapshot daemon (every 5 minutes)
    pub fn start_daemon(self: Arc<Self>) {
        std::thread::spawn(move || {
            let rt = tokio::runtime::Runtime::new().expect("Failed to create runtime");
            rt.block_on(async {
                loop {
                    tokio::time::sleep(Duration::from_secs(300)).await;
                    match self.snapshot().await {
                        Ok(path) => log::debug!("Snapshot saved: {}", path),
                        Err(e) => log::error!("Snapshot failed: {}", e),
                    }
                }
            });
        });
    }

    /// Clean old snapshots (keep last N)
    pub async fn cleanup_old_snapshots(&self, keep_count: usize) -> Result<()> {
        let mut files: Vec<(PathBuf, i64)> = Vec::new();

        if let Ok(entries) = fs::read_dir(&self.state_dir) {
            for entry in entries.flatten() {
                if let Ok(metadata) = entry.metadata() {
                    if let Ok(modified) = metadata.modified() {
                        if let Ok(duration) = modified.duration_since(std::time::UNIX_EPOCH) {
                            let timestamp = duration.as_secs() as i64;
                            files.push((entry.path(), timestamp));
                        }
                    }
                }
            }
        }

        files.sort_by_key(|f| std::cmp::Reverse(f.1));

        for (path, _) in files.iter().skip(keep_count) {
            fs::remove_file(path)
                .map_err(|e| Error::StateManager(format!("Failed to delete snapshot: {}", e)))?;
        }

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_state_manager_init() {
        let manager = StateManager::init().await.unwrap();
        let state = manager.get_state().await.unwrap();
        assert_eq!(state.battery_level, 100.0);
    }

    #[tokio::test]
    async fn test_snapshot_and_restore() {
        let manager = StateManager::init().await.unwrap();
        let mut state = SystemState::default();
        state.battery_level = 75.0;
        manager.update_state(state.clone()).await.unwrap();
        
        manager.snapshot().await.unwrap();
        let restored = manager.restore().await.unwrap();
        assert_eq!(restored.battery_level, 75.0);
    }
}
