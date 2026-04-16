# Mobile Expansion — Module How-To Guide
**Category:** `mobile_expansion` | **Module Count:** 4

Mobile Expansion extends the core mobile offense capabilities with deep-access operations: system call interception, forensic acquisition, remote surveillance, and cross-device covert monitoring.

---

## How These Modules Work

Mobile Expansion modules operate at a deeper level than the standard Mobile Offense category — they interact with kernel-level interfaces, exploit ADB root privileges, or use libimobiledevice's advanced APIs for iOS. All four require either a rooted Android device or an iOS device in developer/jailbroken mode.

---

## Module Overview

### me_001 — Kernel Call Interceptor
**What it does:** Hooks into Android's Binder IPC system to intercept and log all inter-process communication. Captures app-to-app calls, permission checks, and system service requests in real time.

**How to run:**
1. Ensure device is rooted (ADB root confirmed in status bar)
2. Janus TUI → **Mobile Expansion** → **Kernel Call Interceptor**
3. Set filter: All calls / Target app only / System services only
4. Monitor the live IPC stream in the log pane

```
KERNEL IPC MONITOR: ACTIVE
TARGET: ALL PROCESSES
INTERCEPTED: com.banking.app → android.permission.READ_CONTACTS
INTERCEPTED: com.messaging.app → SMS_SEND
LOG: /Evidence/ipc_log.txt
```

---

### me_002 — Deep Acquisition
**What it does:** Performs a full logical and physical acquisition of the target device — file system image, RAM dump, partition table, and encrypted keystore — in one automated pass.

**How to run:**
1. Janus TUI → **Mobile Expansion** → **Deep Acquisition**
2. Select acquisition type: Logical / Physical / Full
3. Set output location (Pandora NVMe or external)
4. Estimated time shown before starting — confirm to proceed

```
DEEP ACQUISITION: STARTING
TYPE: FULL (LOGICAL + PHYSICAL)
DEVICE STORAGE: 64GB
ETA: ~18 minutes
PROGRESS: [=========>  ] 72%
HASH (SHA-256): [COMPUTED ON COMPLETION]
SAVED: /Evidence/acquisition/[DEVICE]_[DATE].img
```

---

### me_003 — Covert Surveillance
**What it does:** Installs a lightweight background monitor on the target device that silently captures: GPS location (live), microphone (on-keyword), camera (on-trigger), and all incoming/outgoing messages. Exfiltrates via encrypted channel.

**How to run:**
1. Janus TUI → **Mobile Expansion** → **Covert Surveillance**
2. Configure collection: Location / Audio / Camera / Messages / All
3. Set exfil method: USB pull / Wi-Fi covert / Cellular
4. Deploy — module installs silently with no app icon

```
COVERT SURVEILLANCE: DEPLOYING
AGENT SIZE: 47KB
PERMISSIONS: ACQUIRED VIA ROOT
TRIGGERS: KEYWORD [configured] / SCHEDULED
EXFIL: ENCRYPTED VIA COVERT CHANNEL
STATUS: ACTIVE (INVISIBLE)
```

---

### me_004 — Cross-Device Bridge
**What it does:** Creates a covert data bridge between two target devices on the same network or via Bluetooth proximity — silently syncing data between them through the Pandora unit as a relay.

**How to run:**
1. Ensure both target devices are connected or in range
2. Janus TUI → **Mobile Expansion** → **Cross-Device Bridge**
3. Select source device and destination device
4. Choose data types to bridge: Files / Messages / Contacts / Full mirror

```
CROSS-DEVICE BRIDGE: ACTIVE
SOURCE: [DEVICE A]
DESTINATION: [DEVICE B]
RELAY: Pandora Titan
TRANSFER RATE: 2.4 MB/s
MIRRORING: COMPLETE
```
