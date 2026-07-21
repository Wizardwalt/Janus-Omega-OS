//! Dashboard data structures and utilities.

use serde::{Deserialize, Serialize};

/// Dashboard state snapshot
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Dashboard {
    /// System mode
    pub mode: String,
    /// Active plugins
    pub active_plugins: u32,
    /// Audit log entries today
    pub audit_entries: u32,
}
