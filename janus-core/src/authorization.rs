//! Central authorization decision for production module execution.

use chrono::{DateTime, Utc};

use crate::{Engagement, LicensedFeature, ModuleCertification, SignedLicense};

/// Input required to authorize a real module execution.
pub struct ExecutionAuthorization<'a> {
    pub license: &'a SignedLicense,
    pub license_public_key_base64: &'a str,
    pub engagement: &'a Engagement,
    pub certification: &'a ModuleCertification,
    pub module_sha256: &'a str,
    pub target_asset: &'a str,
    pub now: DateTime<Utc>,
}

/// Verify every required business and technical control before execution.
///
/// This method intentionally does not execute a module. A runtime handler must
/// call it before it contacts any device, file, or customer-owned system.
pub fn authorize_execution(request: ExecutionAuthorization<'_>) -> crate::Result<()> {
    request
        .license
        .verify(request.license_public_key_base64, request.now)?;

    if request.license.claims.organization_id != request.engagement.organization_id {
        return Err(crate::JanusError::Security(
            "license organization does not match engagement organization".to_string(),
        ));
    }

    if !request.certification.is_production_approved() {
        return Err(crate::JanusError::Security(
            "module is not certified for production execution".to_string(),
        ));
    }

    if request.certification.module_sha256 != request.module_sha256 {
        return Err(crate::JanusError::Security(
            "module content differs from the certified version".to_string(),
        ));
    }

    let feature: &LicensedFeature = &request.certification.required_feature;
    if !request.license.claims.permits(feature, request.now) {
        return Err(crate::JanusError::License(
            "license does not permit the requested feature".to_string(),
        ));
    }

    if !request
        .engagement
        .authorizes(feature, request.target_asset, request.now)
    {
        return Err(crate::JanusError::Security(
            "engagement does not authorize this feature or target asset".to_string(),
        ));
    }

    Ok(())
}
