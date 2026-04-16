# SIGINT — Module How-To Guide
**Category:** `sigint` | **Module Count:** 100

The SIGINT (Signals Intelligence) category covers radio frequency monitoring, cellular interception, sub-GHz analysis, satellite signal processing, and electronic warfare. Requires the Pandora Titan's Hydra Radio Array or an external SDR (Software Defined Radio) dongle connected to the Pandora Omega.

---

## Hardware Requirements

| Module Range | Required Hardware |
|---|---|
| sigint_001–030 | SDR dongle (RTL-SDR / HackRF) or Hydra Radio Array |
| sigint_031–060 | Pandora Titan Hydra Radio Array (5G/LTE capable) |
| sigint_061–080 | High-gain antenna + SDR |
| sigint_081–100 | Pandora Titan full suite + Singularity AI module |

---

## How to Run Any SIGINT Module

1. Ensure radio hardware is detected — check status bar in Janus TUI
2. Janus TUI → **SIGINT**
3. Select module number (sigint_001 through sigint_100)
4. Set frequency range or target band when prompted
5. Monitor the live waterfall display in the TUI
6. Captured signals saved to `/Intelligence/sigint/` as `.iq` files

---

## Module Index by Function

| Range | Focus Area |
|---|---|
| sigint_001 – sigint_010 | FM/AM broadcast monitoring |
| sigint_011 – sigint_020 | Sub-GHz analysis (433MHz, 868MHz, 915MHz) |
| sigint_021 – sigint_030 | Bluetooth (BLE) signal capture and analysis |
| sigint_031 – sigint_040 | Cellular monitoring: GSM/UMTS/LTE scanning |
| sigint_041 – sigint_050 | Wi-Fi spectrum analysis and hidden SSID detection |
| sigint_051 – sigint_060 | DECT phone interception |
| sigint_061 – sigint_070 | Pager and legacy protocol decoding |
| sigint_071 – sigint_080 | LoRaWAN and IoT protocol analysis |
| sigint_081 – sigint_090 | Satellite downlink monitoring |
| sigint_091 – sigint_100 | AI-assisted signal classification (Singularity) |

---

## Key Workflows

### Cellular Scanner
1. SIGINT → sigint_031
2. Select band: GSM 900 / GSM 1800 / LTE / 5G NR
3. Module scans all frequencies in the band
4. Outputs tower map with signal strengths and cell IDs

```
CELLULAR SCANNER: ACTIVE
BAND: LTE 700MHz
TOWERS FOUND: 12
STRONGEST: [Cell ID] -67dBm
SAVED: /Intelligence/sigint/cell_scan.json
```

### Sub-GHz Replay Attack
1. SIGINT → sigint_011 (capture) then sigint_012 (replay)
2. Capture target remote/key fob signal
3. Review captured waveform
4. Run replay module to retransmit

### AI Signal Classification
1. SIGINT → sigint_091
2. Point antenna at unknown signal source
3. Singularity AI analyzes modulation, protocol, and source type
4. Returns classification with confidence score

```
SINGULARITY ANALYSIS: RUNNING
INPUT: CAPTURED IQ SAMPLES
CLASSIFICATION: LTE CAT-M1 (IoT)
CONFIDENCE: 97.3%
SOURCE: UTILITY SMART METER
```

---

## Tips

- sigint_001 is a good starting point — it does a broad spectrum scan to show you what's active in the area
- The Black-Box flight recorder automatically captures all frequency environment changes 24/7 on the Pandora Titan, even without running a specific SIGINT module
- sigint_091–100 use the Hailo-8 AI accelerator — ensure it's enabled in System Settings for real-time analysis
- Combine cellular scanner output with OSINT Oracle for tower owner identification
