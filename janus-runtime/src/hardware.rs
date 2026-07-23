//! Hardware abstraction layer for Titan device integration.

use anyhow::Result;
use serde::Serialize;
use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::{debug, info};

/// Honest adapter status returned to authenticated clients.
#[derive(Debug, Clone, Serialize)]
pub struct HardwareAdapterStatus {
    pub adapter: String,
    pub state: String,
    pub detail: String,
}

/// Hardware interface trait
pub trait HardwareInterface: Send + Sync {
    /// Get interface name
    fn name(&self) -> &str;

    /// Check if interface is available
    fn available(&self) -> bool;
}

/// Serial port interface
pub struct SerialInterface {
    port: String,
    available: bool,
}

impl SerialInterface {
    pub fn new(port: impl Into<String>) -> Self {
        Self {
            port: port.into(),
            available: true,
        }
    }

    pub async fn open(&mut self) -> Result<()> {
        debug!("Opening serial port: {}", self.port);
        // Placeholder: would use serialport crate
        Ok(())
    }

    pub async fn write(&self, data: &[u8]) -> Result<usize> {
        debug!("Writing {} bytes to serial", data.len());
        Ok(data.len())
    }

    pub async fn read(&self, buf: &mut [u8]) -> Result<usize> {
        debug!("Reading from serial");
        Ok(0)
    }
}

impl HardwareInterface for SerialInterface {
    fn name(&self) -> &str {
        "serial"
    }

    fn available(&self) -> bool {
        self.available
    }
}

/// GPIO interface
pub struct GpioInterface {
    pins: Vec<u32>,
}

impl GpioInterface {
    pub fn new() -> Self {
        Self { pins: vec![] }
    }

    pub async fn set_pin(&mut self, pin: u32, level: bool) -> Result<()> {
        debug!("GPIO pin {} -> {}", pin, level);
        Ok(())
    }

    pub async fn read_pin(&self, pin: u32) -> Result<bool> {
        debug!("Reading GPIO pin {}", pin);
        Ok(false)
    }
}

impl HardwareInterface for GpioInterface {
    fn name(&self) -> &str {
        "gpio"
    }

    fn available(&self) -> bool {
        false
    }
}

/// Cellular interface
pub struct CellularInterface;

impl CellularInterface {
    pub fn new() -> Self {
        Self
    }

    pub async fn scan(&self) -> Result<Vec<CellularNetwork>> {
        debug!("Scanning cellular networks");
        Ok(vec![])
    }
}

impl HardwareInterface for CellularInterface {
    fn name(&self) -> &str {
        "cellular"
    }

    fn available(&self) -> bool {
        false
    }
}

#[derive(Debug, Clone)]
pub struct CellularNetwork {
    pub name: String,
    pub signal_strength: i32,
}

/// RF (Radio Frequency) interface
pub struct RfInterface;

impl RfInterface {
    pub fn new() -> Self {
        Self
    }

    pub async fn scan_frequencies(&self, start: u32, end: u32) -> Result<Vec<RfSignal>> {
        debug!("Scanning RF: {} - {} Hz", start, end);
        Ok(vec![])
    }
}

impl HardwareInterface for RfInterface {
    fn name(&self) -> &str {
        "rf"
    }

    fn available(&self) -> bool {
        false
    }
}

#[derive(Debug, Clone)]
pub struct RfSignal {
    pub frequency: u32,
    pub strength: i32,
    pub modulation: String,
}

/// Sensor interface (accelerometer, GPS, etc.)
pub struct SensorInterface;

impl SensorInterface {
    pub fn new() -> Self {
        Self
    }

    pub async fn read_accelerometer(&self) -> Result<(f64, f64, f64)> {
        debug!("Reading accelerometer");
        Ok((0.0, 0.0, 9.8))
    }

    pub async fn read_gps(&self) -> Result<(f64, f64)> {
        debug!("Reading GPS");
        Ok((0.0, 0.0))
    }
}

impl HardwareInterface for SensorInterface {
    fn name(&self) -> &str {
        "sensors"
    }

    fn available(&self) -> bool {
        false
    }
}

/// Hardware manager coordinating all interfaces
pub struct HardwareManager {
    serial: Arc<RwLock<SerialInterface>>,
    gpio: Arc<RwLock<GpioInterface>>,
    cellular: Arc<RwLock<CellularInterface>>,
    rf: Arc<RwLock<RfInterface>>,
    sensors: Arc<RwLock<SensorInterface>>,
}

impl HardwareManager {
    pub fn new(serial_port: Option<String>) -> Self {
        let port = serial_port.unwrap_or_else(|| "/dev/ttyUSB0".to_string());
        Self {
            serial: Arc::new(RwLock::new(SerialInterface::new(port))),
            gpio: Arc::new(RwLock::new(GpioInterface::new())),
            cellular: Arc::new(RwLock::new(CellularInterface::new())),
            rf: Arc::new(RwLock::new(RfInterface::new())),
            sensors: Arc::new(RwLock::new(SensorInterface::new())),
        }
    }

    pub async fn initialize(&self) -> Result<()> {
        info!("Initializing hardware manager");
        // Would initialize each interface
        Ok(())
    }

    /// Report only verified adapter availability; unsupported adapters never claim readiness.
    pub async fn status(&self) -> Vec<HardwareAdapterStatus> {
        let serial = self.serial.read().await;
        let serial_exists = std::path::Path::new(&serial.port).exists();
        vec![
            HardwareAdapterStatus { adapter: "serial".into(), state: if serial_exists { "available" } else { "unavailable" }.into(), detail: format!("configured path: {}", serial.port) },
            HardwareAdapterStatus { adapter: "gpio".into(), state: "unsupported".into(), detail: "No production GPIO driver is installed.".into() },
            HardwareAdapterStatus { adapter: "cellular".into(), state: "unsupported".into(), detail: "No production cellular adapter is installed.".into() },
            HardwareAdapterStatus { adapter: "rf".into(), state: "unsupported".into(), detail: "No production RF adapter is installed.".into() },
            HardwareAdapterStatus { adapter: "sensors".into(), state: "unsupported".into(), detail: "No production sensor adapter is installed.".into() },
        ]
    }

    pub fn serial(&self) -> Arc<RwLock<SerialInterface>> {
        Arc::clone(&self.serial)
    }

    pub fn gpio(&self) -> Arc<RwLock<GpioInterface>> {
        Arc::clone(&self.gpio)
    }

    pub fn cellular(&self) -> Arc<RwLock<CellularInterface>> {
        Arc::clone(&self.cellular)
    }

    pub fn rf(&self) -> Arc<RwLock<RfInterface>> {
        Arc::clone(&self.rf)
    }

    pub fn sensors(&self) -> Arc<RwLock<SensorInterface>> {
        Arc::clone(&self.sensors)
    }
}
