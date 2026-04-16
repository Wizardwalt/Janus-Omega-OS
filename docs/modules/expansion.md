# Expansion — Module How-To Guide
**Category:** `expansion` | **Module Count:** 4

The Expansion category contains high-power attack modules that go beyond standard device targets — covering biometric spoofing, industrial infrastructure attacks, raw packet injection, and satellite signal interception.

---

## bio_metric_spoof.lua — Synthetic Biometric Generation

**What it does:** Generates and injects synthetic biometric signatures (fingerprint patterns, iris codes) to bypass biometric authentication on target systems.

**When to use:** Physical access point secured by biometric scanner, or remote biometric authentication needs to be bypassed.

**How to run:**
1. Janus TUI → **Expansion** → **Bio-Metric Spoof**
2. Select biometric type: Fingerprint / Iris / Both
3. Choose generation method: Random synthetic / Model from image / Clone from capture
4. If cloning — provide source image or captured scan
5. Module outputs injectable biometric data package

**Expected output:**
```
GENERATING SYNTHETIC BIOMETRIC PROFILE...
SPOOFING: Fingerprint / Iris Pattern
PROFILE GENERATED: [HASH]
INJECTING INTO TARGET ENCLAVE...
STATUS: AUTHENTICATED
```

---

## grid_override.lua — Infrastructure Command & Control

**What it does:** Scans local networks for SCADA/PLC (industrial control system) gateways and injects command packets to manipulate connected infrastructure (power, water, HVAC, etc.).

**When to use:** Industrial penetration testing against SCADA systems on isolated networks.

**How to run:**
1. Connect to the target OT (operational technology) network
2. Janus TUI → **Expansion** → **Grid Override**
3. Module scans for Modbus, DNP3, and S7 protocol devices
4. Select target device from discovered list
5. Choose command: Read / Write / Override / Shutdown

**Expected output:**
```
SCANNING LOCAL POWER GRID NODES...
IDENTIFYING SCADA GATEWAYS: 3 FOUND
PROTOCOL: Modbus TCP
TARGET: [DEVICE ID]
INJECTING COMMAND PACKETS...
RESPONSE: ACK
STATUS: CONTROL ESTABLISHED
```

**Warning:** Use only on isolated lab networks or with explicit written authorization.

---

## packet_injector.lua — Layer 2/3 Custom Injection

**What it does:** Crafts and injects raw Ethernet and IP packets into the network — bypassing the OS network stack entirely. Used for exploit delivery, protocol fuzzing, and network manipulation.

**How to run:**
1. Janus TUI → **Expansion** → **Packet Injector**
2. Select injection level: Layer 2 (Ethernet) / Layer 3 (IP) / Layer 4 (TCP/UDP)
3. Load a payload template or craft manually (hex editor view)
4. Set target MAC/IP and broadcast options
5. Execute injection sequence

**Expected output:**
```
INITIALIZING RAW PACKET ENGINE...
CRAFTING EXPLOIT PAYLOAD...
PACKET SIZE: 1500 bytes
INJECTION INTERFACE: [wlan0/eth0]
BROADCASTING ON LOCAL SUBNET...
PACKETS SENT: 1000 | ACK: 847
```

---

## sat_hijack.lua — Low-Orbit Signal Interception

**What it does:** Uses the Hydra Radio Array (or high-gain external antenna) to lock onto LEO satellite downlink beacons and attempt to intercept and decrypt the packet stream.

**When to use:** Satellite communications intelligence gathering.

**How to run:**
1. Ensure high-gain antenna is connected (or Pandora Titan's Hydra Array is active)
2. Janus TUI → **Expansion** → **Sat Hijack**
3. Select constellation target: Starlink / Iridium / OneWeb / GPS
4. Module locks onto downlink frequency and begins capture
5. Captured IQ data saved for offline analysis

**Expected output:**
```
TARGETING LEO CONSTELLATION...
LOCKING ON DOWNLINK BEACON: [FREQ]
SIGNAL STRENGTH: -72dBm
DECRYPTING PACKET STREAM...
FRAMES CAPTURED: 4,892
SAVED: /Intelligence/sigint/sat_capture.iq
```
