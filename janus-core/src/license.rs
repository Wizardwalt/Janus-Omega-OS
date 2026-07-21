//! Signed license claims and offline verification for Janus deployments.

use base64::{engine::general_purpose::STANDARD, Engine as _};
use chrono::{DateTime, Utc};
use ed25519_dalek::{Signature, Verifier, VerifyingKey};
use serde::{Deserialize, Serialize};

/// A capability that may be enabled by a customer license.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum LicensedFeature {
    Forensics,
    NetworkDiagnostics,
    HardwareDiagnostics,
    Reporting,
    ApiAccess,
}

/// Claims issued to a customer organization. These claims are signed as a whole.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LicenseClaims {
    pub license_id: String,
    pub organization_id: String,
    pub plan: String,
    pub issued_at: DateTime<Utc>,
    pub expires_at: DateTime<Utc>,
    pub max_operators: u32,
    pub enabled_features: Vec<LicensedFeature>,
}

impl LicenseClaims {
    /// Returns whether a feature is licensed at the supplied time.
    pub fn permits(&self, feature: &LicensedFeature, now: DateTime<Utc>) -> bool {
        now >= self.issued_at && now < self.expires_at && self.enabled_features.contains(feature)
    }
}

/// A license document signed by the Janus licensing service.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SignedLicense {
    pub claims: LicenseClaims,
    /// Base64-encoded Ed25519 signature over the JSON serialization of `claims`.
    pub signature: String,
}

impl SignedLicense {
    /// Verify this license against a base64-encoded Ed25519 public key.
    ///
    /// The corresponding private key must never be stored in the application,
    /// repository, customer deployment, or browser.
    pub fn verify(&self, public_key_base64: &str, now: DateTime<Utc>) -> crate::Result<()> {
        let public_key = decode_fixed::<32>(public_key_base64, "public key")?;
        let signature = decode_fixed::<64>(&self.signature, "signature")?;
        let verifying_key = VerifyingKey::from_bytes(&public_key)
            .map_err(|error| crate::JanusError::License(error.to_string()))?;
        let signature = Signature::from_bytes(&signature);
        let payload = serde_json::to_vec(&self.claims)
            .map_err(|error| crate::JanusError::License(error.to_string()))?;

        verifying_key
            .verify(&payload, &signature)
            .map_err(|_| crate::JanusError::License("license signature is invalid".to_string()))?;

        if now < self.claims.issued_at {
            return Err(crate::JanusError::License(
                "license is not active yet".to_string(),
            ));
        }
        if now >= self.claims.expires_at {
            return Err(crate::JanusError::License(
                "license has expired".to_string(),
            ));
        }
        Ok(())
    }
}

fn decode_fixed<const N: usize>(value: &str, label: &str) -> crate::Result<[u8; N]> {
    let bytes = STANDARD
        .decode(value)
        .map_err(|_| crate::JanusError::License(format!("invalid base64 {label}")))?;
    bytes
        .try_into()
        .map_err(|_| crate::JanusError::License(format!("{label} has an invalid length")))
}

#[cfg(test)]
mod tests {
    use super::*;
    use ed25519_dalek::{Signer, SigningKey};

    #[test]
    fn accepts_a_valid_signed_unexpired_license() {
        let now = Utc::now();
        let signing_key = SigningKey::from_bytes(&[7_u8; 32]);
        let claims = LicenseClaims {
            license_id: "lic_1".into(),
            organization_id: "org_1".into(),
            plan: "professional".into(),
            issued_at: now - chrono::Duration::hours(1),
            expires_at: now + chrono::Duration::hours(1),
            max_operators: 5,
            enabled_features: vec![LicensedFeature::Forensics],
        };
        let signature = signing_key.sign(&serde_json::to_vec(&claims).unwrap());
        let license = SignedLicense {
            claims,
            signature: STANDARD.encode(signature.to_bytes()),
        };

        assert!(license
            .verify(&STANDARD.encode(signing_key.verifying_key().to_bytes()), now)
            .is_ok());
    }
}
