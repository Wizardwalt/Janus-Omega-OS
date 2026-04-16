# Offensive — Module How-To Guide
**Category:** `offensive` | **Module Count:** 3

The Offensive category contains three core attack modules that serve as the foundation of any active operation: ADB shell command execution, shell command pipeline, and target enumeration. These are the building blocks that other modules call internally.

---

## off_001 — ADB Shell Executor

**What it does:** Direct ADB shell command execution against a connected Android device. Accepts any shell command and runs it with the privileges of the ADB session (root if device is rooted).

**When to use:** Running custom one-off commands not covered by other modules, or chaining commands from other modules.

**How to run:**
1. Janus TUI → **Offensive** → **ADB Shell Executor**
2. Type the shell command in the input field
3. Press Enter to execute
4. Output displayed in real time

**Example commands:**
```bash
# Dump the SMS database
content query --uri content://sms/inbox

# Extract installed apps
pm list packages -3

# Pull a file
adb pull /data/data/com.target.app/databases/main.db
```

**Expected output:**
```
ADB SHELL EXECUTOR: READY
COMMAND: [your command]
OUTPUT:
[command output displayed here]
EXIT CODE: 0
```

---

## off_002 — Shell Pipeline

**What it does:** Executes multi-step shell pipelines on the connected device — allowing complex operations like grep filtering, data transformation, and file chaining in a single command sequence.

**How to run:**
1. Janus TUI → **Offensive** → **Shell Pipeline**
2. Build your pipeline using the step builder (each step is one command)
3. Chain up to 16 steps with pipe (`|`) or redirect (`>`) operators
4. Execute and review output at each stage

**Example pipeline:**
```bash
cat /data/data/com.whatsapp/databases/msgstore.db | strings | grep -E "[0-9]{10}" | sort | uniq
```

**Expected output:**
```
PIPELINE: 4 STEPS
STEP 1: READ msgstore.db [OK]
STEP 2: strings [OK - 45,231 strings]
STEP 3: grep phone numbers [OK - 127 matches]
STEP 4: sort | uniq [OK - 43 unique numbers]
OUTPUT SAVED: /Evidence/pipeline_output.txt
```

---

## off_003 — Target Enumerator

**What it does:** Performs a comprehensive enumeration of the connected device — collecting device model, Android version, security patch level, installed apps, accounts, network interfaces, running processes, and open ports in one automated pass. This is always the recommended first step of any operation.

**How to run:**
1. Connect target device
2. Janus TUI → **Offensive** → **Target Enumerator**
3. No configuration needed — runs automatically
4. Full report generated in 30–60 seconds

**Expected output:**
```
TARGET ENUMERATOR: RUNNING
DEVICE: Samsung Galaxy S23 Ultra
ANDROID: 14 | SECURITY PATCH: 2024-01
BOOTLOADER: Locked | ROOT: No
INSTALLED APPS: 127
ACCOUNTS: Google (3), Samsung (1)
NETWORK: wlan0 (192.168.1.45), rmnet0
PROCESSES: 287 running
OPEN PORTS: 5555 (ADB)
REPORT: /Evidence/enum_[DEVICE]_[DATE].json
```

**Tip:** Always run Target Enumerator before any other offensive module — the report tells you which attack paths are available.
