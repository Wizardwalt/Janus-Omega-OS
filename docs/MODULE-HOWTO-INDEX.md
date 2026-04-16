# JanusOS — Master Module How-To Index
**Version:** 3.5.1 | **Total Modules:** 1,233 | **Categories:** 13 + Core Omega

> This is the master reference for all JanusOS modules. Each category links to a dedicated how-to guide. Use this index to find the right tool for your operation.

---

## Quick Start

1. **Boot JanusOS** — boots directly into the Janus terminal (green/purple TUI)
2. **Connect your target** — ADB (Android) or libimobiledevice (iOS) — confirmed in status bar
3. **Always run first:** `Core Omega → 01_identity` to enumerate the target
4. **Choose your operation** from the category list below
5. **End of operation:** Run `Core Omega → 47_report_gen` to compile evidence

---

## Category Index

| Category | Modules | File | Description |
|---|---|---|---|
| **Core Omega** | 203 | [core_omega.md](modules/core_omega.md) | Root-level toolkit: ADB ops, forensics, elite God Tier |
| **Forensics** | 152 | [forensics.md](modules/forensics.md) | Data recovery, WAL carving, timeline reconstruction |
| **Cyber Warfare** | 154 | [cyber_warfare.md](modules/cyber_warfare.md) | Offensive digital ops, credential attacks, persistence |
| **Mobile Offense** | 150 | [mobile_offense.md](modules/mobile_offense.md) | FRP bypass, root, bloatware, app modification |
| **Network Warfare** | 150 | [network_warfare.md](modules/network_warfare.md) | Wi-Fi attacks, MITM, traffic interception, SCADA |
| **Hardware Glitch** | 100 | [hardware_glitch.md](modules/hardware_glitch.md) | Voltage/clock glitch attacks via Pandora Mk.1 |
| **OSINT Oracle** | 100 | [osint_oracle.md](modules/osint_oracle.md) | Identity correlation, geo-profiling, dark web |
| **SIGINT** | 100 | [sigint.md](modules/sigint.md) | RF monitoring, cellular intercept, satellite |
| **Titan Exclusive** | 104 | [titan_exclusive.md](modules/titan_exclusive.md) | AR-HUD, Neural-Sync, CBRN, Kinetic Harvester |
| **Tactical** | 5 | [tactical.md](modules/tactical.md) | Janus AI, Ghost-Net mesh, stealth boot, signal analysis |
| **Advanced Mobile** | 4 | [advanced_mobile.md](modules/advanced_mobile.md) | Identity cloning, SIM spoof, Ghost Mode, bypass |
| **Expansion** | 4 | [expansion.md](modules/expansion.md) | Biometric spoof, grid override, packet inject, sat |
| **Mobile Expansion** | 4 | [mobile_expansion.md](modules/mobile_expansion.md) | Kernel intercept, deep acquisition, covert surveillance |
| **Offensive** | 3 | [offensive.md](modules/offensive.md) | ADB shell, pipeline executor, target enumerator |

---

## Operational Playbooks

Common mission flows combining multiple categories.

---

### Playbook A — Full Device Forensics (Android)

**Goal:** Extract all evidence from a target Android device.

```
1. Core Omega → 01_identity          (confirm connection)
2. Core Omega → 33_stealth_mode      (disable your own telemetry)
3. Offensive → off_003               (full target enumeration)
4. Core Omega → 05_data_extract      (pull media and documents)
5. Core Omega → 19_sms_forensics     (extract SMS including deleted)
6. Core Omega → 21_call_logs         (extract call history)
7. Forensics → data_carver           (recover deleted DB records)
8. Core Omega → 65_exif_mapper       (map location from photos)
9. Core Omega → 17_usage_timeline    (reconstruct app usage)
10. Core Omega → 47_report_gen       (compile full report)
```

---

### Playbook B — Network Penetration

**Goal:** Infiltrate and map a target Wi-Fi network.

```
1. Network Warfare → nw_061          (passive network scan)
2. Network Warfare → nw_001          (Wi-Fi Marauder - capture handshake)
3. Core Omega → 40_crypto_brute      (crack WPA passphrase offline)
4. [Connect to network]
5. Tactical → network_cartographer   (full topology map)
6. Network Warfare → nw_021          (SSL Strip MITM)
7. Core Omega → 58_mitm_proxy        (full MITM with SSL inspection)
8. Core Omega → 61_browser_dumper    (capture credentials)
9. Core Omega → 47_report_gen        (compile report)
```

---

### Playbook C — Radio Intelligence Gathering

**Goal:** Monitor and analyze radio environment in an area.

```
1. SIGINT → sigint_001               (broad spectrum scan)
2. SIGINT → sigint_031               (cellular tower scan)
3. Core Omega → 35_stingray_detector (detect IMSI catchers)
4. Core Omega → 34_sdr_suite         (full SDR analysis)
5. Tactical → deep_signal_analyzer   (fingerprint unknown signals)
6. OSINT Oracle → osint_001          (correlate found identifiers)
7. Tactical → janus_ai               (AI classification of all findings)
```

---

### Playbook D — Hardware Attack (Physical Access)

**Goal:** Extract data from a physically accessed device using Pandora Mk.1.

```
1. Hardware Glitch → hw_001          (characterize target power profile)
2. Hardware Glitch → hw_021          (unlock JTAG port)
3. Hardware Glitch → hw_031          (secure boot bypass)
4. Core Omega → 49_jtag_uart         (open JTAG debug session)
5. Core Omega → 92_cold_ram_dump     (extract RAM contents)
6. Core Omega → 77_ram_analyzer      (analyze dump for credentials/keys)
7. Mobile Expansion → me_002         (full physical acquisition)
```

---

### Playbook E — OSINT Target Profile

**Goal:** Build a complete profile on a target from open sources only.

```
1. OSINT Oracle → osint_001          (identity correlation from phone/email)
2. OSINT Oracle → osint_011          (social media footprint)
3. OSINT Oracle → osint_041          (dark web presence)
4. OSINT Oracle → osint_051          (breach database check)
5. OSINT Oracle → osint_021          (geo-profile from any photos found)
6. OSINT Oracle → osint_091          (generate threat intelligence report)
```

---

## Hardware Quick Reference

| Module Category | Primary Hardware |
|---|---|
| Core Omega, Forensics, Mobile Offense | Any Pandora + ADB cable |
| Hardware Glitch | Pandora Mk.1 (USB Glitcher) |
| SIGINT, Network Warfare | Pandora Omega/Titan + SDR/Wi-Fi adapter |
| Titan Exclusive | Pandora Titan only |
| Tactical (Ghost-Net) | 2+ Pandora units |
| Advanced Mobile (Signal Cloner) | Pandora Titan + Hydra Radio Array |

---

## Module Count Summary

```
Core Omega (root)    203
Cyber Warfare        154
Titan Exclusive      104
Forensics            152
Mobile Offense       150
Network Warfare      150
OSINT Oracle         100
SIGINT               100
Hardware Glitch      100
Advanced Mobile        4
Expansion              4
Mobile Expansion       4
Offensive              3
Tactical               5
─────────────────────────
TOTAL              1,233
```

---

## Finding a Module

**By function:** Use the category table above  
**By name:** `Janus TUI → Search` — type any keyword  
**By number:** Navigate directly to the module number in its category  
**By AI:** Ask the Janus AI: *"What module should I use to [goal]?"*
