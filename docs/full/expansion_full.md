# Expansion — Full Module Reference
**Category:** `expansion` | **Total Modules:** 4 | *Every module individually documented*

---

## exp_001 — Grid Override

**Platform:** pandora_titan

**What it does:** Interfaces with smart grid infrastructure (where accessible) to analyze power distribution, identify vulnerable nodes, and document control system topology.

**How to run:**
1. Expansion → exp_001
2. Connect to target grid network (via LAN or wireless)
3. Enumerate SCADA/ICS nodes on grid
4. Topology map generated

**Expected output:**
```
GRID OVERRIDE: CONNECTING
TARGET: Smart Grid Network
SCADA NODES: 23
CONTROL SYSTEMS: [enumerated]
VULNERABLE NODES: 5
SAVED: /Evidence/expansion/grid_topology.json
```

**Note:** Grid analysis is passive by default — active interaction requires explicit confirmation.

---

## exp_002 — Quantum Packet Injector

**Platform:** network

**What it does:** Injects specially crafted packets into quantum key distribution (QKD) networks to test for implementation vulnerabilities and side-channel leakage.

**How to run:**
1. Expansion → exp_002
2. Identify target QKD link
3. Configure injection parameters
4. Inject test packets and monitor for leakage

**Expected output:**
```
QUANTUM INJECTOR: RUNNING
TARGET: QKD LINK
INJECTION RATE: 1000 pkts/sec
LEAKAGE DETECTED: YES
QUBIT ERROR RATE: elevated
SAVED: /Evidence/expansion/qkd_analysis.json
```

**Note:** QKD vulnerability research — document findings thoroughly for academic/security report.

---

## exp_003 — Satellite Hijack

**Platform:** pandora_titan

**What it does:** Interfaces with satellite communication links — monitors uplinks, decodes traffic, and (with appropriate authorization) injects test packets into satellite data streams.

**How to run:**
1. Expansion → exp_003
2. Point Titan's high-gain antenna at target satellite
3. Lock on to downlink carrier
4. Decode traffic or inject test data

**Expected output:**
```
SAT HIJACK: LOCKING
SATELLITE: [acquired]
DOWNLINK: [frequency]
TRAFFIC: DECODING
INJECTION: STANDBY (awaiting auth)
SAVED: /Evidence/expansion/sat_traffic.json
```

**Note:** Satellite injection requires explicit operator authorization — passive monitoring is always safe.

---

## exp_004 — Biometric Spoof Engine

**Platform:** hardware

**What it does:** Creates synthetic biometric samples (fingerprint, iris, face, voice) calibrated to bypass specific biometric sensors and implementations.

**How to run:**
1. Expansion → exp_004
2. Select biometric type: Fingerprint / Iris / Face / Voice
3. Provide sample data (latent print / photo / voice clip)
4. Synthetic sample generated and printed/displayed

**Expected output:**
```
BIOMETRIC SPOOF: GENERATING
TYPE: FINGERPRINT
SOURCE: latent print from surface
RESOLUTION: 1200 DPI
GELATIN MOLD: SPECIFICATIONS GENERATED
SAVED: /Evidence/expansion/biometric_spoof/
```

**Note:** Fingerprint spoofs work best on optical sensors — capacitive sensors are more resistant.

---

