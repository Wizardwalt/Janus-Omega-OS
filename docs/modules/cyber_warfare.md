# Cyber Warfare — Module How-To Guide
**Category:** `cyber_warfare` | **Module Count:** 154

The Cyber Warfare category covers offensive digital operations: synthetic identity generation, credential attacks, infrastructure exploitation, and persistent access tools.

---

## Named Modules

### biometric_forge.lua — Synthetic Identity Generation

**What it does:** Generates synthetic biometric signatures (iris patterns, fingerprints, voice prints) to bypass biometric authentication gates.

**How to run:**
1. Janus TUI → **Cyber Warfare** → **Biometric Forge**
2. Select biometric type: Iris / Fingerprint / Voice / All
3. Select target system: Android / iOS / Custom Gatekeeper
4. Module generates and injects the synthetic biometric

**Expected output:**
```
FORGING SYNTHETIC BIOMETRICS...
GENERATING: IRIS / FINGERPRINT / VOICE
BYPASSING GATEKEEPER-X...
STATUS: IDENTITY VALIDATED
```

---

## Numbered Modules (cyb_001 through cyb_153)

These 153 modules cover a full spectrum of cyber warfare tactics. Each is self-contained and can be launched from the TUI module list.

**How to run any numbered module:**
1. Janus TUI → **Cyber Warfare** → type module number or scroll list
2. Press Enter to execute
3. Review output in the log pane

### Module Index by Function

| Range | Focus Area |
|---|---|
| cyb_001 – cyb_020 | Network infiltration and pivot techniques |
| cyb_021 – cyb_040 | Credential harvesting and password attacks |
| cyb_041 – cyb_060 | Persistence mechanisms and rootkit deployment |
| cyb_061 – cyb_080 | Lateral movement and privilege escalation |
| cyb_081 – cyb_100 | Data exfiltration and covert channels |
| cyb_101 – cyb_120 | Anti-forensic measures and log wiping |
| cyb_121 – cyb_140 | Exploit delivery and payload staging |
| cyb_141 – cyb_153 | Command & control infrastructure |

**Common usage pattern:**
```
Janus TUI → Cyber Warfare → Select Module → Execute → Review Logs
```

**All modules report:**
```
EXECUTING CYBER_WARFARE [N]...
STATUS: OPERATIONAL
```

---

## General Tips

- Run `cyb_001` first on any new target to map the attack surface
- Numbered modules chain together — output from one feeds into the next
- All activity is logged to the Black-Box flight recorder automatically
- Use **Anti-Forensic** modules (cyb_101–120) after operations to clean traces
