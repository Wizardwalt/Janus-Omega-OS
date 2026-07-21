//! Error types for Janus ecosystem.

use std::fmt;

/// Result type alias for Janus operations.
pub type Result<T> = std::result::Result<T, JanusError>;

/// Comprehensive error type for Janus operations.
#[derive(Debug, Clone)]
pub enum JanusError {
    /// Plugin execution failed
    PluginExecution(String),
    /// Plugin not found
    PluginNotFound(String),
    /// Configuration error
    Config(String),
    /// Database operation failed
    Database(String),
    /// Audit trail corruption or access denied
    Audit(String),
    /// Lua runtime error
    LuaRuntime(String),
    /// State inconsistency
    StateError(String),
    /// Hardware interface error
    Hardware(String),
    /// API/Network error
    Network(String),
    /// Security violation
    Security(String),
    /// IO error
    Io(String),
    /// Generic error with context
    Other(String),
}

impl fmt::Display for JanusError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            JanusError::PluginExecution(msg) => write!(f, "Plugin execution failed: {}", msg),
            JanusError::PluginNotFound(name) => write!(f, "Plugin not found: {}", name),
            JanusError::Config(msg) => write!(f, "Configuration error: {}", msg),
            JanusError::Database(msg) => write!(f, "Database error: {}", msg),
            JanusError::Audit(msg) => write!(f, "Audit error: {}", msg),
            JanusError::LuaRuntime(msg) => write!(f, "Lua runtime error: {}", msg),
            JanusError::StateError(msg) => write!(f, "State error: {}", msg),
            JanusError::Hardware(msg) => write!(f, "Hardware error: {}", msg),
            JanusError::Network(msg) => write!(f, "Network error: {}", msg),
            JanusError::Security(msg) => write!(f, "Security violation: {}", msg),
            JanusError::Io(msg) => write!(f, "IO error: {}", msg),
            JanusError::Other(msg) => write!(f, "Error: {}", msg),
        }
    }
}

impl std::error::Error for JanusError {}
