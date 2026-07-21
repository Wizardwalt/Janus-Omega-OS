//! SQLite database layer for state persistence and audit logging.

use anyhow::Result;
use chrono::Utc;
use janus_core::{AuditEntry, AuditLevel, AuditLog, StateKey, SystemState};
use rusqlite::{params, Connection, OptionalExtension};
use std::{path::Path, sync::Mutex};
use tracing::debug;

/// Database manager for persistence
pub struct Database {
    conn: Mutex<Connection>,
}

impl Database {
    /// Open or create database
    pub fn open(path: impl AsRef<Path>) -> Result<Self> {
        let conn = Connection::open(path)?;
        let db = Self {
            conn: Mutex::new(conn),
        };
        db.init_schema()?;
        Ok(db)
    }

    /// Initialize database schema
    fn init_schema(&self) -> Result<()> {
        self.conn
            .lock()
            .map_err(|_| anyhow::anyhow!("database lock poisoned"))?
            .execute_batch(
                r#"
            CREATE TABLE IF NOT EXISTS state (
                id INTEGER PRIMARY KEY,
                key TEXT UNIQUE NOT NULL,
                value TEXT NOT NULL,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS audit_log (
                id TEXT PRIMARY KEY,
                timestamp TIMESTAMP NOT NULL,
                level TEXT NOT NULL,
                actor TEXT NOT NULL,
                action TEXT NOT NULL,
                resource TEXT NOT NULL,
                result TEXT NOT NULL,
                error TEXT,
                metadata TEXT
            );

            CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_log(timestamp);
            CREATE INDEX IF NOT EXISTS idx_audit_level ON audit_log(level);
            CREATE INDEX IF NOT EXISTS idx_state_key ON state(key);

            CREATE TABLE IF NOT EXISTS module_certifications (
                module_id TEXT PRIMARY KEY,
                module_sha256 TEXT NOT NULL,
                status TEXT NOT NULL,
                required_feature TEXT NOT NULL,
                reviewed_by TEXT,
                reviewed_at TEXT,
                notes TEXT,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            CREATE INDEX IF NOT EXISTS idx_module_certification_status
                ON module_certifications(status);
        "#,
            )?;
        debug!("Database schema initialized");
        Ok(())
    }

    /// Store state value
    pub fn set_state(&self, key: &StateKey, value: &serde_json::Value) -> Result<()> {
        let json_str = serde_json::to_string(value)?;
        self.conn
            .lock()
            .map_err(|_| anyhow::anyhow!("database lock poisoned"))?
            .execute(
                "INSERT OR REPLACE INTO state (key, value) VALUES (?1, ?2)",
                params![key.fqn(), json_str],
            )?;
        debug!("State persisted: {}", key);
        Ok(())
    }

    /// Remove a persisted state value.
    pub fn remove_state(&self, key: &StateKey) -> Result<()> {
        self.conn
            .lock()
            .map_err(|_| anyhow::anyhow!("database lock poisoned"))?
            .execute("DELETE FROM state WHERE key = ?1", params![key.fqn()])?;
        Ok(())
    }

    /// Retrieve state value
    pub fn get_state(&self, key: &StateKey) -> Result<Option<serde_json::Value>> {
        let conn = self
            .conn
            .lock()
            .map_err(|_| anyhow::anyhow!("database lock poisoned"))?;
        let result = conn
            .query_row(
                "SELECT value FROM state WHERE key = ?1",
                params![key.fqn()],
                |row| row.get::<_, String>(0),
            )
            .optional()?;

        Ok(result.and_then(|s| serde_json::from_str(&s).ok()))
    }

    /// Load all state
    pub fn load_all_state(&self) -> Result<SystemState> {
        let conn = self
            .conn
            .lock()
            .map_err(|_| anyhow::anyhow!("database lock poisoned"))?;
        let mut stmt = conn.prepare("SELECT key, value FROM state")?;
        let mut state = SystemState::new();

        let rows = stmt.query_map([], |row| {
            Ok((row.get::<_, String>(0)?, row.get::<_, String>(1)?))
        })?;

        for row_result in rows {
            let (key_str, value_str) = row_result?;
            if let Ok(value) = serde_json::from_str(&value_str) {
                let parts: Vec<&str> = key_str.split(':').collect();
                if parts.len() == 2 {
                    let key = StateKey::new(parts[0], parts[1]);
                    state.set(&key, value);
                }
            }
        }

        Ok(state)
    }
}

/// Audit log implementation
impl AuditLog for Database {
    fn record(&self, entry: AuditEntry) -> janus_core::Result<()> {
        let json = serde_json::to_string(&entry.metadata).unwrap_or_else(|_| "{}".to_string());

        self.conn
            .lock()
            .map_err(|_| janus_core::JanusError::Audit("database lock poisoned".to_string()))?
            .execute(
                r#"
                INSERT INTO audit_log 
                (id, timestamp, level, actor, action, resource, result, error, metadata)
                VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)
            "#,
                params![
                    entry.id,
                    entry.timestamp.to_rfc3339(),
                    entry.level.to_string(),
                    entry.actor,
                    entry.action,
                    entry.resource,
                    entry.result,
                    entry.error,
                    json
                ],
            )
            .map_err(|e| janus_core::JanusError::Audit(e.to_string()))?;

        Ok(())
    }

    fn query(&self, limit: usize) -> janus_core::Result<Vec<AuditEntry>> {
        let conn = self
            .conn
            .lock()
            .map_err(|_| janus_core::JanusError::Audit("database lock poisoned".to_string()))?;
        let mut stmt = conn
            .prepare(
                "SELECT id, timestamp, level, actor, action, resource, result, error, metadata 
                 FROM audit_log ORDER BY timestamp DESC LIMIT ?1",
            )
            .map_err(|e| janus_core::JanusError::Audit(e.to_string()))?;

        let entries = stmt
            .query_map(params![limit as i32], |row| {
                Ok(AuditEntry {
                    id: row.get(0)?,
                    timestamp: chrono::DateTime::parse_from_rfc3339(&row.get::<_, String>(1)?)
                        .map(|dt| dt.with_timezone(&Utc))
                        .unwrap_or_else(|_| Utc::now()),
                    level: match row.get::<_, String>(2)?.as_str() {
                        "WARN" => AuditLevel::Warn,
                        "ERROR" => AuditLevel::Error,
                        "CRITICAL" => AuditLevel::Critical,
                        _ => AuditLevel::Info,
                    },
                    actor: row.get(3)?,
                    action: row.get(4)?,
                    resource: row.get(5)?,
                    result: row.get(6)?,
                    error: row.get(7)?,
                    metadata: row
                        .get::<_, String>(8)
                        .ok()
                        .and_then(|s| serde_json::from_str(&s).ok())
                        .unwrap_or(serde_json::json!({})),
                })
            })
            .map_err(|e| janus_core::JanusError::Audit(e.to_string()))?
            .collect::<Result<Vec<_>, _>>()
            .map_err(|e| janus_core::JanusError::Audit(e.to_string()))?;

        Ok(entries)
    }

    fn cleanup(&self, days_old: u32) -> janus_core::Result<usize> {
        let cutoff = Utc::now() - chrono::Duration::days(days_old as i64);
        let rows = self
            .conn
            .lock()
            .map_err(|_| janus_core::JanusError::Audit("database lock poisoned".to_string()))?
            .execute(
                "DELETE FROM audit_log WHERE timestamp < ?1",
                params![cutoff.to_rfc3339()],
            )
            .map_err(|e| janus_core::JanusError::Audit(e.to_string()))?;

        Ok(rows)
    }
}
