# Mobile Offense — Module How-To Guide
**Category:** `mobile_offense` | **Module Count:** 150

The Mobile Offense category covers Android and iOS offensive operations: FRP bypass, bloatware removal, root detection, app modification, and deep device access. Requires ADB for Android targets.

---

## How to Run Any Mobile Offense Module

1. Connect target Android device with USB debugging enabled
2. Confirm ADB connection: device should appear in the Janus TUI status bar
3. Janus TUI → **Mobile Offense**
4. Select module by name or number
5. Follow prompts (target app package, device model, etc.)

---

## Key Named Modules (root plugins cross-reference)

### FRP Bypass (mo_001–020 range)
Bypasses Factory Reset Protection via intent injection and YouTube/Maps exploit chain.

**How to run:**
1. Mobile Offense → **FRP Bypass**
2. Confirm device is at FRP lock screen
3. Select exploit vector: YouTube / Maps / Settings / OEM-specific
4. Module launches browser intent chain

```
FRP BYPASS SEQUENCE INITIATED
[1] YOUTUBE INJECT: SENT
[2] MAPS INJECT: SENT
[3] SETTINGS ACCESS: GAINED
FRP: BYPASSED
```

### Bloatware Matrix (mo_021–040 range)
Mass uninstall/disable of 150+ carrier and OEM bloatware packages.

**How to run:**
1. Mobile Offense → **Bloatware Matrix**
2. Select profile: Samsung / Xiaomi / OnePlus / Generic Carrier / All
3. Review package list, confirm
4. Module runs `pm uninstall -k --user 0` for each target

```
BLOATWARE MATRIX: RUNNING
TARGET: 150 PACKAGES
REMOVED: com.facebook.katana [OK]
REMOVED: com.samsung.bixby [OK]
...
COMPLETE: 147/150 REMOVED
```

### Root Dragnet (mo_041–060 range)
Automated root detection and privilege escalation for supported devices.

**How to run:**
1. Mobile Offense → **Root Dragnet**
2. Select method: Magisk / KernelSU / OEM Exploit / ADB Root
3. Module checks device compatibility and applies the appropriate method

```
DRAGNET: SCANNING TARGET
DEVICE: [MODEL]
EXPLOIT PATH: [METHOD]
ROOT: GRANTED
```

### Game Alchemist (mo_061–080 range)
Universal game modifier — injects infinite resources, unlocks premium content.

**How to run:**
1. Mobile Offense → **Game Alchemist**
2. Select target game from installed app list
3. Select modification: Coins / XP / Unlock / No-ads
4. Module patches SharedPreferences XML or memory values

```
GAME ALCHEMIST: TARGETING [APP]
PATCHING: coins value → 9999999
PATCHING: premium_unlocked → true
COMPLETE
```

---

## Module Index by Function

| Range | Focus Area |
|---|---|
| mo_001 – mo_020 | FRP bypass (multi-vendor) |
| mo_021 – mo_040 | Bloatware removal and debloat |
| mo_041 – mo_060 | Root and privilege escalation |
| mo_061 – mo_080 | App modification and game hacking |
| mo_081 – mo_100 | Bootloop repair and recovery |
| mo_101 – mo_120 | App lock bypass and screen unlock |
| mo_121 – mo_140 | APK extraction, decompile, and repack |
| mo_141 – mo_150 | Deep system modification (SELinux, partition) |

---

## Tips

- Enable USB debugging before connecting — some modules can enable it via ADB over TCP if the device is already on the same Wi-Fi
- Bloatware Matrix profile selection matters: Samsung profile removes Bixby, S-Voice, Samsung Pay extras; use Generic for unknown devices
- Root Dragnet will not brick devices — it verifies compatibility before applying any changes
- All mobile offense operations are logged with timestamps to the Black-Box recorder
