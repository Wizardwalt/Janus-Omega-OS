# SIGINT — Full Module Reference
**Category:** `sigint` | **Total Modules:** 100 | *Every module individually documented*

---

## sigint_001 — Wideband Spectrum Scanner

**Platform:** pandora_titan/omega

**What it does:** Performs a full wideband spectrum scan from 70MHz to 6GHz using the integrated SDR hardware. Visualizes signal density and identifies active frequencies.

**How to run:**
1. SIGINT → sigint_001
2. Select scan range: Full / Custom band
3. Set resolution bandwidth: 25kHz / 100kHz / 1MHz
4. Scan runs and waterfall display activates

**Expected output:**
```
SPECTRUM SCAN: RUNNING
RANGE: 70MHz - 6GHz
SCAN SPEED: 4 GHz/sec
ACTIVE SIGNALS: 234
STRONGEST: 2.4GHz (-45dBm)
SAVED: /Evidence/sigint/spectrum.csv
```

**Note:** Full scan takes ~2 seconds per pass — run continuously for dynamic environment monitoring.

---

## sigint_002 — Signal Classification Engine

**Platform:** pandora_titan

**What it does:** Classifies detected signals by modulation type, bandwidth, and protocol using the Hailo-8 AI accelerator.

**How to run:**
1. SIGINT → sigint_002
2. Requires sigint_001 active scan
3. AI classifies each active signal in real time
4. Unknown signals flagged for manual analysis

**Expected output:**
```
SIGNAL CLASSIFIER: RUNNING
SIGNALS BEING CLASSIFIED: 234
WI-FI 2.4GHz: 45
BLUETOOTH: 23
GSM 900: 12
LTE B3: 8
UNKNOWN: 3 (FLAGGED)
SAVED: /Evidence/sigint/classifications.json
```

**Note:** Unknown signals are high priority — investigate with sigint_003 for deeper analysis.

---

## sigint_003 — Deep Signal Demodulation

**Platform:** pandora_titan/omega

**What it does:** Demodulates and decodes a target signal — supports AM, FM, SSB, CW, FSK, PSK, QAM, and custom waveforms.

**How to run:**
1. SIGINT → sigint_003
2. Select signal from spectrum view or enter frequency manually
3. Select modulation type or let AI detect
4. Demodulated audio/data output

**Expected output:**
```
SIGNAL DEMODULATION: RUNNING
FREQUENCY: [input]
MODULATION: AUTO-DETECTED: FM
DEMODULATED: AUDIO STREAM
RECORDING: /Evidence/sigint/signal_[freq].wav
```

**Note:** AI modulation detection works for most common signal types — for exotic signals, try manual mode.

---

## sigint_004 — GSM Cell Tower Scanner

**Platform:** pandora_titan

**What it does:** Scans for GSM 850/900/1800/1900 MHz base stations and decodes broadcast control channel (BCCH) information.

**How to run:**
1. SIGINT → sigint_004
2. Select GSM band(s) to scan
3. Module locks to each active ARFCN
4. Cell identity, LAC, MCC, MNC extracted

**Expected output:**
```
GSM SCAN: RUNNING
BANDS: 850/900/1800/1900
CELLS FOUND: 34
STRONGEST: MCC:310 MNC:410 LAC:1234 CID:56789
FREQUENCY: 947.8 MHz ARFCN:56
SAVED: /Evidence/sigint/gsm_cells.json
```

**Note:** Cell ID can be resolved to physical location using OpenCellID database.

---

## sigint_005 — LTE/4G Network Analysis

**Platform:** pandora_titan

**What it does:** Analyzes LTE networks: detects base stations, decodes system information blocks (SIBs), and monitors downlink traffic.

**How to run:**
1. SIGINT → sigint_005
2. Select LTE bands to scan
3. Module locks to detected eNodeBs
4. System information decoded and logged

**Expected output:**
```
LTE ANALYSIS: RUNNING
BANDS: B2, B4, B12, B66
eNODEBs: 8
STRONGEST: EARFCN:2300 PCI:45 eNB-ID:12345
SYSTEM INFO: SIB1, SIB2, SIB3 DECODED
SAVED: /Evidence/sigint/lte_cells.json
```

**Note:** LTE eNodeB ID uniquely identifies each base station — use for tower tracking.

---

## sigint_006 — 5G NR Network Analysis

**Platform:** pandora_titan

**What it does:** Analyzes 5G NR networks in sub-6GHz bands: detects gNBs, decodes MIB/SIB, and monitors control channel.

**How to run:**
1. SIGINT → sigint_006
2. Select 5G NR bands to scan
3. Synchronization signals detected and decoded
4. Network configuration extracted

**Expected output:**
```
5G NR ANALYSIS: RUNNING
BANDS: n77, n78, n79
gNBs: 3
MIB DECODED: SFN, DL Bandwidth, SSB
NSA/SA: NSA detected
SAVED: /Evidence/sigint/5g_cells.json
```

**Note:** 5G NSA (Non-Standalone) still uses 4G LTE for control — often easier to intercept.

---

## sigint_007 — IMSI Catcher Detector

**Platform:** pandora_titan

**What it does:** Detects fake base stations (IMSI catchers/Stingrays) by monitoring for suspicious cell behavior: low tower ID, forced 2G downgrade, missing encryption.

**How to run:**
1. SIGINT → sigint_007
2. Module runs continuously in background
3. All nearby cells analyzed for rogue indicators
4. Alert triggered on suspected IMSI catcher

**Expected output:**
```
IMSI CATCHER DETECT: MONITORING
CELLS MONITORED: 34
SUSPICIOUS: 1 CELL
  -> FORCED 2G DOWNGRADE
  -> ENCRYPTION DISABLED
  -> UNKNOWN CID
ALERT: POSSIBLE STINGRAY DETECTED
SAVED: /Evidence/sigint/imsi_alert.json
```

**Note:** Multiple indicators = high confidence IMSI catcher. Single indicator = investigate further.

---

## sigint_008 — SS7 Protocol Monitor

**Platform:** pandora_titan

**What it does:** Monitors SS7 signaling traffic (where accessible) for location requests, call intercept, and SMS interception commands.

**How to run:**
1. SIGINT → sigint_008
2. Requires access to SS7 link (carrier-grade hardware)
3. Module captures and decodes SS7 messages
4. Location requests and intercept commands flagged

**Expected output:**
```
SS7 MONITOR: RUNNING
SS7 LINK: CONNECTED
MESSAGES/SEC: 1,204
LOCATION REQUESTS: 23
INTERCEPT COMMANDS: 3
SAVED: /Evidence/sigint/ss7_log.json
```

**Note:** SS7 monitoring requires carrier-level hardware access — Pandora Titan Hydra Radio Array supports this.

---

## sigint_009 — Bluetooth Passive Scanner

**Platform:** pandora_titan/omega

**What it does:** Passively scans for all Bluetooth classic and BLE devices in range without transmitting any signals.

**How to run:**
1. SIGINT → sigint_009
2. Set scan duration: 60s / 5min / 15min / Continuous
3. All BT/BLE advertisements captured
4. Device database built with addresses, names, RSSI

**Expected output:**
```
BT PASSIVE SCAN: RUNNING
DURATION: 5 MINUTES
DEVICES FOUND: 67
BLE: 45 | BT CLASSIC: 22
VENDOR RESOLVED: 61/67
SAVED: /Evidence/sigint/bt_devices.json
```

**Note:** Passive BLE scanning is undetectable — no signals transmitted, 100% covert.

---

## sigint_010 — Wi-Fi Passive Monitor

**Platform:** pandora_titan/omega

**What it does:** Passively monitors all Wi-Fi channels in monitor mode — captures probe requests, beacons, and association traffic without transmitting.

**How to run:**
1. SIGINT → sigint_010
2. Select channel hopping mode: All / 2.4GHz / 5GHz / 6GHz
3. Set capture duration
4. All traffic captured to pcap

**Expected output:**
```
WI-FI PASSIVE MONITOR: RUNNING
MODE: MONITOR (all channels)
PACKETS/SEC: 1,204
APPs SEEN: 89
CLIENTS: 234
PROBE REQUESTS: 445
SAVED: /Evidence/sigint/wifi_capture.pcap
```

**Note:** Probe requests reveal the SSIDs of networks a device has previously connected to — even when not connected to any network.

---

## sigint_011 — Wi-Fi Client Tracker

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes wi-fi client tracker signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_011
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 011: RUNNING
MODULE: WI-FI CLIENT TRACKER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_011_results.json
```

**Note:** Use Singularity AI with sigint_011 output for automated signal classification.

---

## sigint_012 — Device Movement Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes device movement monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_012
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 012: RUNNING
MODULE: DEVICE MOVEMENT MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_012_results.json
```

**Note:** Use Singularity AI with sigint_012 output for automated signal classification.

---

## sigint_013 — RF Fingerprinting

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes rf fingerprinting signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_013
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 013: RUNNING
MODULE: RF FINGERPRINTING
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_013_results.json
```

**Note:** Use Singularity AI with sigint_013 output for automated signal classification.

---

## sigint_014 — Signal Strength Triangulation

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes signal strength triangulation signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_014
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 014: RUNNING
MODULE: SIGNAL STRENGTH TRIANGULATION
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_014_results.json
```

**Note:** Use Singularity AI with sigint_014 output for automated signal classification.

---

## sigint_015 — Time Difference of Arrival (TDoA)

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes time difference of arrival (tdoa) signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_015
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 015: RUNNING
MODULE: TIME DIFFERENCE OF ARRIVAL (TDOA)
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_015_results.json
```

**Note:** Use Singularity AI with sigint_015 output for automated signal classification.

---

## sigint_016 — Angle of Arrival Analysis

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes angle of arrival analysis signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_016
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 016: RUNNING
MODULE: ANGLE OF ARRIVAL ANALYSIS
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_016_results.json
```

**Note:** Use Singularity AI with sigint_016 output for automated signal classification.

---

## sigint_017 — Direction Finding

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes direction finding signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_017
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 017: RUNNING
MODULE: DIRECTION FINDING
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_017_results.json
```

**Note:** Use Singularity AI with sigint_017 output for automated signal classification.

---

## sigint_018 — Mobile DF Hunt Mode

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes mobile df hunt mode signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_018
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 018: RUNNING
MODULE: MOBILE DF HUNT MODE
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_018_results.json
```

**Note:** Use Singularity AI with sigint_018 output for automated signal classification.

---

## sigint_019 — Radio Frequency Map Builder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes radio frequency map builder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_019
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 019: RUNNING
MODULE: RADIO FREQUENCY MAP BUILDER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_019_results.json
```

**Note:** Use Singularity AI with sigint_019 output for automated signal classification.

---

## sigint_020 — Frequency Coordination Analysis

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes frequency coordination analysis signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_020
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 020: RUNNING
MODULE: FREQUENCY COORDINATION ANALYSIS
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_020_results.json
```

**Note:** Use Singularity AI with sigint_020 output for automated signal classification.

---

## sigint_021 — POCSAG Pager Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes pocsag pager decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_021
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 021: RUNNING
MODULE: POCSAG PAGER DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_021_results.json
```

**Note:** Use Singularity AI with sigint_021 output for automated signal classification.

---

## sigint_022 — FLEX Pager Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes flex pager decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_022
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 022: RUNNING
MODULE: FLEX PAGER DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_022_results.json
```

**Note:** Use Singularity AI with sigint_022 output for automated signal classification.

---

## sigint_023 — TETRA Trunked Radio Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes tetra trunked radio monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_023
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 023: RUNNING
MODULE: TETRA TRUNKED RADIO MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_023_results.json
```

**Note:** Use Singularity AI with sigint_023 output for automated signal classification.

---

## sigint_024 — P25 Digital Radio Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes p25 digital radio decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_024
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 024: RUNNING
MODULE: P25 DIGITAL RADIO DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_024_results.json
```

**Note:** Use Singularity AI with sigint_024 output for automated signal classification.

---

## sigint_025 — DMR Digital Radio Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes dmr digital radio decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_025
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 025: RUNNING
MODULE: DMR DIGITAL RADIO DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_025_results.json
```

**Note:** Use Singularity AI with sigint_025 output for automated signal classification.

---

## sigint_026 — D-STAR Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes d-star decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_026
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 026: RUNNING
MODULE: D-STAR DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_026_results.json
```

**Note:** Use Singularity AI with sigint_026 output for automated signal classification.

---

## sigint_027 — System Fusion Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes system fusion decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_027
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 027: RUNNING
MODULE: SYSTEM FUSION DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_027_results.json
```

**Note:** Use Singularity AI with sigint_027 output for automated signal classification.

---

## sigint_028 — NXDN Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes nxdn decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_028
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 028: RUNNING
MODULE: NXDN DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_028_results.json
```

**Note:** Use Singularity AI with sigint_028 output for automated signal classification.

---

## sigint_029 — APCO-25 Phase 2 Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes apco-25 phase 2 decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_029
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 029: RUNNING
MODULE: APCO-25 PHASE 2 DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_029_results.json
```

**Note:** Use Singularity AI with sigint_029 output for automated signal classification.

---

## sigint_030 — Analog Voice Recorder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes analog voice recorder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_030
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 030: RUNNING
MODULE: ANALOG VOICE RECORDER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_030_results.json
```

**Note:** Use Singularity AI with sigint_030 output for automated signal classification.

---

## sigint_031 — Digital Voice Recorder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes digital voice recorder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_031
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 031: RUNNING
MODULE: DIGITAL VOICE RECORDER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_031_results.json
```

**Note:** Use Singularity AI with sigint_031 output for automated signal classification.

---

## sigint_032 — Aircraft ADS-B Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes aircraft ads-b monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_032
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 032: RUNNING
MODULE: AIRCRAFT ADS-B MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_032_results.json
```

**Note:** Use Singularity AI with sigint_032 output for automated signal classification.

---

## sigint_033 — Mode-S Transponder Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes mode-s transponder decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_033
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 033: RUNNING
MODULE: MODE-S TRANSPONDER DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_033_results.json
```

**Note:** Use Singularity AI with sigint_033 output for automated signal classification.

---

## sigint_034 — TCAS Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes tcas monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_034
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 034: RUNNING
MODULE: TCAS MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_034_results.json
```

**Note:** Use Singularity AI with sigint_034 output for automated signal classification.

---

## sigint_035 — AIS Maritime Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes ais maritime monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_035
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 035: RUNNING
MODULE: AIS MARITIME MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_035_results.json
```

**Note:** Use Singularity AI with sigint_035 output for automated signal classification.

---

## sigint_036 — ACARS Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes acars decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_036
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 036: RUNNING
MODULE: ACARS DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_036_results.json
```

**Note:** Use Singularity AI with sigint_036 output for automated signal classification.

---

## sigint_037 — VDL-2 Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes vdl-2 decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_037
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 037: RUNNING
MODULE: VDL-2 DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_037_results.json
```

**Note:** Use Singularity AI with sigint_037 output for automated signal classification.

---

## sigint_038 — HF Shortwave Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes hf shortwave monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_038
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 038: RUNNING
MODULE: HF SHORTWAVE MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_038_results.json
```

**Note:** Use Singularity AI with sigint_038 output for automated signal classification.

---

## sigint_039 — RTTY Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes rtty decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_039
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 039: RUNNING
MODULE: RTTY DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_039_results.json
```

**Note:** Use Singularity AI with sigint_039 output for automated signal classification.

---

## sigint_040 — CW Morse Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes cw morse decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_040
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 040: RUNNING
MODULE: CW MORSE DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_040_results.json
```

**Note:** Use Singularity AI with sigint_040 output for automated signal classification.

---

## sigint_041 — NOAA Weather Satellite Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes noaa weather satellite decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_041
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 041: RUNNING
MODULE: NOAA WEATHER SATELLITE DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_041_results.json
```

**Note:** Use Singularity AI with sigint_041 output for automated signal classification.

---

## sigint_042 — METEOR-M2 Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes meteor-m2 decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_042
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 042: RUNNING
MODULE: METEOR-M2 DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_042_results.json
```

**Note:** Use Singularity AI with sigint_042 output for automated signal classification.

---

## sigint_043 — GOES Satellite Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes goes satellite decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_043
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 043: RUNNING
MODULE: GOES SATELLITE DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_043_results.json
```

**Note:** Use Singularity AI with sigint_043 output for automated signal classification.

---

## sigint_044 — Iridium Satellite Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes iridium satellite monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_044
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 044: RUNNING
MODULE: IRIDIUM SATELLITE MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_044_results.json
```

**Note:** Use Singularity AI with sigint_044 output for automated signal classification.

---

## sigint_045 — Globalstar Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes globalstar monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_045
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 045: RUNNING
MODULE: GLOBALSTAR MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_045_results.json
```

**Note:** Use Singularity AI with sigint_045 output for automated signal classification.

---

## sigint_046 — Inmarsat Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes inmarsat monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_046
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 046: RUNNING
MODULE: INMARSAT MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_046_results.json
```

**Note:** Use Singularity AI with sigint_046 output for automated signal classification.

---

## sigint_047 — Thuraya Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes thuraya monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_047
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 047: RUNNING
MODULE: THURAYA MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_047_results.json
```

**Note:** Use Singularity AI with sigint_047 output for automated signal classification.

---

## sigint_048 — GPS/GNSS Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes gps/gnss monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_048
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 048: RUNNING
MODULE: GPS/GNSS MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_048_results.json
```

**Note:** Use Singularity AI with sigint_048 output for automated signal classification.

---

## sigint_049 — GPS Jamming Detector

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes gps jamming detector signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_049
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 049: RUNNING
MODULE: GPS JAMMING DETECTOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_049_results.json
```

**Note:** Use Singularity AI with sigint_049 output for automated signal classification.

---

## sigint_050 — GPS Spoofing Detector

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes gps spoofing detector signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_050
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 050: RUNNING
MODULE: GPS SPOOFING DETECTOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_050_results.json
```

**Note:** Use Singularity AI with sigint_050 output for automated signal classification.

---

## sigint_051 — GLONASS Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes glonass monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_051
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 051: RUNNING
MODULE: GLONASS MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_051_results.json
```

**Note:** Use Singularity AI with sigint_051 output for automated signal classification.

---

## sigint_052 — Galileo Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes galileo monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_052
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 052: RUNNING
MODULE: GALILEO MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_052_results.json
```

**Note:** Use Singularity AI with sigint_052 output for automated signal classification.

---

## sigint_053 — BeiDou Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes beidou monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_053
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 053: RUNNING
MODULE: BEIDOU MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_053_results.json
```

**Note:** Use Singularity AI with sigint_053 output for automated signal classification.

---

## sigint_054 — SBAS Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes sbas monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_054
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 054: RUNNING
MODULE: SBAS MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_054_results.json
```

**Note:** Use Singularity AI with sigint_054 output for automated signal classification.

---

## sigint_055 — LoRa Network Scanner

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes lora network scanner signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_055
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 055: RUNNING
MODULE: LORA NETWORK SCANNER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_055_results.json
```

**Note:** Use Singularity AI with sigint_055 output for automated signal classification.

---

## sigint_056 — LoRaWAN Packet Decoder

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes lorawan packet decoder signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_056
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 056: RUNNING
MODULE: LORAWAN PACKET DECODER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_056_results.json
```

**Note:** Use Singularity AI with sigint_056 output for automated signal classification.

---

## sigint_057 — Sigfox Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes sigfox monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_057
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 057: RUNNING
MODULE: SIGFOX MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_057_results.json
```

**Note:** Use Singularity AI with sigint_057 output for automated signal classification.

---

## sigint_058 — NB-IoT Scanner

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes nb-iot scanner signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_058
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 058: RUNNING
MODULE: NB-IOT SCANNER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_058_results.json
```

**Note:** Use Singularity AI with sigint_058 output for automated signal classification.

---

## sigint_059 — Cat-M1 Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes cat-m1 monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_059
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 059: RUNNING
MODULE: CAT-M1 MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_059_results.json
```

**Note:** Use Singularity AI with sigint_059 output for automated signal classification.

---

## sigint_060 — ZigBee Network Scanner

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes zigbee network scanner signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_060
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 060: RUNNING
MODULE: ZIGBEE NETWORK SCANNER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_060_results.json
```

**Note:** Use Singularity AI with sigint_060 output for automated signal classification.

---

## sigint_061 — Z-Wave Network Scanner

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes z-wave network scanner signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_061
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 061: RUNNING
MODULE: Z-WAVE NETWORK SCANNER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_061_results.json
```

**Note:** Use Singularity AI with sigint_061 output for automated signal classification.

---

## sigint_062 — Thread Network Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes thread network monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_062
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 062: RUNNING
MODULE: THREAD NETWORK MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_062_results.json
```

**Note:** Use Singularity AI with sigint_062 output for automated signal classification.

---

## sigint_063 — Matter Protocol Scanner

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes matter protocol scanner signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_063
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 063: RUNNING
MODULE: MATTER PROTOCOL SCANNER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_063_results.json
```

**Note:** Use Singularity AI with sigint_063 output for automated signal classification.

---

## sigint_064 — Insteon Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes insteon monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_064
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 064: RUNNING
MODULE: INSTEON MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_064_results.json
```

**Note:** Use Singularity AI with sigint_064 output for automated signal classification.

---

## sigint_065 — Powerline Communication Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes powerline communication monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_065
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 065: RUNNING
MODULE: POWERLINE COMMUNICATION MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_065_results.json
```

**Note:** Use Singularity AI with sigint_065 output for automated signal classification.

---

## sigint_066 — Smart Meter Monitor (AMR/AMI)

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes smart meter monitor (amr/ami) signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_066
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 066: RUNNING
MODULE: SMART METER MONITOR (AMR/AMI)
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_066_results.json
```

**Note:** Use Singularity AI with sigint_066 output for automated signal classification.

---

## sigint_067 — RFID 125kHz Scanner

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes rfid 125khz scanner signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_067
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 067: RUNNING
MODULE: RFID 125KHZ SCANNER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_067_results.json
```

**Note:** Use Singularity AI with sigint_067 output for automated signal classification.

---

## sigint_068 — RFID 134.2kHz Scanner

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes rfid 134.2khz scanner signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_068
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 068: RUNNING
MODULE: RFID 134.2KHZ SCANNER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_068_results.json
```

**Note:** Use Singularity AI with sigint_068 output for automated signal classification.

---

## sigint_069 — NFC Type A/B/F/V Scanner

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes nfc type a/b/f/v scanner signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_069
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 069: RUNNING
MODULE: NFC TYPE A/B/F/V SCANNER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_069_results.json
```

**Note:** Use Singularity AI with sigint_069 output for automated signal classification.

---

## sigint_070 — HF RFID Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes hf rfid monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_070
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 070: RUNNING
MODULE: HF RFID MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_070_results.json
```

**Note:** Use Singularity AI with sigint_070 output for automated signal classification.

---

## sigint_071 — UHF RFID Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes uhf rfid monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_071
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 071: RUNNING
MODULE: UHF RFID MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_071_results.json
```

**Note:** Use Singularity AI with sigint_071 output for automated signal classification.

---

## sigint_072 — Microwave Link Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes microwave link monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_072
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 072: RUNNING
MODULE: MICROWAVE LINK MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_072_results.json
```

**Note:** Use Singularity AI with sigint_072 output for automated signal classification.

---

## sigint_073 — Point-to-Point Radio Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes point-to-point radio monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_073
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 073: RUNNING
MODULE: POINT-TO-POINT RADIO MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_073_results.json
```

**Note:** Use Singularity AI with sigint_073 output for automated signal classification.

---

## sigint_074 — MMDS Scanner

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes mmds scanner signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_074
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 074: RUNNING
MODULE: MMDS SCANNER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_074_results.json
```

**Note:** Use Singularity AI with sigint_074 output for automated signal classification.

---

## sigint_075 — LMDS Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes lmds monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_075
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 075: RUNNING
MODULE: LMDS MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_075_results.json
```

**Note:** Use Singularity AI with sigint_075 output for automated signal classification.

---

## sigint_076 — WiMAX Scanner

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes wimax scanner signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_076
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 076: RUNNING
MODULE: WIMAX SCANNER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_076_results.json
```

**Note:** Use Singularity AI with sigint_076 output for automated signal classification.

---

## sigint_077 — CDMA2000 Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes cdma2000 monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_077
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 077: RUNNING
MODULE: CDMA2000 MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_077_results.json
```

**Note:** Use Singularity AI with sigint_077 output for automated signal classification.

---

## sigint_078 — WCDMA/UMTS Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes wcdma/umts monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_078
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 078: RUNNING
MODULE: WCDMA/UMTS MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_078_results.json
```

**Note:** Use Singularity AI with sigint_078 output for automated signal classification.

---

## sigint_079 — TD-SCDMA Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes td-scdma monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_079
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 079: RUNNING
MODULE: TD-SCDMA MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_079_results.json
```

**Note:** Use Singularity AI with sigint_079 output for automated signal classification.

---

## sigint_080 — GSM-R (Railway) Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes gsm-r (railway) monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_080
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 080: RUNNING
MODULE: GSM-R (RAILWAY) MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_080_results.json
```

**Note:** Use Singularity AI with sigint_080 output for automated signal classification.

---

## sigint_081 — TETRA Police Radio Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes tetra police radio monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_081
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 081: RUNNING
MODULE: TETRA POLICE RADIO MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_081_results.json
```

**Note:** Use Singularity AI with sigint_081 output for automated signal classification.

---

## sigint_082 — Air Traffic Control Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes air traffic control monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_082
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 082: RUNNING
MODULE: AIR TRAFFIC CONTROL MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_082_results.json
```

**Note:** Use Singularity AI with sigint_082 output for automated signal classification.

---

## sigint_083 — Military Band Scanner

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes military band scanner signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_083
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 083: RUNNING
MODULE: MILITARY BAND SCANNER
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_083_results.json
```

**Note:** Use Singularity AI with sigint_083 output for automated signal classification.

---

## sigint_084 — Emergency Service Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes emergency service monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_084
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 084: RUNNING
MODULE: EMERGENCY SERVICE MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_084_results.json
```

**Note:** Use Singularity AI with sigint_084 output for automated signal classification.

---

## sigint_085 — Ham Radio Band Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes ham radio band monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_085
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 085: RUNNING
MODULE: HAM RADIO BAND MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_085_results.json
```

**Note:** Use Singularity AI with sigint_085 output for automated signal classification.

---

## sigint_086 — CB Radio Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes cb radio monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_086
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 086: RUNNING
MODULE: CB RADIO MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_086_results.json
```

**Note:** Use Singularity AI with sigint_086 output for automated signal classification.

---

## sigint_087 — Marine VHF Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes marine vhf monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_087
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 087: RUNNING
MODULE: MARINE VHF MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_087_results.json
```

**Note:** Use Singularity AI with sigint_087 output for automated signal classification.

---

## sigint_088 — Aviation UHF Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes aviation uhf monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_088
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 088: RUNNING
MODULE: AVIATION UHF MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_088_results.json
```

**Note:** Use Singularity AI with sigint_088 output for automated signal classification.

---

## sigint_089 — Satellite Uplink Detector

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes satellite uplink detector signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_089
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 089: RUNNING
MODULE: SATELLITE UPLINK DETECTOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_089_results.json
```

**Note:** Use Singularity AI with sigint_089 output for automated signal classification.

---

## sigint_090 — Ka-Band Satellite Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes ka-band satellite monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_090
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 090: RUNNING
MODULE: KA-BAND SATELLITE MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_090_results.json
```

**Note:** Use Singularity AI with sigint_090 output for automated signal classification.

---

## sigint_091 — Ku-Band Satellite Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes ku-band satellite monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_091
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 091: RUNNING
MODULE: KU-BAND SATELLITE MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_091_results.json
```

**Note:** Use Singularity AI with sigint_091 output for automated signal classification.

---

## sigint_092 — C-Band Satellite Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes c-band satellite monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_092
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 092: RUNNING
MODULE: C-BAND SATELLITE MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_092_results.json
```

**Note:** Use Singularity AI with sigint_092 output for automated signal classification.

---

## sigint_093 — X-Band Radar Detector

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes x-band radar detector signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_093
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 093: RUNNING
MODULE: X-BAND RADAR DETECTOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_093_results.json
```

**Note:** Use Singularity AI with sigint_093 output for automated signal classification.

---

## sigint_094 — S-Band Radar Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes s-band radar monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_094
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 094: RUNNING
MODULE: S-BAND RADAR MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_094_results.json
```

**Note:** Use Singularity AI with sigint_094 output for automated signal classification.

---

## sigint_095 — L-Band Radar Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes l-band radar monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_095
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 095: RUNNING
MODULE: L-BAND RADAR MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_095_results.json
```

**Note:** Use Singularity AI with sigint_095 output for automated signal classification.

---

## sigint_096 — Drone Control Link Detector

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes drone control link detector signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_096
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 096: RUNNING
MODULE: DRONE CONTROL LINK DETECTOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_096_results.json
```

**Note:** Use Singularity AI with sigint_096 output for automated signal classification.

---

## sigint_097 — UAV Telemetry Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes uav telemetry monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_097
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 097: RUNNING
MODULE: UAV TELEMETRY MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_097_results.json
```

**Note:** Use Singularity AI with sigint_097 output for automated signal classification.

---

## sigint_098 — FPV Video Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes fpv video monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_098
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 098: RUNNING
MODULE: FPV VIDEO MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_098_results.json
```

**Note:** Use Singularity AI with sigint_098 output for automated signal classification.

---

## sigint_099 — RC Aircraft Monitor

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes rc aircraft monitor signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_099
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 099: RUNNING
MODULE: RC AIRCRAFT MONITOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_099_results.json
```

**Note:** Use Singularity AI with sigint_099 output for automated signal classification.

---

## sigint_100 — 2.4GHz Jammer Detector

**Platform:** pandora_titan/omega

**What it does:** Monitors and analyzes 2.4ghz jammer detector signals as part of the JanusOS SIGINT collection toolkit.

**How to run:**
1. SIGINT → sigint_100
2. Configure frequency range and detection parameters
3. Monitor in real time via Pandora SDR
4. Captured data logged to Evidence

**Expected output:**
```
SIGINT 100: RUNNING
MODULE: 2.4GHZ JAMMER DETECTOR
SDR: ACTIVE
STATUS: MONITORING
SAVED: /Evidence/sigint/sigint_100_results.json
```

**Note:** Use Singularity AI with sigint_100 output for automated signal classification.

---

