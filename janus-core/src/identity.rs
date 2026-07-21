//! Organization and operator identity primitives.

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// Privileges granted to an authenticated Janus operator.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum UserRole {
    PlatformBreakGlassAdmin,
    OrganizationAdmin,
    Operator,
    Reviewer,
    CustomerReadOnly,
}

impl UserRole {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::PlatformBreakGlassAdmin => "platform_break_glass_admin",
            Self::OrganizationAdmin => "organization_admin",
            Self::Operator => "operator",
            Self::Reviewer => "reviewer",
            Self::CustomerReadOnly => "customer_read_only",
        }
    }
}

/// A customer or platform organization.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Organization {
    pub id: String,
    pub name: String,
    pub active: bool,
    pub created_at: DateTime<Utc>,
}

/// Janus-managed account metadata. Password hashes are intentionally not
/// serialized or exposed through public API response types.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserAccount {
    pub id: String,
    pub organization_id: String,
    pub email: String,
    pub role: UserRole,
    pub active: bool,
    pub failed_login_count: u32,
    pub locked_until: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
}
