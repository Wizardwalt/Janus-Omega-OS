//! System state and persistent data structures.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Type-safe state key for type-checked access.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct StateKey {
    /// Namespace for organization
    pub namespace: String,
    /// Key name
    pub key: String,
}

impl StateKey {
    /// Create new state key
    pub fn new(namespace: impl Into<String>, key: impl Into<String>) -> Self {
        Self {
            namespace: namespace.into(),
            key: key.into(),
        }
    }

    /// Get fully qualified key name
    pub fn fqn(&self) -> String {
        format!("{}:{}", self.namespace, self.key)
    }
}

impl std::fmt::Display for StateKey {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.fqn())
    }
}

/// Global system state container.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SystemState {
    /// Persistent key-value store
    state: HashMap<String, serde_json::Value>,
}

impl SystemState {
    /// Create new system state
    pub fn new() -> Self {
        Self::default()
    }

    /// Set state value
    pub fn set(&mut self, key: &StateKey, value: serde_json::Value) {
        self.state.insert(key.fqn(), value);
    }

    /// Get state value
    pub fn get(&self, key: &StateKey) -> Option<&serde_json::Value> {
        self.state.get(&key.fqn())
    }

    /// Get mutable state value
    pub fn get_mut(&mut self, key: &StateKey) -> Option<&mut serde_json::Value> {
        self.state.get_mut(&key.fqn())
    }

    /// Check if key exists
    pub fn contains(&self, key: &StateKey) -> bool {
        self.state.contains_key(&key.fqn())
    }

    /// Remove state value
    pub fn remove(&mut self, key: &StateKey) -> Option<serde_json::Value> {
        self.state.remove(&key.fqn())
    }

    /// Get all keys in namespace
    pub fn keys_in_namespace(&self, namespace: &str) -> Vec<String> {
        self.state
            .keys()
            .filter(|k| k.starts_with(&format!("{}:", namespace)))
            .cloned()
            .collect()
    }

    /// Clear all state
    pub fn clear(&mut self) {
        self.state.clear();
    }
}
