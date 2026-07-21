//! Customer engagement scope and authorization primitives.

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use crate::LicensedFeature;

/// The approved scope for a customer engagement.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct EngagementScope {
    /// Exact normalized host names or IP addresses approved by the customer.
    pub approved_assets: Vec<String>,
    /// Canonical evidence paths approved for read-only collection.
    pub approved_evidence_paths: Vec<String>,
    /// Services expressly authorized for this engagement.
    pub approved_features: Vec<LicensedFeature>,
}

impl EngagementScope {
    pub fn permits_feature(&self, feature: &LicensedFeature) -> bool {
        self.approved_features.contains(feature)
    }

    /// Exact-match only. CIDR/range support must be implemented with a dedicated,
    /// tested parser rather than prefix matching.
    pub fn permits_asset(&self, asset: &str) -> bool {
        self.approved_assets.iter().any(|approved| approved == asset)
    }

    pub fn permits_evidence_path(&self, path: &str) -> bool {
        self.approved_evidence_paths.iter().any(|approved| approved == path)
    }
}

/// A time-bounded authorization issued by a customer for a defined service scope.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Engagement {
    pub id: String,
    pub organization_id: String,
    pub authorization_reference: String,
    pub starts_at: DateTime<Utc>,
    pub ends_at: DateTime<Utc>,
    pub scope: EngagementScope,
    pub active: bool,
}

impl Engagement {
    pub fn is_active_at(&self, now: DateTime<Utc>) -> bool {
        self.active && now >= self.starts_at && now < self.ends_at
    }

    pub fn authorizes(&self, feature: &LicensedFeature, asset: &str, now: DateTime<Utc>) -> bool {
        self.is_active_at(now) && self.scope.permits_feature(feature) && self.scope.permits_asset(asset)
    }
}
