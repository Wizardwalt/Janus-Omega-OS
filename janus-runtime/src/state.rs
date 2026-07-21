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

    /// Import a verified license for the authenticated organization.
    pub async fn import_license(
        &self,
        account: &janus_core::UserAccount,
        license: janus_core::SignedLicense,
    ) -> Result<()> {
        if !account.role.may_administer_organization() {
            return Err(anyhow::anyhow!("role is not allowed to import licenses"));
        }
        if license.claims.organization_id != account.organization_id {
            return Err(anyhow::anyhow!("license belongs to a different organization"));
        }
        let public_key = self.config.license_public_key.as_deref()
            .ok_or_else(|| anyhow::anyhow!("JANUS_LICENSE_PUBLIC_KEY is not configured"))?;
        self.db.store_license(&license, public_key)?;
        self.db.record(
            AuditEntry::new(&account.id, "LICENSE_IMPORTED", &license.claims.license_id)
                .success()
                .with_metadata(serde_json::json!({"organization_id": account.organization_id})),
        )?;
        Ok(())
    }

    /// Apply the complete license, engagement, target, and module certification gate.
    pub async fn authorize_production_execution(
        &self,
        account: &janus_core::UserAccount,
        engagement_id: &str,
        target_asset: &str,
        module_id: &str,
        module_sha256: &str,
    ) -> Result<()> {
        let public_key = self.config.license_public_key.as_deref()
            .ok_or_else(|| anyhow::anyhow!("JANUS_LICENSE_PUBLIC_KEY is not configured"))?;
        let license = self.db.find_active_license(&account.organization_id)?
            .ok_or_else(|| anyhow::anyhow!("organization has no active license"))?;
        let engagement = self.db.find_engagement(engagement_id)?
            .ok_or_else(|| anyhow::anyhow!("engagement was not found"))?;
        let certification = self.db.find_module_certification(module_id)?
            .ok_or_else(|| anyhow::anyhow!("module has no certification record"))?;
        janus_core::authorize_execution(janus_core::ExecutionAuthorization {
            license: &license,
            license_public_key_base64: public_key,
            engagement: &engagement,
            certification: &certification,
            module_sha256,
            target_asset,
            now: chrono::Utc::now(),
        })?;
        Ok(())
    }

    /// Resolve an opaque session token to an active account.
    pub async fn authenticate_session(&self, token: &str) -> Result<janus_core::UserAccount> {
        let token_hash = format!("{:x}", Sha256::digest(token.as_bytes()));
        let account = self
            .db
            .find_session_user(&token_hash, chrono::Utc::now())?
            .ok_or_else(|| anyhow::anyhow!("session is invalid or expired"))?;
        if !account.active {
            return Err(anyhow::anyhow!("account is inactive"));
        }
        Ok(account)
    }

    /// Revoke an opaque session token.
    pub async fn logout(&self, token: &str) -> Result<()> {
        let token_hash = format!("{:x}", Sha256::digest(token.as_bytes()));
        self.db.delete_session(&token_hash)
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
