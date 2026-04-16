# Titan Exclusive — Module How-To Guide
**Category:** `titan_exclusive` | **Module Count:** 104

Titan Exclusive modules are only available on the Pandora Titan. They leverage the Titan's unique hardware: the AR-HUD display, Neural-Sync haptic interface, CBRN sensor suite, Kinetic Harvester power system, and the integrated M.2 AI GPU (Hailo-8).

---

## Hardware Prerequisites

All Titan Exclusive modules require the **Pandora Titan** hardware platform:
- 7-inch 21:9 ultrawide rugged display
- Hydra Radio Array (5G/LTE + Wi-Fi 6E + BT 5.3)
- Hailo-8 AI accelerator (M.2 slot)
- AR-HUD overlay system
- CBRN sensor array
- Kinetic Harvester power system
- Neural-Sync haptic interface

---

## Named Modules

### ar_hud_threat.lua — AR-HUD Real-Time Threat Highlighting

**What it does:** Activates the AR-HUD overlay and processes the camera feed in real time through the Hailo-8 AI to detect and highlight threats, persons of interest, vehicles, and tactical paths.

**How to run:**
1. Titan TUI → **Titan Exclusive** → **AR-HUD Threat**
2. Select detection mode: Persons / Vehicles / Devices / Full Spectrum
3. Optionally load a target photo for person-of-interest tracking
4. AR overlay activates on the Titan display

**Expected output:**
```
INITIATING AR-HUD OVERLAY...
SCANNING FIELD OF VIEW...
TARGETS DETECTED: 3 | THREAT LEVEL: LOW
HIGHLIGHTING OPTIMAL TACTICAL PATH...
AI CONFIDENCE: 94.7%
```

**Controls:** Rotary dial adjusts overlay opacity. Volume buttons cycle between detection modes.

---

### cbrn_detector.lua — Environmental Hazard Detection

**What it does:** Activates the integrated CBRN (Chemical, Biological, Radiological, Nuclear) sensor suite and continuously monitors the environment for hazardous agents.

**How to run:**
1. Titan TUI → **Titan Exclusive** → **CBRN Detector**
2. Module starts automatically — no configuration needed
3. Alerts are delivered via haptic and audio if a threat is detected
4. Readings logged continuously to the Black-Box recorder

**Expected output:**
```
CBRN SENSORS: ONLINE
AIR QUALITY: 99% | RADIATION: 0.01μSv/h
VOC LEVEL: 0.02 ppm
BIO-HAZARD SCAN: NEGATIVE
STATUS: ENVIRONMENT SECURE
```

**Thresholds:** Radiation alert at >1μSv/h. VOC alert at >1ppm. Bio-hazard alert on any positive detection.

---

### kinetic_harvester.lua — Power Management

**What it does:** Monitors and manages the Kinetic Harvester system which generates power from arm movement. Displays real-time generation rate, battery status, and optimizes power distribution.

**How to run:**
1. Titan TUI → **Titan Exclusive** → **Kinetic Harvester**
2. Module runs as a background daemon — always active
3. Check the status panel for live power readings

**Expected output:**
```
KINETIC HARVESTER: MONITORING...
CURRENT GENERATION: 480mW
BATTERY STATUS: 100% (TRICKLE CHARGE)
POWER SOURCE: MOTION-DERIVED
ESTIMATED RUNTIME: INDEFINITE
```

---

### neural_sync.lua — Haptic Intent Interface

**What it does:** Calibrates the Neural-Sync system which reads haptic intent from the forearm haptic pads and translates physical gestures into TUI commands — allowing hands-free navigation of JanusOS.

**How to run:**
1. Titan TUI → **Titan Exclusive** → **Neural Sync**
2. Follow calibration sequence: flex fingers 1–5 to map gestures
3. System learns your haptic signature over 60 seconds
4. Once calibrated, navigate TUI by haptic intent alone

**Expected output:**
```
LINKING NEURAL INTERFACE...
CALIBRATING HAPTIC FEEDBACK...
GESTURE MAPPING: FINGERS 1-5 ASSIGNED
INTENT SYNC: 98.4% | STATUS: SYNCED
COMMAND OVERRIDE: NEURAL-ONLY MODE ENABLED
```

**Haptic commands:** Single tap = select. Double tap = back. Spread = expand. Pinch = collapse.

---

## Numbered Modules (tit_001 through tit_100)

100 additional Titan-only modules covering advanced hardware operations.

### Module Index by Function

| Range | Focus Area |
|---|---|
| tit_001 – tit_020 | AR-HUD advanced modes (thermal, night vision, spectrum) |
| tit_021 – tit_040 | Neural-Sync advanced gesture programming |
| tit_041 – tit_060 | Chameleon Mode — instant display skin overlay |
| tit_061 – tit_070 | CBRN advanced detection and threat mapping |
| tit_071 – tit_080 | Singularity AI — local offline intelligence |
| tit_081 – tit_090 | Ghost-Net P2P mesh networking between Pandora units |
| tit_091 – tit_100 | Quantum-resistant encryption management |

---

## Tips

- Run `neural_sync.lua` on first boot to calibrate the haptic interface before using any other Titan modules
- Chameleon Mode (tit_041–060) activates instantly via the physical panic button on the Titan chassis — maps to whatever skin you configured
- The AR-HUD draws ~200mW — the Kinetic Harvester fully compensates during normal walking
- Ghost-Net (tit_081–090) creates a private encrypted mesh between all Pandora units in range — ideal for team operations
