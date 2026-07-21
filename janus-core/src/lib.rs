//! # Janus-Core
//!
//! Shared library providing foundational types, configuration structures,
//! plugin metadata, capability registry, audit trail types, and execution mode state.
//!
//! This crate is the single source of truth for all cross-crate data structures
//! and enables strong type safety across the distributed Janus ecosystem.

pub mod audit;
pub mod capabilities;
pub mod config;
pub mod error;
pub mod modes;
pub mod plugin;
pub mod state;

pub use audit::{AuditEntry, AuditLog, AuditLevel};
pub use capabilities::{Capability, CapabilityRegistry, CapabilitySet};
pub use config::{Config, ConfigError};
pub use error::{JanusError, Result};
pub use modes::{ExecutionMode, SystemMode};
pub use plugin::{Plugin, PluginMetadata, PluginStatus};
pub use state::{SystemState, StateKey};

/// Library version matching Cargo.toml
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
