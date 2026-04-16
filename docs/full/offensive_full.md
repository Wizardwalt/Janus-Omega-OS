# Offensive — Full Module Reference
**Category:** `offensive` | **Total Modules:** 3 | *Every module individually documented*

---

## off_001 — ADB Shell Executor

**Platform:** android

**What it does:** Direct ADB shell command execution against a connected Android device. Accepts any shell command and runs it with the privileges of the ADB session (root if device is rooted). Foundation of all Android operations.

**How to run:**
1. Offensive → off_001
2. Type shell command in input field
3. Press Enter to execute
4. Output displayed in real time, saved to log

**Expected output:**
```
ADB SHELL EXECUTOR: READY
COMMAND: [your command]
SESSION: root (rooted device)
OUTPUT:
[command output]
EXIT CODE: 0
SAVED: /Evidence/shell/shell_log.txt
```

**Note:** Root shell gives access to all device resources — use carefully to avoid triggering security alerts.

---

## off_002 — Shell Pipeline Engine

**Platform:** android

**What it does:** Executes multi-step shell pipelines on the connected device — allowing complex operations like grep filtering, data transformation, and file chaining in a single command sequence.

**How to run:**
1. Offensive → off_002
2. Build pipeline using step builder
3. Chain up to 16 steps with pipe or redirect operators
4. Execute and review output at each stage

**Expected output:**
```
PIPELINE: 4 STEPS
STEP 1: cat /data/data/com.target.app/databases/main.db [OK]
STEP 2: strings [OK - 45,231 strings]
STEP 3: grep -E '[0-9]{10}' [OK - 127 matches]
STEP 4: sort | uniq [OK - 43 unique]
OUTPUT: /Evidence/pipeline_output.txt
```

**Note:** Save complex pipelines for reuse — documented in /etc/janus/pipelines/.

---

## off_003 — Target Enumerator

**Platform:** android/ios

**What it does:** Comprehensive automatic enumeration of the connected device — collects device model, OS version, security patch, installed apps, accounts, network interfaces, running processes, and open ports in one pass.

**How to run:**
1. Offensive → off_003
2. No configuration needed — runs fully automatically
3. Full report generated in 30-60 seconds
4. Feeds results to all subsequent modules automatically

**Expected output:**
```
TARGET ENUMERATOR: RUNNING
DEVICE: Samsung Galaxy S24 Ultra
ANDROID: 14 | PATCH: 2024-04
BOOTLOADER: Locked | ROOT: Yes (Magisk)
APPS: 142 | ACCOUNTS: Google(2), Samsung(1)
NETWORK: wlan0 (192.168.1.12)
PROCESSES: 312
REPORT: /Evidence/enum_[DEVICE]_[DATE].json
```

**Note:** Always run off_003 first — it provides the baseline intelligence for all subsequent operations.

---

