# Forensics — Module How-To Guide
**Category:** `forensics` | **Module Count:** 152

The Forensics category covers digital evidence collection, data recovery, artifact reconstruction, and stealth operations. These modules work on both Android and iOS targets connected via ADB or libimobiledevice.

---

## Named Modules

### data_carver.lua — WAL & Journal Analysis

**What it does:** Scans for SQLite WAL (Write-Ahead Log) files and database journals on the target device, then reconstructs deleted records including SMS messages, call logs, and app data.

**When to use:** Target has deleted messages or call history you need to recover.

**How to run:**
1. Connect target device (ADB for Android, libimobiledevice for iOS)
2. Janus TUI → **Forensics** → **Data Carver**
3. Select database targets: All / SMS / Calls / App-specific
4. Module scans and outputs recovered records to `Evidence/` folder

**Expected output:**
```
SCANNING FOR SQLITE JOURNALS...
RECOVERING DELETED SMS/CALLS...
FOUND: 247 WAL ENTRIES
RECONSTRUCTED: 89 DELETED RECORDS
RECONSTRUCTION COMPLETE
```

---

### stealth_boot.lua — Decoy OS Controller

**What it does:** Configures a decoy OS skin on the device. When triggered (e.g., wrong PIN, specific gesture), switches the display to a harmless-looking interface while JanusOS continues running in the background.

**When to use:** Operational security — prevent discovery if device is inspected.

**How to run:**
1. Janus TUI → **Forensics** → **Stealth Boot**
2. Choose decoy skin: Calculator / Standard Android / Medical Monitor
3. Set trigger: Wrong PIN (3x) / Volume button combo / Scheduled time
4. Arm the module

**Expected output:**
```
CONFIGURING STEALTH-BOOT...
DECOY OS ARMED
TRIGGER: WRONG PIN x3
SKIN: CALCULATOR MODE
STATUS: ACTIVE
```

---

## Numbered Modules (for_001 through for_150)

150 forensic modules covering the full evidence collection and analysis pipeline.

**How to run any numbered module:**
1. Janus TUI → **Forensics** → scroll or type module number
2. Press Enter to execute
3. All evidence is saved to `/Evidence/` on the Pandora unit

### Module Index by Function

| Range | Focus Area |
|---|---|
| for_001 – for_020 | File system imaging and disk acquisition |
| for_021 – for_040 | Database recovery (SQLite, SharedPrefs, Keychain) |
| for_041 – for_060 | Communication forensics (SMS, calls, emails, chat) |
| for_061 – for_080 | App data extraction (social media, banking, cloud) |
| for_081 – for_100 | Photo/video metadata and EXIF analysis |
| for_101 – for_120 | Network artifact recovery (browser history, DNS cache) |
| for_121 – for_140 | Memory forensics and RAM analysis |
| for_141 – for_150 | Timeline reconstruction and report generation |

---

## General Tips

- Always run `for_001` first to create a full filesystem image before running other modules
- `for_141–150` generate structured reports automatically — use these for final output
- Evidence is hash-verified (SHA-256) after collection for chain-of-custody integrity
- iOS targets require the device to be in Trust state before forensic modules will run
