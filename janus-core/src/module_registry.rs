//! Production certification metadata for discoverable modules.

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use crate::LicensedFeature;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum CertificationStatus {
    PendingReview,
    Unsupported,
    Deprecated,
    DemoOnly,
    ProductionApproved,
}

impl CertificationStatus {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::PendingReview => "pending_review",
            Self::Unsupported => "unsupported",
            Self::Deprecated => "deprecated",
            Self::DemoOnly => "demo_only",
            Self::ProductionApproved => "production_approved",
        }
    }

    pub fn from_str(value: &str) -> Option<Self> {
        match value {
            "pending_review" => Some(Self::PendingReview),
            "unsupported" => Some(Self::Unsupported),
            "deprecated" => Some(Self::Deprecated),
            "demo_only" => Some(Self::DemoOnly),
            "production_approved" => Some(Self::ProductionApproved),
            _ => None,
        }
    }
}

/// Certification record required before a module can be considered for production execution.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModuleCertification {
    pub module_id: String,
    pub module_sha256: String,
    pub status: CertificationStatus,
    pub required_feature: LicensedFeature,
    pub reviewed_by: Option<String>,
    pub reviewed_at: Option<DateTime<Utc>>,
    pub notes: Option<String>,
}

impl ModuleCertification {
    pub fn is_production_approved(&self) -> bool {
        self.status == CertificationStatus::ProductionApproved
    }
}
