//! Plugin metadata and manifest structures.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Plugin execution status.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum PluginStatus {
    /// Loaded and ready
    Ready,
    /// Currently executing
    Running,
    /// Paused/suspended
    Paused,
    /// Failed state
    Failed,
    /// Disabled by policy
    Disabled,
}

/// Plugin metadata from manifest.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PluginMetadata {
    /// Unique plugin identifier
    pub id: String,
    /// Display name
    pub name: String,
    /// Version
    pub version: String,
    /// Description
    pub description: String,
    /// Author
    pub author: String,
    /// Execution priority (0-255, lower executes first)
    pub priority: u8,
    /// Required capabilities
    pub capabilities: Vec<String>,
    /// Plugin category
    pub category: String,
    /// Implementation status: "production", "prototype", "stub", "planned"
    pub status: String,
    /// Custom configuration
    #[serde(default)]
    pub config: HashMap<String, serde_json::Value>,
}

/// Runtime plugin instance.
#[derive(Debug, Clone)]
pub struct Plugin {
    /// Metadata
    pub metadata: PluginMetadata,
    /// Current execution status
    pub status: PluginStatus,
    /// Last execution timestamp (Unix)
    pub last_execution: Option<i64>,
    /// Total executions
    pub execution_count: u64,
    /// Error message if failed
    pub error: Option<String>,
}

impl Plugin {
    /// Create new plugin instance
    pub fn new(metadata: PluginMetadata) -> Self {
        Self {
            metadata,
            status: PluginStatus::Ready,
            last_execution: None,
            execution_count: 0,
            error: None,
        }
    }

    /// Check if plugin is available for execution
    pub fn is_available(&self) -> bool {
        matches!(self.status, PluginStatus::Ready | PluginStatus::Paused)
    }
}
