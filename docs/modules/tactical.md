# Tactical — Module How-To Guide
**Category:** `tactical` | **Module Count:** 5

The Tactical category contains Janus system-level intelligence and networking modules that operate as background daemons — supporting all other operations with AI analysis, mesh networking, stealth, signal intelligence, and network mapping.

---

## janus_ai.lua — Localized Offline Intelligence

**What it does:** Activates the Singularity AI engine running on the Hailo-8 AI accelerator. Provides real-time signal analysis, threat classification, OSINT correlation, and tactical recommendations without any internet connection.

**How to run:**
1. Janus TUI → **Tactical** → **Janus AI**
2. AI engine starts as a background daemon
3. All other modules automatically route analysis requests through the AI
4. Query directly: type a question in the AI prompt overlay

**Expected output:**
```
INITIALIZING JANUS-AI...
AI ACCELERATOR (Hailo-8): ONLINE
MODEL: SINGULARITY v3.0 (LOCAL)
INFERENCE ENGINE: READY
STATUS: TACTICAL ANALYSIS ACTIVE
```

**Queries you can ask:**
- "Classify this signal" — feed .iq file, get modulation type
- "Who owns this IP" — OSINT correlation
- "Recommend next step" — tactical advice based on active operation
- "Analyze this PCAP" — network traffic summary

---

## ghost_net.lua — P2P Mesh Networking

**What it does:** Creates an encrypted peer-to-peer mesh network between all active Pandora units in range. Allows sharing of intelligence, module output, and live feeds across a team without any internet infrastructure.

**How to run:**
1. Janus TUI → **Tactical** → **Ghost-Net**
2. Module broadcasts discovery beacon on sub-GHz band
3. Other Pandora units running Ghost-Net will appear in the peer list
4. Share data: select peer → share module output / live feed / file

**Expected output:**
```
ACTIVATING GHOST-NET MESH...
SYNCING PANDORA UNITS...
PEERS DISCOVERED: 2
ENCRYPTION: AES-256 + Kyber-1024 (Post-Quantum)
MESH STATUS: ONLINE
LATENCY: 12ms
```

---

## stealth_boot.lua — Decoy OS Controller

**What it does:** Arms the Chameleon Mode system — when the panic button is pressed or a trigger condition is met, the Titan display instantly switches to a pre-configured decoy skin (calculator, medical monitor, standard smartwatch UI).

**How to run:**
1. Janus TUI → **Tactical** → **Stealth Boot**
2. Select decoy skin: Calculator / Medical / Standard Watch / Custom
3. Set trigger: Panic Button / Wrong PIN / Scheduled
4. Arm — system remains running JanusOS underneath

**Expected output:**
```
CONFIGURING STEALTH-BOOT...
SKIN: CALCULATOR MODE
TRIGGER: PANIC BUTTON
JANUS CONTINUES: BACKGROUND
DECOY OS ARMED
```

---

## deep_signal_analyzer.lua — Deep Frequency Fingerprinting

**What it does:** Performs deep spectral analysis of captured radio signals, extracting modulation characteristics, device fingerprints, and emitter patterns for source identification.

**How to run:**
1. Janus TUI → **Tactical** → **Deep Signal Analyzer**
2. Load a captured .iq file or point to live SDR input
3. Set analysis depth: Quick / Standard / Deep (Hailo-8 accelerated)
4. Review frequency fingerprint report

**Expected output:**
```
INITIALIZING DEEP SIGNAL ANALYZER...
TARGET: MULTI-SPECTRAL EMISSIONS
ANALYSIS MODE: DEEP (AI-ASSISTED)
EMITTER FINGERPRINT: [HASH]
DEVICE TYPE: Motorola Solutions P25 Radio
CONFIDENCE: 91.2%
```

---

## network_cartographer.lua — Advanced Topology Mapping

**What it does:** Performs a comprehensive network topology scan, mapping all devices, their relationships, open services, and traffic flows. Generates an interactive network map.

**How to run:**
1. Connect to the target network (wired or wireless)
2. Janus TUI → **Tactical** → **Network Cartographer**
3. Set scan scope: /24 subnet / /16 / Custom range
4. Select depth: Ping sweep / Port scan / Service fingerprint / Full
5. Review generated map in the TUI topology view

**Expected output:**
```
MAP GENERATION IN PROGRESS...
SCANNING SUBNET: 192.168.1.0/24
HOSTS DISCOVERED: 23
OPEN PORTS MAPPED: 156
SERVICES IDENTIFIED: 34
TOPOLOGY SAVED: /Intelligence/maps/network_[TIMESTAMP].json
```
