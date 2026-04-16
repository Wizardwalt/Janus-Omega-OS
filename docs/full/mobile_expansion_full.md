# Mobile Expansion — Full Module Reference
**Category:** `mobile_expansion` | **Total Modules:** 4 | *Every module individually documented*

---

## mexp_001 — Kernel Intercept

**Platform:** android

**What it does:** Loads a custom kernel module (.ko) that intercepts all system calls at the kernel level — provides Ring-0 visibility into all device operations.

**How to run:**
1. Mobile Expansion → mexp_001
2. Device must be rooted with unlocked bootloader
3. Select kernel module from library
4. Module loaded and system call hooks active

**Expected output:**
```
KERNEL INTERCEPT: LOADING
MODULE: janus_intercept.ko
KERNEL: LOADED
HOOKS: ACTIVE
SYSCALLS INTERCEPTED: ALL
LOG: /Evidence/kernel/syscall_intercept.log
```

**Note:** Kernel module is removed on device reboot — re-deploy after any restart.

---

## mexp_002 — Deep Physical Acquisition

**Platform:** android

**What it does:** Bypasses all Android security to perform a complete physical acquisition — extracts all partitions including encrypted /data using kernel-level decryption key access.

**How to run:**
1. Mobile Expansion → mexp_002
2. Requires mexp_001 kernel intercept active
3. Decryption keys captured from kernel memory
4. Full device image with decrypted data

**Expected output:**
```
DEEP ACQUISITION: RUNNING
KERNEL ACCESS: CONFIRMED
DECRYPTION KEYS: CAPTURED
/DATA: DECRYPTED
IMAGE: COMPLETE
SAVED: /Evidence/deep/full_decrypted.img
```

**Note:** Deep acquisition captures decrypted /data including all app private data — the most complete forensic image.

---

## mexp_003 — Covert Surveillance Suite

**Platform:** android/ios

**What it does:** Deploys a comprehensive covert surveillance package: location tracking, audio capture, camera capture, and communication logging — all operating silently without user notification.

**How to run:**
1. Mobile Expansion → mexp_003
2. Select surveillance components: All / Custom
3. Configure reporting interval and upload endpoint
4. Suite deployed silently

**Expected output:**
```
COVERT SURVEILLANCE: DEPLOYING
LOCATION TRACKING: ACTIVE (60s interval)
AUDIO CAPTURE: ACTIVE (keyword triggered)
CAMERA: ACTIVE (motion triggered)
COMMS LOGGING: ACTIVE
REPORTING: Ghost-Net mesh
```

**Note:** All surveillance data is end-to-end encrypted and reported via Ghost-Net to your Pandora unit.

---

## mexp_004 — Total Device Domination

**Platform:** android

**What it does:** The ultimate mobile control module — establishes persistent, undetectable root access with full system control, remote management, and evidence-grade extraction capability.

**How to run:**
1. Mobile Expansion → mexp_004
2. Run as final step after all other access is established
3. Persistence mechanism installed at multiple levels
4. Remote control endpoint configured

**Expected output:**
```
TOTAL DOMINATION: EXECUTING
PERSISTENCE: BOOTLOADER / KERNEL / SYSTEM / APP
REMOTE CONTROL: ACTIVE
STEALTH: MAXIMUM
EVIDENCE EXTRACTION: READY
STATUS: TOTAL CONTROL ESTABLISHED
```

**Note:** Persistence survives factory reset via bootloader-level implant — deepest persistence available.

---

