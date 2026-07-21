//! State management and persistence.

use crate::database::Database;
use anyhow::Result;
use janus_core::{hash_password, AuditEntry, AuditLog, Config, Organization, StateKey, SystemState, UserAccount, UserRole};
use sha2::{Digest, Sha256};
use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::debug;

/// Authenticated session returned only after password verification.
pub struct LoginSession {
    pub token: String,
    pub expires_at: chrono::DateTime<chrono::Utc>,
    pub account: janus_core::UserAccount,
}

/// State manager with persistence layer.
pub struct StateManager {
    config: Config,
    state: Arc<RwLock<SystemState>>,
    db: Arc<Database>,
}

impl StateManager {
    /// Create new state manager
    pub async fn new(config: &Config, db: Arc<Database>) -> Result<Self> {
        debug!(
            "Initializing state manager with DB: {}",
            config.db_path.display()
        );
        let state = db.load_all_state()?;
        Ok(Self {
            config: config.clone(),
            state: Arc::new(RwLock::new(state)),
            db,
        })
    }

    /// Complete the one-time initial organization administrator setup.
    pub async fn bootstrap_first_admin(
        &self,
        organization_name: String,
        email: String,
        password: String,
    ) -> Result<(Organization, UserAccount)> {
        let organization_name = organization_name.trim();
        let email = email.trim().to_ascii_lowercase();
        if organization_name.is_empty() || email.is_empty() || !email.contains('@') {
            return Err(anyhow::anyhow!("organization name and a valid email are required"));
        }

        let now = chrono::Utc::now();
        let organization = Organization {
            id: format!("org_{}", uuid::Uuid::new_v4()),
            name: organization_name.to_string(),
            active: true,
            created_at: now,
        };
        let account = UserAccount {
            id: format!("usr_{}", uuid::Uuid::new_v4()),
            organization_id: organization.id.clone(),
            email,
            role: UserRole::OrganizationAdmin,
            active: true,
            failed_login_count: 0,
            locked_until: None,
            created_at: now,
        };
        let password_hash = hash_password(&password)?;
        self.db.bootstrap_first_admin(&organization, &account, &password_hash)?;
        self.db.record(
            AuditEntry::new("bootstrap", "INITIAL_ADMIN_CREATED", &account.id)
                .success()
                .with_metadata(serde_json::json!({"organization_id": organization.id, "email": account.email})),
        )?;
        Ok((organization, account))
    }

    /// Authenticate an active account and return an opaque, expiring session token.
    pub async fn login(&self, email: String, password: String) -> Result<LoginSession> {
        let email = email.trim().to_ascii_lowercase();
        let now = chrono::Utc::now();
        let stored = self
            .db
            .find_user_by_email(&email)?
            .ok_or_else(|| anyhow::anyhow!("invalid email or password"))?;

        if !stored.account.active {
            return Err(anyhow::anyhow!("account is inactive"));
        }
        if stored.account.locked_until.is_some_and(|until| until > now) {
            return Err(anyhow::anyhow!("account is temporarily locked"));
        }

        if !janus_core::verify_password(&password, &stored.password_hash)? {
            self.db.record_login_failure(&stored.account.id, now)?;
            self.db.record(
                AuditEntry::new(&stored.account.id, "LOGIN_FAILURE", "authentication")
                    .failed("invalid password"),
            )?;
            return Err(anyhow::anyhow!("invalid email or password"));
        }

        self.db.reset_login_failures(&stored.account.id)?;
        let token = format!("janus_{}", uuid::Uuid::new_v4());
        let token_hash = format!("{:x}", Sha256::digest(token.as_bytes()));
        let expires_at = now + chrono::Duration::hours(12);
        self.db.create_session(&token_hash, &stored.account.id, expires_at)?;
        self.db.record(
            AuditEntry::new(&stored.account.id, "LOGIN_SUCCESS", "authentication")
                .success(),
        )?;

        Ok(LoginSession {
            token,
            expires_at,
            account: stored.account,
        })
    }

    /// Get current state
    pub async fn get_state(&self) -> Result<SystemState> {
        Ok(self.state.read().await.clone())
    }

    /// Get single state value
    pub async fn get(&self, key: &StateKey) -> Result<Option<serde_json::Value>> {
        Ok(self.state.read().await.get(key).cloned())
    }

    /// Update state
    pub async fn update_state(&self, key: &StateKey, value: serde_json::Value) -> Result<()> {
        self.state.write().await.set(key, value.clone());
        self.db.set_state(key, &value)?;
        Ok(())
    }

    /// Remove state value
    pub async fn remove(&self, key: &StateKey) -> Result<Option<serde_json::Value>> {
        let removed = self.state.write().await.remove(key);
        if removed.is_some() {
            self.db.remove_state(key)?;
        }
        Ok(removed)
    }
}
