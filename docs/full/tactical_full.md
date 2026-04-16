# Tactical — Full Module Reference
**Category:** `tactical` | **Total Modules:** 5 | *Every module individually documented*

---

## tactical_janus_ai — Janus AI Autonomous Operator

**Platform:** all

**What it does:** The Janus AI is the central intelligence of JanusOS — powered by the Hailo-8 accelerator. Set a mission objective and the AI automatically selects, sequences, and executes the appropriate modules.

**How to run:**
1. Tactical → janus_ai
2. State your mission objective in natural language
3. Janus AI proposes a module sequence
4. Approve or modify, then execute

**Expected output:**
```
JANUS AI: ONLINE
MODEL: Singularity-7B (Hailo-8)
OBJECTIVE: [entered]
PROPOSED SEQUENCE:
  1. 01_identity
  2. 33_stealth_mode
  3. [AI selected modules...]
AWAITING APPROVAL...
```

**Note:** Janus AI learns from your operational patterns — improves module recommendations over time.

---

## tactical_ghost_net — Ghost-Net Mesh Commander

**Platform:** all

**What it does:** Manages the P2P Ghost-Net mesh network between multiple Pandora units. Syncs intelligence, coordinates operations, and enables silent unit-to-unit communication.

**How to run:**
1. Tactical → ghost_net
2. Discover nearby Pandora units (automatic)
3. Form mesh network
4. Select sync: Intelligence / Commands / Both

**Expected output:**
```
GHOST-NET: ONLINE
UNITS DISCOVERED: 3
MESH FORMED: YES
ENCRYPTION: CRYSTALS-Kyber-1024
INTEL SYNCED: YES
COMMAND RELAY: ACTIVE
```

**Note:** Ghost-Net operates on sub-GHz frequencies — range up to 2km line-of-sight between units.

---

## tactical_stealth_boot — Stealth Boot Manager

**Platform:** all

**What it does:** Manages JanusOS stealth boot options — boots to a clean decoy OS, activates Chameleon Mode, or configures secure boot parameters. Panic wipe trigger also managed here.

**How to run:**
1. Tactical → stealth_boot
2. Select boot profile: Janus / Decoy / Chameleon
3. Configure panic wipe trigger conditions
4. Apply and reboot if needed

**Expected output:**
```
STEALTH BOOT: CONFIGURING
CURRENT PROFILE: JANUS
DECOY OS: READY (Ubuntu 22.04)
CHAMELEON: STANDBY
PANIC WIPE: ARMED (wrong PIN x5)
STATUS: CONFIGURED
```

**Note:** Decoy OS is a fully functional Ubuntu install — indistinguishable from a normal laptop to casual inspection.

---

## tactical_network_cartographer — Network Cartographer

**Platform:** network

**What it does:** Builds a comprehensive network topology map of the current environment — automatically discovers all devices, services, and relationships using passive and active techniques.

**How to run:**
1. Tactical → network_cartographer
2. Select scope: Local LAN / Extended / Full sweep
3. Module runs passive scan, then active enumeration
4. Interactive network map generated

**Expected output:**
```
NETWORK CARTOGRAPHER: RUNNING
PASSIVE SCAN: COMPLETE
ACTIVE ENUM: RUNNING
HOSTS FOUND: 45
SERVICES: 234
MESSAGE: MAP BUILT
SAVED: /Evidence/network/topology_map.html
```

**Note:** Interactive HTML map shows all hosts, connections, and services — click any node for details.

---

## tactical_deep_signal — Deep Signal Analyzer

**Platform:** pandora_titan/omega

**What it does:** Advanced signal analysis module combining SDR hardware with Hailo-8 AI for deep protocol decoding, signal origin estimation, and anomaly detection in the radio environment.

**How to run:**
1. Tactical → deep_signal
2. Select frequency range or specific signal
3. AI analysis runs automatically
4. Protocol decoded and signal origin estimated

**Expected output:**
```
DEEP SIGNAL ANALYZER: RUNNING
FREQUENCY: [input]
AI: HAILO-8 ACTIVE
PROTOCOL: [decoded]
ORIGIN ESTIMATE: [bearing and distance]
ANOMALY: [if detected]
SAVED: /Evidence/sigint/deep_analysis.json
```

**Note:** Origin estimation uses direction finding and signal propagation modeling for best accuracy.

---

