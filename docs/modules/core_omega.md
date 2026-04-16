# Core Omega — Module How-To Guide
**Category:** Root plugins (`plugins/*.lua`) | **Module Count:** 203

The Core Omega modules are the foundational JanusOS toolkit — the original 203 root-level plugins covering the full operational spectrum from basic ADB identity scanning through God-Tier legendary operations. These are loaded directly from `plugins/` (not a subdirectory).

---

## How to Run Root Modules

1. Janus TUI → **Core Omega** (top-level menu)
2. Browse by number (01–200) or search by name
3. Select and press Enter to execute

---

## Module Reference

### Tier 1 — Core Operations (01–20)

| Module | Name | What It Does |
|---|---|---|
| 01_identity | ADB Identity Scan | Reads device model, Android version, security patch, bootloader state |
| 02_frp_bypass | FRP Bypass | YouTube/Maps intent chain to bypass Factory Reset Protection |
| 03_bloat_matrix | Bloatware Matrix | Removes/disables 150+ OEM and carrier bloatware packages |
| 04_threat_dragnet | Threat Dragnet | Scans 50+ paths and signatures for spyware, stalkerware, and root threats |
| 05_data_extract | Data Pull | Pulls DCIM, Downloads, WhatsApp media, and documents to Evidence folder |
| 06_game_god | Game God | Patches game XML files for infinite in-game resources |
| 07_bootloop_fix | Bootloop Fix | Wipes dalvik/cache, restarts UI, repairs common bootloop causes |
| 10_cellular_scan | Cellular Scanner | Scans all bands for nearby towers, outputs Cell IDs and signal strengths |
| 11_bt_forensics | Bluetooth Forensics | Dumps Bluetooth pairing history and scans for nearby devices |
| 12_remote_report | Remote Report | Packages all collected evidence into an encrypted report and queues for exfil |
| 13_cloud_security | Cloud Security | Audits Google/Apple/Samsung cloud sync settings and disables insecure ones |
| 14_location_forensics | Location Forensics | Extracts location history from Google Maps, Life360, and native GPS logs |
| 15_smart_diag | Smart Diagnostics | Full device health check: battery, storage, RAM, CPU, thermal |
| 16_adb_keys | ADB Keys | Dumps and manages ADB authorized keys database |
| 17_usage_timeline | Usage Timeline | Reconstructs app usage timeline from UsageStats API |
| 18_dns_dump | DNS Dump | Dumps DNS cache and recent resolver queries |
| 19_sms_forensics | SMS Forensics | Extracts SMS database including deleted messages via WAL |
| 20_selinux_audit | SELinux Audit | Reports current SELinux policy and detects policy bypasses |

---

### Tier 2 — Intelligence Operations (21–50)

| Module | Name | What It Does |
|---|---|---|
| 21_call_logs | Call Log Extractor | Pulls full call history including deleted entries |
| 22_wifi_history | Wi-Fi History | Extracts saved networks, connection timestamps, and signal logs |
| 23_mount_analyzer | Mount Analyzer | Lists all mounted partitions and detects hidden/encrypted volumes |
| 24_dev_settings | Developer Settings | Audits and configures Android developer options remotely |
| 25_hidden_files | Hidden Files | Scans for dot-files, alternate data streams, and hidden directories |
| 26_account_audit | Account Audit | Lists all accounts on device across all authenticators |
| 27_process_map | Process Map | Maps all running processes, their PIDs, parents, and network connections |
| 28_overlay_detector | Overlay Detector | Detects clickjacking overlays and UI overlay attacks |
| 29_ai_heuristic | AI Heuristic Analysis | AI-driven behavioral analysis of apps for malware indicators |
| 30_quantum_crypto | Quantum Crypto Scanner | Identifies non-quantum-safe cryptographic implementations on device |
| 31_zeroday_auditor | Zero-Day Auditor | Checks installed apps and system against known CVE database |
| 32_darkweb_monitor | Dark Web Monitor | Monitors for device identifiers appearing on dark web forums |
| 33_stealth_mode | Stealth Mode | Full operational stealth: disables all outbound telemetry |
| 34_sdr_suite | SDR Suite | Launches software-defined radio scanner with full band sweep |
| 35_stingray_detector | Stingray Detector | Detects IMSI catchers / fake base stations in the area |
| 36_gps_spoof_check | GPS Spoof Check | Detects if device is reporting spoofed GPS coordinates |
| 37_lorawan_auditor | LoRaWAN Auditor | Scans for LoRaWAN gateways and audits network security |
| 38_cold_boot | Cold Boot | Initiates controlled cold boot attack preparation sequence |
| 39_biometric_bypass | Biometric Bypass | Attempts to bypass biometric lock using stored template analysis |
| 40_crypto_brute | Crypto Brute | GPU-accelerated password attack on extracted hash files |
| 41_metadata_scrubber | Metadata Scrubber | Strips all metadata from files before exfil (EXIF, Office, PDF) |
| 42_kernel_injector | Kernel Injector | Loads custom kernel module (.ko) onto rooted target |
| 43_hypervisor_detect | Hypervisor Detect | Detects if device is running inside a virtual machine or sandbox |
| 44_uefi_scan | UEFI Scan | Audits UEFI/BIOS firmware for known vulnerabilities |
| 45_osint_hub | OSINT Hub | Central OSINT launcher — queries all Oracle modules against target |
| 46_mesh_sync | Mesh Sync | Syncs collected intelligence to all Ghost-Net peers |
| 47_report_gen | Report Generator | Generates formatted PDF/Markdown report from all Evidence |
| 48_can_bus | CAN Bus | Reads and injects CAN bus frames (vehicle/industrial targets) |
| 49_jtag_uart | JTAG/UART | Opens JTAG or UART debug session on connected hardware target |
| 50_biometric_extract | Biometric Extract | Extracts biometric templates from device secure enclave |

---

### Tier 3 — Advanced Operations (51–99)

| Module | Name | What It Does |
|---|---|---|
| 51_ssh_brute | SSH Brute | Credential attack against SSH services on target network |
| 52_social_shadow | Social Shadow | Extracts shadow profiles from social app databases |
| 56_wallet_recovery | Wallet Recovery | Recovers crypto wallet seeds from device storage and backups |
| 57_thermal_bypass | Thermal Bypass | Exploits thermal throttling to create timing windows for attacks |
| 58_mitm_proxy | MITM Proxy | Full MITM proxy with SSL inspection on target network |
| 59_usb_ducky | USB Ducky | Programs the Pandora Mk.1 as a BadUSB HID attack device |
| 60_cloud_dumper | Cloud Dumper | Extracts linked cloud storage (Google Drive, iCloud, OneDrive) |
| 61_browser_dumper | Browser Dumper | Dumps saved passwords, cookies, and history from all browsers |
| 62_kernel_logs | Kernel Logs | Streams live kernel dmesg output for analysis |
| 63_nfc_emulator | NFC Emulator | Emulates NFC cards (access badges, payment cards, transit) |
| 64_app_lock_bypass | App Lock Bypass | Bypasses third-party app locks without device unlock |
| 65_exif_mapper | EXIF Mapper | Maps EXIF GPS data from photo collection to movement timeline |
| 66_voltage_glitch | Voltage Glitch | Direct voltage glitch via Pandora Mk.1 (see Hardware Glitch for detail) |
| 67_wpa3_scan | WPA3 Scanner | Audits WPA3 networks for Dragonblood and implementation flaws |
| 68_root_ca_audit | Root CA Audit | Lists all trusted certificate authorities and flags untrusted ones |
| 69_voip_recon | VoIP Recon | Discovers and fingerprints VoIP infrastructure |
| 70_entropy_monitor | Entropy Monitor | Monitors /dev/random entropy pool — detects weak RNG |
| 71_deleted_recovery | Deleted Recovery | Recovers deleted files from device storage via unlink analysis |
| 72_bgp_monitor | BGP Monitor | Monitors BGP routing table for hijacking and anomalies |
| 73_faceid_spoof | FaceID Spoof | Generates 3D face model to attempt FaceID bypass |
| 74_crypto_trace | Crypto Trace | Traces cryptographic key material through memory |
| 75_secure_boot_audit | Secure Boot Audit | Audits Android Verified Boot and reports bypass opportunities |
| 76_ble_sniffer | BLE Sniffer | Captures BLE advertisement packets and connections |
| 77_ram_analyzer | RAM Analyzer | Analyzes memory dump for credentials, keys, and artifacts |
| 78_tor_detector | Tor Detector | Detects Tor exit nodes and hidden service traffic on network |
| 79_tpm_audit | TPM Audit | Audits TPM chip state and detects key extraction opportunities |
| 80_darkweb_search | Dark Web Search | Searches Tor onion indexes for target identifiers |
| 81_subghz_* | Sub-GHz Suite | Full sub-GHz toolkit: sniff, replay, and clone RF remotes |
| 82_rfid_* | RFID Suite | RFID card read, clone, and emulate |
| 83_ir_* | IR Suite | Universal IR blaster — learn and replay any IR remote |
| 84_nfc_manipulator | NFC Manipulator | Read, write, clone, and fuzz NFC tags |
| 85_ir_blaster | IR Blaster | Control any IR device (TV, AC, projector) from Titan |
| 86_gpio_sniffer | GPIO Sniffer | Monitors GPIO pins on embedded targets |
| 87_dect_interceptor | DECT Interceptor | Captures DECT cordless phone transmissions |
| 88_pager_decoder | Pager Decoder | Decodes POCSAG/FLEX pager messages |
| 89_badusb_studio | BadUSB Studio | Visual editor for HID attack payloads |
| 90_wifi_marauder | Wi-Fi Marauder | Full Wi-Fi attack suite (see Network Warfare) |
| 91_nmap_scan | Nmap Scan | Full Nmap scan with customizable flags against any target |
| 92_cold_ram_dump | Cold RAM Dump | Freezes device and extracts RAM contents |
| 93_social_graph | Social Graph | Builds social relationship graph from extracted contacts |
| 94_watchdog_bypass | Watchdog Bypass | Disables Android watchdog to prevent automatic reboots |
| 95_dns_poison | DNS Poison | Poisons DNS cache on local network to redirect traffic |
| 96_biometric_emu | Biometric Emulator | Emulates biometric hardware responses for bypass |
| 97_satcom_tracker | Satcom Tracker | Tracks satellite communication patterns |
| 98_token_recovery | Token Recovery | Recovers OAuth tokens and session cookies from app storage |
| 99_bootloader_unlock | Bootloader Unlock | OEM-specific bootloader unlock sequences |

---

### Tier 4 — God Tier / Elite (100–200)

| Module | Name | What It Does |
|---|---|---|
| 100_core_omega | Core Omega | Activates all 100 forensic modules simultaneously — full system integration |
| 101_god_mode | God Mode | Kernel Ring-0 access via custom .ko — hooks all system calls |
| 102_decrypt_engine | Decrypt Engine | GPU-accelerated AES-256-XTS decryption at 14.2 GB/s throughput |
| 103_global_intel | Global Intel Sync | Syncs threat intelligence signatures via encrypted satellite uplink |
| 104_zero_trace | Zero-Trace Wiper | Gutmann 35-pass secure deletion of all forensic artifacts |
| 105_neural_unlock | Neural Pattern Unlock | Analyzes screen smudge + biometric patterns to reconstruct PIN/gesture |
| 106_dark_fi | Dark-Fi Sniffer | Detects hidden and non-broadcasting wireless networks |
| 107_cold_storage | Cold Storage Extractor | Extracts keys from secure element via race condition exploit |
| 108_ghost_gsm | Ghost GSM | Operates as a ghost GSM node — intercepts local cellular traffic |
| 109_anti_forensic | Anti-Forensic | Full counter-forensics: wipes logs, randomizes timestamps |
| 110_quantum_mesh | Quantum Mesh | Quantum-resistant encrypted mesh communication layer |
| 111_sat_grabber | Sat Grabber | Grabs satellite internet session data |
| 112_bios_bypass | BIOS Bypass | Exploits UEFI vulnerabilities for persistent firmware implant |
| 113_airgap_jumper | Air Gap Jumper | Exfiltrates data across air-gapped networks via acoustic/RF covert channels |
| 114_thermal_tracker | Thermal Tracker | Tracks device location via thermal emission pattern analysis |
| 115_miner_detector | Miner Detector | Detects hidden cryptocurrency mining processes |
| 116_app_dissector | App Dissector | Decompiles and analyzes any APK for security vulnerabilities |
| 117_usb_power | USB Power | Powers Pandora Mk.1 attack sequences via USB power delivery |
| 118_rootkit_hunter | Rootkit Hunter | Deep scan for kernel-level rootkits and persistent implants |
| 119_voice_cloner | Voice Cloner | Clones a voice profile from audio sample for bypass or impersonation |
| 120_singularity | Singularity | Activates full AI autonomy — Janus operates independently |
| 121–130 | Communication Suite | Voice calls, SMS center control, contacts extraction, space signal analysis |
| 131–140 | Exfiltration Suite | Fan-based exfil, satellite internet, exploit hub, face cloaking |
| 141–150 | Offensive Suite | Onion crawler, smart home override, BIOS persistence, neural scan |
| 151–160 | Omega Suite | Hypersonic signal, archaeo carver, DNA encryption, gravity wave analysis |
| 161–170 | Transcendence Suite | Neural mapping, teleport communications, soul recovery operations |
| 171–180 | Singularity Suite | Mesh override, archivist, singularity core, multiverse monitoring |
| 181–190 | Absolute Suite | Mind-net bridge, atomic override, ghost operator, power harvester |
| 191–200 | Alpha-Omega Suite | Planet override, galactic exfil, sovereign operations, deity mode |

---

## Tips

- Start any operation with `01_identity` to confirm device connectivity
- Run `33_stealth_mode` before any active operation to prevent telemetry
- God Tier modules (100+) are the most powerful — some require Pandora Titan hardware
- `47_report_gen` compiles all Evidence into a formatted report — run this at the end of every operation
- `120_singularity` activates full AI autonomy — the Janus AI will suggest and execute modules automatically based on the operational objective you set
