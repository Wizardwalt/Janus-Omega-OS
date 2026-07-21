//! Execution and system modes for Janus.

use serde::{Deserialize, Serialize};

/// Execution mode for runtime behavior.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ExecutionMode {
    /// Normal operation
    Normal,
    /// Restricted safety mode
    Safe,
    /// Maintenance/debug mode
    Maintenance,
    /// Recovery environment
    Recovery,
}

impl std::fmt::Display for ExecutionMode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ExecutionMode::Normal => write!(f, "normal"),
            ExecutionMode::Safe => write!(f, "safe"),
            ExecutionMode::Maintenance => write!(f, "maintenance"),
            ExecutionMode::Recovery => write!(f, "recovery"),
        }
    }
}

/// Overall system mode and lifecycle state.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum SystemMode {
    /// Initializing
    Initializing,
    /// Fully operational
    Ready,
    /// Executing plugins
    Active,
    /// Paused/suspended
    Paused,
    /// Shutting down
    Shutting,
}

impl std::fmt::Display for SystemMode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SystemMode::Initializing => write!(f, "initializing"),
            SystemMode::Ready => write!(f, "ready"),
            SystemMode::Active => write!(f, "active"),
            SystemMode::Paused => write!(f, "paused"),
            SystemMode::Shutting => write!(f, "shutting"),
        }
    }
}
