# Hardware Glitch — Full Module Reference
**Category:** `hardware_glitch` | **Total Modules:** 100 | *Every module individually documented*

---

## hw_001 — Target Power Profiling

**Platform:** hardware

**What it does:** Measures and profiles the target device's power consumption profile — identifies voltage levels, current draw, and timing characteristics needed to plan a glitch attack.

**How to run:**
1. Hardware Glitch → hw_001
2. Connect Pandora Mk.1 power probes to target
3. Power target and begin profile capture
4. Capture minimum 60 seconds of data

**Expected output:**
```
POWER PROFILING: RUNNING
TARGET: [device]
VCC: 3.3V | VCORE: 1.1V
CURRENT: 245mA idle / 890mA peak
PROFILE SAVED: /Evidence/glitch/power_profile.json
```

**Note:** Power profile is the foundation of all glitch attacks — always run first.

---

## hw_002 — Voltage Glitch Calibration

**Platform:** hardware

**What it does:** Calibrates the Pandora Mk.1 voltage glitcher for the target device — finds optimal glitch voltage, duration, and timing offset.

**How to run:**
1. Hardware Glitch → hw_002
2. Requires hw_001 profile
3. Module runs automated calibration sequence
4. Successful parameters saved to glitch profile

**Expected output:**
```
VOLTAGE GLITCH CALIBRATION: RUNNING
CALIBRATION SWEEPS: 1,000
SUCCESSFUL GLITCHES: 23
OPTIMAL: -500mV / 45ns / offset 1.2ms
PROFILE: /Evidence/glitch/calibration.json
```

**Note:** Calibration can take 30-60 minutes — the more thorough the calibration, the higher the attack success rate.

---

## hw_003 — Clock Glitch Calibration

**Platform:** hardware

**What it does:** Calibrates clock glitch parameters — finds the optimal clock manipulation that causes the target to skip instructions without crashing.

**How to run:**
1. Hardware Glitch → hw_003
2. Connect Pandora Mk.1 to target clock line
3. Run calibration sweep across frequencies and pulse widths
4. Working parameters saved

**Expected output:**
```
CLOCK GLITCH CALIBRATION: RUNNING
CLOCK LINE: CONNECTED
FREQUENCY SWEEPS: 500
OPTIMAL: 8MHz | PULSE: 15ns | OFFSET: 2.3ms
SAVED: /Evidence/glitch/clock_calibration.json
```

**Note:** Clock glitching is more reliable than voltage glitching on some targets — test both.

---

## hw_004 — Secure Boot Bypass via Voltage Glitch

**Platform:** hardware

**What it does:** Uses calibrated voltage glitch to bypass Secure Boot verification — causes the boot ROM to skip signature verification.

**How to run:**
1. Hardware Glitch → hw_004
2. Requires hw_002 calibration
3. Target booted with Pandora Mk.1 in-line
4. Glitch triggered at boot ROM signature check

**Expected output:**
```
SECURE BOOT BYPASS: RUNNING
METHOD: VOLTAGE GLITCH
GLITCH: -500mV / 45ns
ATTEMPTS: 23
SUCCESS: YES
CUSTOM BOOT: LOADED
```

**Note:** Boot ROM signature check happens in a very specific timing window — calibrate precisely.

---

## hw_005 — Secure Boot Bypass via Clock Glitch

**Platform:** hardware

**What it does:** Clock glitch variant of Secure Boot bypass — manipulates clock to skip CRC/signature verification in boot ROM.

**How to run:**
1. Hardware Glitch → hw_005
2. Requires hw_003 calibration
3. Trigger clock glitch at signature verification
4. Custom bootloader loaded on success

**Expected output:**
```
SECURE BOOT BYPASS (CLOCK): RUNNING
GLITCH: 15ns PULSE
ATTEMPTS: 45
SUCCESS: YES
CUSTOM BOOTLOADER: RUNNING
```

**Note:** Clock glitch bypass is more reliable on Cortex-M targets — voltage glitch better for application processors.

---

## hw_006 — JTAG Lock Bypass

**Platform:** hardware

**What it does:** Bypasses JTAG lock/fuse bits using voltage glitch during JTAG authentication to enable debug interface.

**How to run:**
1. Hardware Glitch → hw_006
2. Connect Pandora Mk.1 to target power and JTAG
3. Glitch timed during JTAG auth sequence
4. JTAG enabled on success

**Expected output:**
```
JTAG LOCK BYPASS: RUNNING
JTAG: DETECTED
GLITCH: VOLTAGE / -600mV / 30ns
ATTEMPTS: 67
JTAG LOCK: BYPASSED
DEBUG: ENABLED
```

**Note:** Once JTAG is unlocked, full memory read/write access is available.

---

## hw_007 — Flash Read Protection Bypass

**Platform:** hardware

**What it does:** Bypasses flash read protection (RDP) on microcontrollers using voltage glitch during boot.

**How to run:**
1. Hardware Glitch → hw_007
2. Target: STM32/nRF/Kinetis with RDP enabled
3. Glitch calibrated for target MCU
4. Flash contents readable on success

**Expected output:**
```
FLASH READ PROTECTION BYPASS: RUNNING
TARGET MCU: STM32F4
RDP LEVEL: 1
GLITCH SEQUENCE: 3 PULSES
SUCCESS: YES
FLASH: READABLE
```

**Note:** RDP Level 2 (permanent) cannot be bypassed by glitching — only Levels 0 and 1.

---

## hw_008 — Secure Element Extraction

**Platform:** hardware

**What it does:** Attempts to extract keys from secure elements using combined glitch + timing side-channel attack.

**How to run:**
1. Hardware Glitch → hw_008
2. Identify target SE (NXP SE050, ATECC, etc.)
3. Run combined glitch + SCA attack
4. Key material extracted if successful

**Expected output:**
```
SECURE ELEMENT ATTACK: RUNNING
TARGET SE: NXP SE050
METHOD: GLITCH + DIFFERENTIAL POWER ANALYSIS
ATTEMPTS: 10,000
KEY BITS RECOVERED: 128/256
FURTHER ATTEMPTS NEEDED: YES
```

**Note:** Secure Element attacks require extended time (hours to days) — dedicated attack sessions recommended.

---

## hw_009 — Power Side-Channel Analysis

**Platform:** hardware

**What it does:** Measures power consumption during cryptographic operations to extract keys via Differential Power Analysis (DPA).

**How to run:**
1. Hardware Glitch → hw_009
2. Connect high-resolution current probe
3. Trigger target to perform cryptographic operations repeatedly
4. Collect 10,000+ traces for DPA

**Expected output:**
```
POWER SCA: RUNNING
TRACES COLLECTED: 10,000
DPA PROCESSING: running
KEY BYTES FOUND: 12/32 AES bytes
CONTINUING: YES
```

**Note:** Power SCA requires many traces — more traces = higher key recovery accuracy.

---

## hw_010 — Electromagnetic Side-Channel

**Platform:** hardware

**What it does:** Captures electromagnetic emissions during cryptographic operations using near-field EM probe for EMCA analysis.

**How to run:**
1. Hardware Glitch → hw_010
2. Position EM probe over target crypto core
3. Collect EM traces during repeated crypto operations
4. EMCA processing extracts key

**Expected output:**
```
EM SIDE-CHANNEL: RUNNING
EM PROBE: POSITIONED
TRACES: 10,000
EM-DPA: PROCESSING
KEY RECOVERED: AES-128 [32 bytes]
SAVED: /Evidence/glitch/em_key.bin
```

**Note:** EM probing can be done from greater distances than power SCA — useful for passively placed targets.

---

## hw_011 — Timing Side-Channel Attack

**Platform:** hardware

**What it does:** Executes timing side-channel attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_011
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 011: EXECUTING
MODULE: TIMING SIDE-CHANNEL ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_011_results.json
```

**Note:** Consult hardware target documentation before executing hw_011.

---

## hw_012 — Cache Side-Channel (Spectre/Meltdown)

**Platform:** hardware

**What it does:** Executes cache side-channel (spectre/meltdown) using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_012
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 012: EXECUTING
MODULE: CACHE SIDE-CHANNEL (SPECTRE/MELTDOWN)
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_012_results.json
```

**Note:** Consult hardware target documentation before executing hw_012.

---

## hw_013 — Acoustic Side-Channel

**Platform:** hardware

**What it does:** Executes acoustic side-channel using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_013
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 013: EXECUTING
MODULE: ACOUSTIC SIDE-CHANNEL
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_013_results.json
```

**Note:** Consult hardware target documentation before executing hw_013.

---

## hw_014 — Photon Emission Analysis

**Platform:** hardware

**What it does:** Executes photon emission analysis using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_014
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 014: EXECUTING
MODULE: PHOTON EMISSION ANALYSIS
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_014_results.json
```

**Note:** Consult hardware target documentation before executing hw_014.

---

## hw_015 — Temperature Glitch Attack

**Platform:** hardware

**What it does:** Executes temperature glitch attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_015
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 015: EXECUTING
MODULE: TEMPERATURE GLITCH ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_015_results.json
```

**Note:** Consult hardware target documentation before executing hw_015.

---

## hw_016 — Laser Fault Injection

**Platform:** hardware

**What it does:** Executes laser fault injection using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_016
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 016: EXECUTING
MODULE: LASER FAULT INJECTION
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_016_results.json
```

**Note:** Consult hardware target documentation before executing hw_016.

---

## hw_017 — Focused Ion Beam Preparation

**Platform:** hardware

**What it does:** Executes focused ion beam preparation using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_017
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 017: EXECUTING
MODULE: FOCUSED ION BEAM PREPARATION
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_017_results.json
```

**Note:** Consult hardware target documentation before executing hw_017.

---

## hw_018 — NAND Glitching

**Platform:** hardware

**What it does:** Executes nand glitching using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_018
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 018: EXECUTING
MODULE: NAND GLITCHING
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_018_results.json
```

**Note:** Consult hardware target documentation before executing hw_018.

---

## hw_019 — eMMC Command Injection

**Platform:** hardware

**What it does:** Executes emmc command injection using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_019
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 019: EXECUTING
MODULE: EMMC COMMAND INJECTION
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_019_results.json
```

**Note:** Consult hardware target documentation before executing hw_019.

---

## hw_020 — UFS Protocol Exploit

**Platform:** hardware

**What it does:** Executes ufs protocol exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_020
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 020: EXECUTING
MODULE: UFS PROTOCOL EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_020_results.json
```

**Note:** Consult hardware target documentation before executing hw_020.

---

## hw_021 — USB Glitch Attack

**Platform:** hardware

**What it does:** Executes usb glitch attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_021
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 021: EXECUTING
MODULE: USB GLITCH ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_021_results.json
```

**Note:** Consult hardware target documentation before executing hw_021.

---

## hw_022 — USB Fuzzing

**Platform:** hardware

**What it does:** Executes usb fuzzing using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_022
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 022: EXECUTING
MODULE: USB FUZZING
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_022_results.json
```

**Note:** Consult hardware target documentation before executing hw_022.

---

## hw_023 — HID Injection (BadUSB)

**Platform:** hardware

**What it does:** Executes hid injection (badusb) using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_023
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 023: EXECUTING
MODULE: HID INJECTION (BADUSB)
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_023_results.json
```

**Note:** Consult hardware target documentation before executing hw_023.

---

## hw_024 — HID Payload Editor

**Platform:** hardware

**What it does:** Executes hid payload editor using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_024
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 024: EXECUTING
MODULE: HID PAYLOAD EDITOR
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_024_results.json
```

**Note:** Consult hardware target documentation before executing hw_024.

---

## hw_025 — Rubber Ducky Emulation

**Platform:** hardware

**What it does:** Executes rubber ducky emulation using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_025
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 025: EXECUTING
MODULE: RUBBER DUCKY EMULATION
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_025_results.json
```

**Note:** Consult hardware target documentation before executing hw_025.

---

## hw_026 — LAN Turtle Mode

**Platform:** hardware

**What it does:** Executes lan turtle mode using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_026
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 026: EXECUTING
MODULE: LAN TURTLE MODE
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_026_results.json
```

**Note:** Consult hardware target documentation before executing hw_026.

---

## hw_027 — PCIe DMA Attack

**Platform:** hardware

**What it does:** Executes pcie dma attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_027
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 027: EXECUTING
MODULE: PCIE DMA ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_027_results.json
```

**Note:** Consult hardware target documentation before executing hw_027.

---

## hw_028 — Thunderbolt Attack

**Platform:** hardware

**What it does:** Executes thunderbolt attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_028
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 028: EXECUTING
MODULE: THUNDERBOLT ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_028_results.json
```

**Note:** Consult hardware target documentation before executing hw_028.

---

## hw_029 — FireWire DMA

**Platform:** hardware

**What it does:** Executes firewire dma using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_029
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 029: EXECUTING
MODULE: FIREWIRE DMA
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_029_results.json
```

**Note:** Consult hardware target documentation before executing hw_029.

---

## hw_030 — ExpressCard Exploit

**Platform:** hardware

**What it does:** Executes expresscard exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_030
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 030: EXECUTING
MODULE: EXPRESSCARD EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_030_results.json
```

**Note:** Consult hardware target documentation before executing hw_030.

---

## hw_031 — UART Command Injection

**Platform:** hardware

**What it does:** Executes uart command injection using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_031
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 031: EXECUTING
MODULE: UART COMMAND INJECTION
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_031_results.json
```

**Note:** Consult hardware target documentation before executing hw_031.

---

## hw_032 — UART Baud Rate Brute

**Platform:** hardware

**What it does:** Executes uart baud rate brute using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_032
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 032: EXECUTING
MODULE: UART BAUD RATE BRUTE
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_032_results.json
```

**Note:** Consult hardware target documentation before executing hw_032.

---

## hw_033 — I2C Bus Attack

**Platform:** hardware

**What it does:** Executes i2c bus attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_033
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 033: EXECUTING
MODULE: I2C BUS ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_033_results.json
```

**Note:** Consult hardware target documentation before executing hw_033.

---

## hw_034 — SPI Flash Dump

**Platform:** hardware

**What it does:** Executes spi flash dump using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_034
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 034: EXECUTING
MODULE: SPI FLASH DUMP
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_034_results.json
```

**Note:** Consult hardware target documentation before executing hw_034.

---

## hw_035 — SPI Flash Write

**Platform:** hardware

**What it does:** Executes spi flash write using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_035
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 035: EXECUTING
MODULE: SPI FLASH WRITE
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_035_results.json
```

**Note:** Consult hardware target documentation before executing hw_035.

---

## hw_036 — I2C EEPROM Dump

**Platform:** hardware

**What it does:** Executes i2c eeprom dump using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_036
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 036: EXECUTING
MODULE: I2C EEPROM DUMP
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_036_results.json
```

**Note:** Consult hardware target documentation before executing hw_036.

---

## hw_037 — CAN Bus Fuzzer

**Platform:** hardware

**What it does:** Executes can bus fuzzer using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_037
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 037: EXECUTING
MODULE: CAN BUS FUZZER
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_037_results.json
```

**Note:** Consult hardware target documentation before executing hw_037.

---

## hw_038 — LIN Bus Inject

**Platform:** hardware

**What it does:** Executes lin bus inject using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_038
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 038: EXECUTING
MODULE: LIN BUS INJECT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_038_results.json
```

**Note:** Consult hardware target documentation before executing hw_038.

---

## hw_039 — RS232 Exploit

**Platform:** hardware

**What it does:** Executes rs232 exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_039
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 039: EXECUTING
MODULE: RS232 EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_039_results.json
```

**Note:** Consult hardware target documentation before executing hw_039.

---

## hw_040 — RS485 Attack

**Platform:** hardware

**What it does:** Executes rs485 attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_040
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 040: EXECUTING
MODULE: RS485 ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_040_results.json
```

**Note:** Consult hardware target documentation before executing hw_040.

---

## hw_041 — Modbus TCP Exploit

**Platform:** hardware

**What it does:** Executes modbus tcp exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_041
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 041: EXECUTING
MODULE: MODBUS TCP EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_041_results.json
```

**Note:** Consult hardware target documentation before executing hw_041.

---

## hw_042 — Profibus Attack

**Platform:** hardware

**What it does:** Executes profibus attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_042
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 042: EXECUTING
MODULE: PROFIBUS ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_042_results.json
```

**Note:** Consult hardware target documentation before executing hw_042.

---

## hw_043 — EtherCAT Exploit

**Platform:** hardware

**What it does:** Executes ethercat exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_043
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 043: EXECUTING
MODULE: ETHERCAT EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_043_results.json
```

**Note:** Consult hardware target documentation before executing hw_043.

---

## hw_044 — Industrial Protocol Fuzzer

**Platform:** hardware

**What it does:** Executes industrial protocol fuzzer using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_044
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 044: EXECUTING
MODULE: INDUSTRIAL PROTOCOL FUZZER
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_044_results.json
```

**Note:** Consult hardware target documentation before executing hw_044.

---

## hw_045 — PLC Ladder Logic Inject

**Platform:** hardware

**What it does:** Executes plc ladder logic inject using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_045
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 045: EXECUTING
MODULE: PLC LADDER LOGIC INJECT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_045_results.json
```

**Note:** Consult hardware target documentation before executing hw_045.

---

## hw_046 — RTOS Exploit

**Platform:** hardware

**What it does:** Executes rtos exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_046
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 046: EXECUTING
MODULE: RTOS EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_046_results.json
```

**Note:** Consult hardware target documentation before executing hw_046.

---

## hw_047 — Bare Metal Exploit

**Platform:** hardware

**What it does:** Executes bare metal exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_047
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 047: EXECUTING
MODULE: BARE METAL EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_047_results.json
```

**Note:** Consult hardware target documentation before executing hw_047.

---

## hw_048 — Bootloader Exploit (ARM)

**Platform:** hardware

**What it does:** Executes bootloader exploit (arm) using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_048
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 048: EXECUTING
MODULE: BOOTLOADER EXPLOIT (ARM)
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_048_results.json
```

**Note:** Consult hardware target documentation before executing hw_048.

---

## hw_049 — Bootloader Exploit (MIPS)

**Platform:** hardware

**What it does:** Executes bootloader exploit (mips) using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_049
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 049: EXECUTING
MODULE: BOOTLOADER EXPLOIT (MIPS)
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_049_results.json
```

**Note:** Consult hardware target documentation before executing hw_049.

---

## hw_050 — Bootloader Exploit (RISC-V)

**Platform:** hardware

**What it does:** Executes bootloader exploit (risc-v) using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_050
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 050: EXECUTING
MODULE: BOOTLOADER EXPLOIT (RISC-V)
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_050_results.json
```

**Note:** Consult hardware target documentation before executing hw_050.

---

## hw_051 — Cortex-M Debug Exploit

**Platform:** hardware

**What it does:** Executes cortex-m debug exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_051
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 051: EXECUTING
MODULE: CORTEX-M DEBUG EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_051_results.json
```

**Note:** Consult hardware target documentation before executing hw_051.

---

## hw_052 — Cortex-A Debug Exploit

**Platform:** hardware

**What it does:** Executes cortex-a debug exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_052
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 052: EXECUTING
MODULE: CORTEX-A DEBUG EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_052_results.json
```

**Note:** Consult hardware target documentation before executing hw_052.

---

## hw_053 — JTAG Chain Scan

**Platform:** hardware

**What it does:** Executes jtag chain scan using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_053
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 053: EXECUTING
MODULE: JTAG CHAIN SCAN
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_053_results.json
```

**Note:** Consult hardware target documentation before executing hw_053.

---

## hw_054 — Boundary Scan Attack

**Platform:** hardware

**What it does:** Executes boundary scan attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_054
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 054: EXECUTING
MODULE: BOUNDARY SCAN ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_054_results.json
```

**Note:** Consult hardware target documentation before executing hw_054.

---

## hw_055 — TAP Controller Exploit

**Platform:** hardware

**What it does:** Executes tap controller exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_055
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 055: EXECUTING
MODULE: TAP CONTROLLER EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_055_results.json
```

**Note:** Consult hardware target documentation before executing hw_055.

---

## hw_056 — cJTAG Exploit

**Platform:** hardware

**What it does:** Executes cjtag exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_056
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 056: EXECUTING
MODULE: CJTAG EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_056_results.json
```

**Note:** Consult hardware target documentation before executing hw_056.

---

## hw_057 — SWD Debug Exploit

**Platform:** hardware

**What it does:** Executes swd debug exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_057
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 057: EXECUTING
MODULE: SWD DEBUG EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_057_results.json
```

**Note:** Consult hardware target documentation before executing hw_057.

---

## hw_058 — OpenOCD Integration

**Platform:** hardware

**What it does:** Executes openocd integration using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_058
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 058: EXECUTING
MODULE: OPENOCD INTEGRATION
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_058_results.json
```

**Note:** Consult hardware target documentation before executing hw_058.

---

## hw_059 — GDB Server Launch

**Platform:** hardware

**What it does:** Executes gdb server launch using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_059
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 059: EXECUTING
MODULE: GDB SERVER LAUNCH
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_059_results.json
```

**Note:** Consult hardware target documentation before executing hw_059.

---

## hw_060 — Debug Certificate Exploit

**Platform:** hardware

**What it does:** Executes debug certificate exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_060
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 060: EXECUTING
MODULE: DEBUG CERTIFICATE EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_060_results.json
```

**Note:** Consult hardware target documentation before executing hw_060.

---

## hw_061 — Production Fuse Blow

**Platform:** hardware

**What it does:** Executes production fuse blow using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_061
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 061: EXECUTING
MODULE: PRODUCTION FUSE BLOW
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_061_results.json
```

**Note:** Consult hardware target documentation before executing hw_061.

---

## hw_062 — Fuse Override Attack

**Platform:** hardware

**What it does:** Executes fuse override attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_062
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 062: EXECUTING
MODULE: FUSE OVERRIDE ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_062_results.json
```

**Note:** Consult hardware target documentation before executing hw_062.

---

## hw_063 — OTP Memory Attack

**Platform:** hardware

**What it does:** Executes otp memory attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_063
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 063: EXECUTING
MODULE: OTP MEMORY ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_063_results.json
```

**Note:** Consult hardware target documentation before executing hw_063.

---

## hw_064 — eFuse Manipulation

**Platform:** hardware

**What it does:** Executes efuse manipulation using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_064
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 064: EXECUTING
MODULE: EFUSE MANIPULATION
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_064_results.json
```

**Note:** Consult hardware target documentation before executing hw_064.

---

## hw_065 — Trim Bit Attack

**Platform:** hardware

**What it does:** Executes trim bit attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_065
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 065: EXECUTING
MODULE: TRIM BIT ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_065_results.json
```

**Note:** Consult hardware target documentation before executing hw_065.

---

## hw_066 — Analog Calibration Exploit

**Platform:** hardware

**What it does:** Executes analog calibration exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_066
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 066: EXECUTING
MODULE: ANALOG CALIBRATION EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_066_results.json
```

**Note:** Consult hardware target documentation before executing hw_066.

---

## hw_067 — ADC Injection

**Platform:** hardware

**What it does:** Executes adc injection using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_067
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 067: EXECUTING
MODULE: ADC INJECTION
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_067_results.json
```

**Note:** Consult hardware target documentation before executing hw_067.

---

## hw_068 — DAC Manipulation

**Platform:** hardware

**What it does:** Executes dac manipulation using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_068
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 068: EXECUTING
MODULE: DAC MANIPULATION
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_068_results.json
```

**Note:** Consult hardware target documentation before executing hw_068.

---

## hw_069 — Comparator Glitch

**Platform:** hardware

**What it does:** Executes comparator glitch using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_069
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 069: EXECUTING
MODULE: COMPARATOR GLITCH
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_069_results.json
```

**Note:** Consult hardware target documentation before executing hw_069.

---

## hw_070 — Watchdog Bypass

**Platform:** hardware

**What it does:** Executes watchdog bypass using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_070
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 070: EXECUTING
MODULE: WATCHDOG BYPASS
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_070_results.json
```

**Note:** Consult hardware target documentation before executing hw_070.

---

## hw_071 — Brown-Out Reset Exploit

**Platform:** hardware

**What it does:** Executes brown-out reset exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_071
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 071: EXECUTING
MODULE: BROWN-OUT RESET EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_071_results.json
```

**Note:** Consult hardware target documentation before executing hw_071.

---

## hw_072 — Power Management IC Attack

**Platform:** hardware

**What it does:** Executes power management ic attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_072
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 072: EXECUTING
MODULE: POWER MANAGEMENT IC ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_072_results.json
```

**Note:** Consult hardware target documentation before executing hw_072.

---

## hw_073 — Voltage Regulator Exploit

**Platform:** hardware

**What it does:** Executes voltage regulator exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_073
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 073: EXECUTING
MODULE: VOLTAGE REGULATOR EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_073_results.json
```

**Note:** Consult hardware target documentation before executing hw_073.

---

## hw_074 — LDO Bypass

**Platform:** hardware

**What it does:** Executes ldo bypass using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_074
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 074: EXECUTING
MODULE: LDO BYPASS
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_074_results.json
```

**Note:** Consult hardware target documentation before executing hw_074.

---

## hw_075 — Switching Regulator Attack

**Platform:** hardware

**What it does:** Executes switching regulator attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_075
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 075: EXECUTING
MODULE: SWITCHING REGULATOR ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_075_results.json
```

**Note:** Consult hardware target documentation before executing hw_075.

---

## hw_076 — RF Power Amplifier Attack

**Platform:** hardware

**What it does:** Executes rf power amplifier attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_076
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 076: EXECUTING
MODULE: RF POWER AMPLIFIER ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_076_results.json
```

**Note:** Consult hardware target documentation before executing hw_076.

---

## hw_077 — Oscillator Crystal Attack

**Platform:** hardware

**What it does:** Executes oscillator crystal attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_077
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 077: EXECUTING
MODULE: OSCILLATOR CRYSTAL ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_077_results.json
```

**Note:** Consult hardware target documentation before executing hw_077.

---

## hw_078 — PLL Manipulation

**Platform:** hardware

**What it does:** Executes pll manipulation using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_078
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 078: EXECUTING
MODULE: PLL MANIPULATION
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_078_results.json
```

**Note:** Consult hardware target documentation before executing hw_078.

---

## hw_079 — Clock Tree Attack

**Platform:** hardware

**What it does:** Executes clock tree attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_079
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 079: EXECUTING
MODULE: CLOCK TREE ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_079_results.json
```

**Note:** Consult hardware target documentation before executing hw_079.

---

## hw_080 — Reset Line Glitch

**Platform:** hardware

**What it does:** Executes reset line glitch using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_080
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 080: EXECUTING
MODULE: RESET LINE GLITCH
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_080_results.json
```

**Note:** Consult hardware target documentation before executing hw_080.

---

## hw_081 — RESET# Pin Attack

**Platform:** hardware

**What it does:** Executes reset# pin attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_081
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 081: EXECUTING
MODULE: RESET# PIN ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_081_results.json
```

**Note:** Consult hardware target documentation before executing hw_081.

---

## hw_082 — NMI Exploit

**Platform:** hardware

**What it does:** Executes nmi exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_082
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 082: EXECUTING
MODULE: NMI EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_082_results.json
```

**Note:** Consult hardware target documentation before executing hw_082.

---

## hw_083 — Hardware Security Module Attack

**Platform:** hardware

**What it does:** Executes hardware security module attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_083
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 083: EXECUTING
MODULE: HARDWARE SECURITY MODULE ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_083_results.json
```

**Note:** Consult hardware target documentation before executing hw_083.

---

## hw_084 — TPM 1.2 Attack

**Platform:** hardware

**What it does:** Executes tpm 1.2 attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_084
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 084: EXECUTING
MODULE: TPM 1.2 ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_084_results.json
```

**Note:** Consult hardware target documentation before executing hw_084.

---

## hw_085 — TPM 2.0 Attack

**Platform:** hardware

**What it does:** Executes tpm 2.0 attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_085
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 085: EXECUTING
MODULE: TPM 2.0 ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_085_results.json
```

**Note:** Consult hardware target documentation before executing hw_085.

---

## hw_086 — SmartCard Glitch

**Platform:** hardware

**What it does:** Executes smartcard glitch using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_086
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 086: EXECUTING
MODULE: SMARTCARD GLITCH
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_086_results.json
```

**Note:** Consult hardware target documentation before executing hw_086.

---

## hw_087 — EMV Card Attack

**Platform:** hardware

**What it does:** Executes emv card attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_087
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 087: EXECUTING
MODULE: EMV CARD ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_087_results.json
```

**Note:** Consult hardware target documentation before executing hw_087.

---

## hw_088 — Contactless Card Clone

**Platform:** hardware

**What it does:** Executes contactless card clone using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_088
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 088: EXECUTING
MODULE: CONTACTLESS CARD CLONE
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_088_results.json
```

**Note:** Consult hardware target documentation before executing hw_088.

---

## hw_089 — NFC Secure Element Attack

**Platform:** hardware

**What it does:** Executes nfc secure element attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_089
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 089: EXECUTING
MODULE: NFC SECURE ELEMENT ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_089_results.json
```

**Note:** Consult hardware target documentation before executing hw_089.

---

## hw_090 — Bluetooth Chip Exploit

**Platform:** hardware

**What it does:** Executes bluetooth chip exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_090
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 090: EXECUTING
MODULE: BLUETOOTH CHIP EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_090_results.json
```

**Note:** Consult hardware target documentation before executing hw_090.

---

## hw_091 — Wi-Fi Chip Exploit

**Platform:** hardware

**What it does:** Executes wi-fi chip exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_091
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 091: EXECUTING
MODULE: WI-FI CHIP EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_091_results.json
```

**Note:** Consult hardware target documentation before executing hw_091.

---

## hw_092 — Cellular Modem Exploit

**Platform:** hardware

**What it does:** Executes cellular modem exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_092
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 092: EXECUTING
MODULE: CELLULAR MODEM EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_092_results.json
```

**Note:** Consult hardware target documentation before executing hw_092.

---

## hw_093 — GPS Module Attack

**Platform:** hardware

**What it does:** Executes gps module attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_093
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 093: EXECUTING
MODULE: GPS MODULE ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_093_results.json
```

**Note:** Consult hardware target documentation before executing hw_093.

---

## hw_094 — Sensor Fusion Exploit

**Platform:** hardware

**What it does:** Executes sensor fusion exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_094
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 094: EXECUTING
MODULE: SENSOR FUSION EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_094_results.json
```

**Note:** Consult hardware target documentation before executing hw_094.

---

## hw_095 — Camera Module Attack

**Platform:** hardware

**What it does:** Executes camera module attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_095
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 095: EXECUTING
MODULE: CAMERA MODULE ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_095_results.json
```

**Note:** Consult hardware target documentation before executing hw_095.

---

## hw_096 — Microphone ADC Glitch

**Platform:** hardware

**What it does:** Executes microphone adc glitch using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_096
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 096: EXECUTING
MODULE: MICROPHONE ADC GLITCH
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_096_results.json
```

**Note:** Consult hardware target documentation before executing hw_096.

---

## hw_097 — Speaker DAC Attack

**Platform:** hardware

**What it does:** Executes speaker dac attack using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_097
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 097: EXECUTING
MODULE: SPEAKER DAC ATTACK
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_097_results.json
```

**Note:** Consult hardware target documentation before executing hw_097.

---

## hw_098 — Display Controller Exploit

**Platform:** hardware

**What it does:** Executes display controller exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_098
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 098: EXECUTING
MODULE: DISPLAY CONTROLLER EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_098_results.json
```

**Note:** Consult hardware target documentation before executing hw_098.

---

## hw_099 — Touchscreen Exploit

**Platform:** hardware

**What it does:** Executes touchscreen exploit using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_099
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 099: EXECUTING
MODULE: TOUCHSCREEN EXPLOIT
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_099_results.json
```

**Note:** Consult hardware target documentation before executing hw_099.

---

## hw_100 — Accelerometer Spoof

**Platform:** hardware

**What it does:** Executes accelerometer spoof using Pandora Mk.1 hardware attack platform. Part of the hardware security assessment and exploitation toolkit.

**How to run:**
1. Hardware Glitch → hw_100
2. Connect Pandora Mk.1 to target hardware
3. Configure attack parameters
4. Execute and monitor results

**Expected output:**
```
HARDWARE GLITCH 100: EXECUTING
MODULE: ACCELEROMETER SPOOF
PANDORA Mk.1: CONNECTED
STATUS: OPERATIONAL
SAVED: /Evidence/glitch/hw_100_results.json
```

**Note:** Consult hardware target documentation before executing hw_100.

---

