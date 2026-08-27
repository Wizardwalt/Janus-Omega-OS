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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{CertificationStatus, EngagementScope, LicenseClaims};
    use base64::{engine::general_purpose::STANDARD, Engine as _};
    use ed25519_dalek::{Signer, SigningKey};

    fn signed_license(now: DateTime<Utc>) -> (SignedLicense, String) {
        let signing_key = SigningKey::from_bytes(&[9_u8; 32]);
        let claims = LicenseClaims {
            license_id: "lic_1".into(),
            organization_id: "org_1".into(),
            plan: "professional".into(),
            issued_at: now - chrono::Duration::hours(1),
            expires_at: now + chrono::Duration::hours(1),
            max_operators: 1,
            enabled_features: vec![LicensedFeature::Forensics],
        };
        let signature = signing_key.sign(&serde_json::to_vec(&claims).unwrap());
        (
            SignedLicense {
                claims,
                signature: STANDARD.encode(signature.to_bytes()),
            },
            STANDARD.encode(signing_key.verifying_key().to_bytes()),
        )
    }

    #[test]
    fn rejects_a_changed_module_even_with_valid_license_and_scope() {
        let now = Utc::now();
        let (license, public_key) = signed_license(now);
        let engagement = Engagement {
            id: "eng_1".into(),
            organization_id: "org_1".into(),
            authorization_reference: "AUTH-1".into(),
            starts_at: now - chrono::Duration::hours(1),
            ends_at: now + chrono::Duration::hours(1),
            active: true,
            scope: EngagementScope {
                approved_assets: vec!["evidence-1".into()],
                approved_evidence_paths: vec![],
                approved_features: vec![LicensedFeature::Forensics],
            },
        };
        let certification = ModuleCertification {
            module_id: "forensics.hash".into(),
            module_sha256: "reviewed-hash".into(),
            status: CertificationStatus::ProductionApproved,
            required_feature: LicensedFeature::Forensics,
            reviewed_by: Some("reviewer".into()),
            reviewed_at: Some(now),
            notes: None,
        };
        let result = authorize_execution(ExecutionAuthorization {
            license: &license,
            license_public_key_base64: &public_key,
            engagement: &engagement,
            certification: &certification,
            module_sha256: "changed-hash",
            target_asset: "evidence-1",
            now,
        });
        assert!(result.is_err());
    }
}
