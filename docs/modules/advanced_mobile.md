# Advanced Mobile — Module How-To Guide
**Category:** `advanced_mobile` | **Module Count:** 4

These four modules handle identity-level mobile operations: cloning device identities, hiding from networks, spoofing SIM credentials, and bypassing hardware security layers.

---

## bypass_matrix.lua — Multi-Layer Security Override

**What it does:** Attacks hardware-level security processors (Knox, T2/T3, Secure Boot, FaceID, Fingerprint) and attempts to bypass the device security enclave.

**When to use:** Target device has hardware security enabled and standard bypass tools have failed.

**How to run:**
1. Connect target Android device via ADB or iOS via libimobiledevice
2. From the Janus TUI, navigate to **Advanced Mobile** → **Bypass Matrix**
3. Select target security type: Knox / Secure Boot / Biometric
4. Confirm execution — triple haptic on Pandora Titan

**Expected output:**
```
INITIALIZING BYPASS MATRIX...
SCANNING SECURITY ENCLAVE...
TARGET: T2/T3 Security Processor
BYPASS VECTORS: [JTAG] [VOLTAGE-GLITCH] [COLD-BOOT]
STATUS: ENCLAVE ACCESS GRANTED
```

**Notes:** Requires the Pandora Mk.1 USB Glitcher connected for voltage injection attacks. Software-only mode available for Knox bypass.

---

## ghost_mode.lua — Total Network Invisibility

**What it does:** Blocks all OEM telemetry, carrier location heartbeats, and background beaconing signals. Makes the device appear offline to all monitoring systems.

**When to use:** Operational security — prevent device from being tracked or phoned home during a mission.

**How to run:**
1. Open Janus TUI → **Advanced Mobile** → **Ghost Mode**
2. Select suppression level: Soft (telemetry only) / Hard (all signals) / Total (airplane + spoof)
3. Module runs continuously in background until manually disabled

**Expected output:**
```
ENGAGING GHOST MODE...
BLOCKING: OEM Telemetry
BLOCKING: Carrier Location Heartbeat
BLOCKING: App Analytics Beacons
STATUS: DEVICE IS INVISIBLE
```

**Notes:** Total mode activates airplane + broadcasts a decoy signal on nearby frequencies to confuse tracking infrastructure.

---

## signal_cloner.lua — IMSI/IMEI/MAC Duplication

**What it does:** Reads and clones the target device's IMSI, IMEI, and MAC address, then injects those identifiers into the Pandora Titan for proxy operation — the Titan appears to be the target device on the network.

**When to use:** Network surveillance, tracking, or when you need to operate as another device on the carrier network.

**How to run:**
1. Janus TUI → **Advanced Mobile** → **Signal Cloner**
2. Bring the Pandora Titan within 2m of target device (or connect via ADB)
3. Run clone sequence — takes 30–60 seconds
4. Confirm cloned identity is active in the status panel

**Expected output:**
```
CLONING DEVICE IDENTITY...
IMSI CAPTURED: [ENCRYPTED]
IMEI CAPTURED: [ENCRYPTED]
MAC ADDRESS: CLONED
TITAN IDENTITY: MIRRORED
STATUS: PROXY ACTIVE
```

**Notes:** Requires the Hydra Radio Array on the Pandora Titan for over-the-air IMSI capture. Wired ADB mode is faster and more reliable.

---

## sim_spoof.lua — Virtual Subscriber Identity

**What it does:** Injects a virtual SIM credential set into the modem, allowing network authentication under a ghost subscriber identity with no physical SIM required.

**When to use:** Operating without a SIM, testing carrier authentication, or maintaining a disposable network identity.

**How to run:**
1. Janus TUI → **Advanced Mobile** → **SIM Spoof**
2. Choose identity type: Ghost (random) / Cloned (from signal_cloner) / Custom
3. Enter custom ICCID/IMSI if using custom mode
4. Module patches the modem firmware temporarily

**Expected output:**
```
INJECTING VIRTUAL SIM...
CREDENTIALS: [GHOST-SUBSCRIBER]
NETWORK AUTH: SUCCESSFUL
CARRIER: REGISTERED
DATA: ACTIVE
```

**Notes:** Virtual SIM persists until reboot or manual reset. Combine with Ghost Mode for full anonymity.
