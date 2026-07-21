//! Capability registry and access control.

use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};

/// Single capability representing a system operation or resource.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct Capability {
    /// Namespace (e.g., "hardware", "network", "crypto")
    pub namespace: String,
    /// Capability name (e.g., "serial_port", "network_scan")
    pub name: String,
    /// Human-readable description
    pub description: String,
}

impl Capability {
    /// Create new capability
    pub fn new(
        namespace: impl Into<String>,
        name: impl Into<String>,
        description: impl Into<String>,
    ) -> Self {
        Self {
            namespace: namespace.into(),
            name: name.into(),
            description: description.into(),
        }
    }

    /// Get fully qualified capability name
    pub fn fqn(&self) -> String {
        format!("{}:{}", self.namespace, self.name)
    }
}

impl std::fmt::Display for Capability {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.fqn())
    }
}

/// Set of capabilities for access control.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct CapabilitySet {
    capabilities: HashSet<String>,
}

impl CapabilitySet {
    /// Create new empty capability set
    pub fn new() -> Self {
        Self::default()
    }

    /// Add capability
    pub fn add(&mut self, cap: &Capability) {
        self.capabilities.insert(cap.fqn());
    }

    /// Check if capability is granted
    pub fn has(&self, cap: &Capability) -> bool {
        self.capabilities.contains(&cap.fqn())
    }

    /// Grant all capabilities
    pub fn grant_all(&mut self, caps: &[Capability]) {
        for cap in caps {
            self.add(cap);
        }
    }
}

/// Registry of all available capabilities.
#[derive(Debug, Clone)]
pub struct CapabilityRegistry {
    capabilities: HashMap<String, Capability>,
}

impl Default for CapabilityRegistry {
    fn default() -> Self {
        Self::new()
    }
}

impl CapabilityRegistry {
    /// Create new registry
    pub fn new() -> Self {
        Self {
            capabilities: HashMap::new(),
        }
    }

    /// Register capability
    pub fn register(&mut self, cap: Capability) {
        self.capabilities.insert(cap.fqn(), cap);
    }

    /// Get capability by FQN
    pub fn get(&self, fqn: &str) -> Option<&Capability> {
        self.capabilities.get(fqn)
    }

    /// List all capabilities in namespace
    pub fn by_namespace(&self, namespace: &str) -> Vec<&Capability> {
        self.capabilities
            .values()
            .filter(|cap| cap.namespace == namespace)
            .collect()
    }

    /// Initialize with standard Titan capabilities
    pub fn with_defaults() -> Self {
        let mut registry = Self::new();

        // Hardware capabilities
        registry.register(Capability::new(
            "hardware",
            "serial_port",
            "Access serial UART interfaces",
        ));
        registry.register(Capability::new(
            "hardware",
            "gpio",
            "GPIO pin control and sensing",
        ));
        registry.register(Capability::new("hardware", "i2c", "I2C bus communication"));
        registry.register(Capability::new("hardware", "spi", "SPI bus communication"));
        registry.register(Capability::new(
            "hardware",
            "adc",
            "Analog-to-digital conversion",
        ));

        // Network capabilities
        registry.register(Capability::new(
            "network",
            "cellular_scan",
            "Scan cellular networks",
        ));
        registry.register(Capability::new(
            "network",
            "wifi_scan",
            "Scan WiFi networks",
        ));
        registry.register(Capability::new(
            "network",
            "dns_query",
            "Perform DNS queries",
        ));
        registry.register(Capability::new(
            "network",
            "mitm",
            "Man-in-the-middle operations",
        ));

        // RF capabilities
        registry.register(Capability::new(
            "rf",
            "subghz",
            "Sub-GHz frequency operations",
        ));
        registry.register(Capability::new(
            "rf",
            "satellite",
            "Satellite communication",
        ));
        registry.register(Capability::new(
            "rf",
            "bluetooth",
            "Bluetooth/BLE operations",
        ));

        // Crypto capabilities
        registry.register(Capability::new(
            "crypto",
            "encryption",
            "Encryption/decryption",
        ));
        registry.register(Capability::new(
            "crypto",
            "key_material",
            "Key generation and storage",
        ));
        registry.register(Capability::new("crypto", "signing", "Digital signatures"));

        // Storage capabilities
        registry.register(Capability::new(
            "storage",
            "database",
            "Database access and modification",
        ));
        registry.register(Capability::new(
            "storage",
            "file_system",
            "File system access",
        ));
        registry.register(Capability::new(
            "storage",
            "cloud",
            "Cloud storage integration",
        ));

        registry
    }
}
