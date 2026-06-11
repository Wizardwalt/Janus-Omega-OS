// src-tauri/src/crypto.rs
// Cryptographic utilities with AES-256-GCM and post-quantum preparation

use aes_gcm::{
    Aes256Gcm, Key, Nonce,
    aead::{Aead, NewAead},
};
use rand::RngCore;
use sha2::{Sha256, Digest};
use hmac::{Hmac, Mac};
use base64::{engine::general_purpose, Engine as _};
use crate::error::{Error, Result};

type HmacSha256 = Hmac<Sha256>;

/// Secure encryption context
pub struct Cipher {
    key: [u8; 32],
}

impl Cipher {
    /// Generate new random encryption key
    pub fn generate() -> Self {
        let mut key = [0u8; 32];
        rand::thread_rng().fill_bytes(&mut key);
        Cipher { key }
    }

    /// Create cipher from existing key (32 bytes for AES-256)
    pub fn from_key(key: &[u8; 32]) -> Self {
        Cipher { key: *key }
    }

    /// Encrypt data using AES-256-GCM
    pub fn encrypt(&self, plaintext: &[u8]) -> Result<Vec<u8>> {
        let cipher = Aes256Gcm::new(Key::<Aes256Gcm>::from_slice(&self.key));
        let mut nonce_bytes = [0u8; 12];
        rand::thread_rng().fill_bytes(&mut nonce_bytes);
        let nonce = Nonce::from_slice(&nonce_bytes);

        let mut output = nonce_bytes.to_vec();
        let ciphertext = cipher
            .encrypt(nonce, plaintext)
            .map_err(|e| Error::Crypto(format!("Encryption failed: {}", e)))?;
        output.extend_from_slice(&ciphertext);
        Ok(output)
    }

    /// Decrypt data using AES-256-GCM
    pub fn decrypt(&self, ciphertext: &[u8]) -> Result<Vec<u8>> {
        if ciphertext.len() < 12 {
            return Err(Error::Crypto("Invalid ciphertext length".to_string()));
        }

        let (nonce_bytes, encrypted) = ciphertext.split_at(12);
        let cipher = Aes256Gcm::new(Key::<Aes256Gcm>::from_slice(&self.key));
        let nonce = Nonce::from_slice(nonce_bytes);

        cipher
            .decrypt(nonce, encrypted)
            .map_err(|e| Error::Crypto(format!("Decryption failed: {}", e)))
    }
}

/// Hash data using SHA-256
pub fn hash_sha256(data: &[u8]) -> [u8; 32] {
    let mut hasher = Sha256::new();
    hasher.update(data);
    let result = hasher.finalize();
    let mut hash = [0u8; 32];
    hash.copy_from_slice(&result[..]);
    hash
}

/// Compute HMAC-SHA256
pub fn hmac_sha256(key: &[u8], data: &[u8]) -> Result<Vec<u8>> {
    let mut mac = HmacSha256::new_from_slice(key)
        .map_err(|e| Error::Crypto(format!("HMAC key error: {}", e)))?;
    mac.update(data);
    Ok(mac.finalize().into_bytes().to_vec())
}

/// Encode bytes to base64
pub fn encode_base64(data: &[u8]) -> String {
    general_purpose::STANDARD.encode(data)
}

/// Decode base64 string
pub fn decode_base64(encoded: &str) -> Result<Vec<u8>> {
    general_purpose::STANDARD
        .decode(encoded)
        .map_err(|e| Error::Crypto(format!("Base64 decode error: {}", e)))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encrypt_decrypt() {
        let cipher = Cipher::generate();
        let plaintext = b"Hello, secure world!";
        let encrypted = cipher.encrypt(plaintext).unwrap();
        let decrypted = cipher.decrypt(&encrypted).unwrap();
        assert_eq!(plaintext, &decrypted[..]);
    }

    #[test]
    fn test_hash_sha256() {
        let data = b"test data";
        let hash = hash_sha256(data);
        assert_eq!(hash.len(), 32);
    }

    #[test]
    fn test_hmac_sha256() {
        let key = b"secret key";
        let data = b"message";
        let hmac = hmac_sha256(key, data).unwrap();
        assert_eq!(hmac.len(), 32);
    }
}
