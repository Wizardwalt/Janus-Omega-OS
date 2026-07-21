//! Configuration management for Janus ecosystem.

use serde::{Deserialize, Serialize};
use std::path::PathBuf;

pub use crate::error::JanusError as ConfigError;

/// Global Janus configuration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    /// System operating mode
    pub system_mode: String,
    /// Database path
    pub db_path: PathBuf,
    /// Plugin directory
    pub plugin_dir: PathBuf,
    /// Lua core modules directory
    pub core_modules_dir: PathBuf,
    /// Web API bind address
    pub web_bind: String,
    /// Web API port
    pub web_port: u16,
    /// Enable audit logging
    pub audit_enabled: bool,
    /// Audit log retention (days)
    pub audit_retention_days: u32,
    /// Enable hardware integration
    pub hardware_enabled: bool,
    /// Serial port configuration
    pub serial_port: Option<String>,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            system_mode: "normal".to_string(),
            db_path: PathBuf::from("./janus.db"),
            plugin_dir: PathBuf::from("./plugins"),
            core_modules_dir: PathBuf::from("./core"),
            web_bind: "127.0.0.1".to_string(),
            web_port: 8080,
            audit_enabled: true,
            audit_retention_days: 90,
            hardware_enabled: true,
            serial_port: None,
        }
    }
}

impl Config {
    /// Load the default configuration.
    pub fn load() -> crate::Result<Self> {
        Ok(Self::default())
    }

    /// Load configuration from a JSON file.
    pub fn load_from_path(path: impl AsRef<std::path::Path>) -> crate::Result<Self> {
        let content = std::fs::read_to_string(path)
            .map_err(|error| crate::JanusError::Config(error.to_string()))?;
        serde_json::from_str(&content)
            .map_err(|error| crate::JanusError::Config(error.to_string()))
    }

    /// Validate configuration consistency
    pub fn validate(&self) -> crate::Result<()> {
        if self.web_port == 0 {
            return Err(crate::JanusError::Config("Invalid port: 0".to_string()));
        }
        Ok(())
    }
}
