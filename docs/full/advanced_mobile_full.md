# Advanced Mobile — Full Module Reference
**Category:** `advanced_mobile` | **Total Modules:** 4 | *Every module individually documented*

---

## adv_001 — Bypass Matrix

**Platform:** android/ios

**What it does:** Comprehensive bypass engine that automatically identifies and defeats all security layers on the target device: biometric, PIN, pattern, FRP, MDM, anti-tamper, and app-level locks.

**How to run:**
1. Advanced Mobile → adv_001
2. Select target device from connected list
3. Bypass Matrix analyzes all security layers
4. Automated bypass sequence executed

**Expected output:**
```
BYPASS MATRIX: RUNNING
SECURITY LAYERS FOUND: 7
  -> Screen lock: PIN
  -> FRP: Active
  -> MDM: Enrolled
  -> Biometric: Fingerprint
BYPASS SEQUENCE: EXECUTING
STATUS: ALL LAYERS DEFEATED
```

**Note:** Bypass Matrix is the fastest way to gain full access — run before any other module.

---

## adv_002 — Ghost Mode

**Platform:** android/ios

**What it does:** Activates complete device invisibility — hides all Janus processes, files, and network connections from device monitoring tools, MDM, and forensic scanners.

**How to run:**
1. Advanced Mobile → adv_002
2. Select stealth level: Partial / Full / Extreme
3. Ghost Mode activated across all layers
4. Verify invisibility with scan test

**Expected output:**
```
GHOST MODE: ACTIVATING
STEALTH LEVEL: FULL
PROCESSES: HIDDEN
FILES: HIDDEN
NETWORK: TUNNELED
MDM: BLIND
STATUS: INVISIBLE
```

**Note:** Extreme Ghost Mode hides from hardware attestation — required for modern MDM systems.

---

## adv_003 — Signal Cloner

**Platform:** pandora_titan

**What it does:** Clones a target device's cellular identity (IMSI/TMSI) — allows a second device to appear as the target on the cellular network.

**How to run:**
1. Advanced Mobile → adv_003
2. Requires Pandora Titan with Hydra Radio Array
3. Capture target's TMSI from GSM/LTE traffic
4. Program cloned identity into test SIM

**Expected output:**
```
SIGNAL CLONER: RUNNING
TARGET TMSI: [captured]
CLONED SIM: PROGRAMMED
NETWORK: REGISTERED AS TARGET
STATUS: CLONE ACTIVE
```

**Note:** Cellular cloning is only possible on 2G/GSM — 3G/4G/5G use mutual authentication that prevents this.

---

## adv_004 — SIM Spoof Engine

**Platform:** pandora_titan

**What it does:** Generates a SIM that presents any IMSI, MSISDN, and carrier identity to the network — useful for identity testing and evasion.

**How to run:**
1. Advanced Mobile → adv_004
2. Enter desired IMSI, MSISDN, and carrier codes
3. Program parameters into programmable SIM
4. Insert and verify registration

**Expected output:**
```
SIM SPOOF: PROGRAMMING
IMSI: [entered]
MSISDN: [entered]
CARRIER: [entered]
SIM: PROGRAMMED
NETWORK: REGISTERED
STATUS: ACTIVE
```

**Note:** Spoofed SIM will route calls and SMS through the specified identity — test with a non-critical call first.

---

