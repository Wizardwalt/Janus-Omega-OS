//! Audit trail and logging infrastructure.

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// Audit log level/severity.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum AuditLevel {
    /// Informational
    Info,
    /// Warning
    Warn,
    /// Error
    Error,
    /// Critical security event
    Critical,
}

impl std::fmt::Display for AuditLevel {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AuditLevel::Info => write!(f, "INFO"),
            AuditLevel::Warn => write!(f, "WARN"),
            AuditLevel::Error => write!(f, "ERROR"),
            AuditLevel::Critical => write!(f, "CRITICAL"),
        }
    }
}

/// Single audit log entry.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuditEntry {
    /// Unique entry ID
    pub id: String,
    /// Timestamp
    pub timestamp: DateTime<Utc>,
    /// Severity level
    pub level: AuditLevel,
    /// Actor/component initiating action
    pub actor: String,
    /// Action performed
    pub action: String,
    /// Resource affected
    pub resource: String,
    /// Operation result: "success" or "failed"
    pub result: String,
    /// Error message if failed
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<String>,
    /// Additional metadata
    #[serde(default)]
    pub metadata: serde_json::Value,
}

impl AuditEntry {
    /// Create new audit entry
    pub fn new(
        actor: impl Into<String>,
        action: impl Into<String>,
        resource: impl Into<String>,
    ) -> Self {
        Self {
            id: uuid_simple(),
            timestamp: Utc::now(),
            level: AuditLevel::Info,
            actor: actor.into(),
            action: action.into(),
            resource: resource.into(),
            result: "pending".to_string(),
            error: None,
            metadata: serde_json::json!({}),
        }
    }

    /// Mark entry as successful
    pub fn success(mut self) -> Self {
        self.result = "success".to_string();
        self
    }

    /// Mark entry as failed
    pub fn failed(mut self, error: impl Into<String>) -> Self {
        self.result = "failed".to_string();
        self.error = Some(error.into());
        self
    }

    /// Set severity level
    pub fn with_level(mut self, level: AuditLevel) -> Self {
        self.level = level;
        self
    }

    /// Add metadata
    pub fn with_metadata(mut self, metadata: serde_json::Value) -> Self {
        self.metadata = metadata;
        self
    }
}

/// Audit trail interface.
pub trait AuditLog: Send + Sync {
    /// Record audit entry
    fn record(&self, entry: AuditEntry) -> crate::Result<()>;
    /// Query recent entries
    fn query(&self, limit: usize) -> crate::Result<Vec<AuditEntry>>;
    /// Cleanup old entries
    fn cleanup(&self, days_old: u32) -> crate::Result<usize>;
}

// Simple UUID generator (not cryptographic)
fn uuid_simple() -> String {
    use chrono::Local;
    format!(
        "{}-{}",
        Local::now().timestamp_millis(),
        (std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_nanos()
            % 1_000_000) as u64
    )
}
