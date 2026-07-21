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
        self.approved_assets
            .iter()
            .any(|approved| approved == asset)
    }

    pub fn permits_evidence_path(&self, path: &str) -> bool {
        self.approved_evidence_paths
            .iter()
            .any(|approved| approved == path)
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
        self.is_active_at(now)
            && self.scope.permits_feature(feature)
            && self.scope.permits_asset(asset)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Duration;

    #[test]
    fn engagement_requires_an_active_window_feature_and_exact_asset() {
        let now = Utc::now();
        let engagement = Engagement {
            id: "eng_1".into(),
            organization_id: "org_1".into(),
            authorization_reference: "AUTH-1".into(),
            starts_at: now - Duration::hours(1),
            ends_at: now + Duration::hours(1),
            active: true,
            scope: EngagementScope {
                approved_assets: vec!["diagnostic.example.com".into()],
                approved_evidence_paths: vec![],
                approved_features: vec![LicensedFeature::NetworkDiagnostics],
            },
        };

        assert!(engagement.authorizes(
            &LicensedFeature::NetworkDiagnostics,
            "diagnostic.example.com",
            now,
        ));
        assert!(!engagement.authorizes(
            &LicensedFeature::NetworkDiagnostics,
            "unapproved.example.com",
            now,
        ));
        assert!(!engagement.authorizes(
            &LicensedFeature::Forensics,
            "diagnostic.example.com",
            now,
        ));
    }
}
