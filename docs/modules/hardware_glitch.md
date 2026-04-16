# Hardware Glitch — Module How-To Guide
**Category:** `hardware_glitch` | **Module Count:** 100

The Hardware Glitch category covers physical-layer attacks using the Pandora Mk.1 USB Glitcher and Pandora Titan's hardware interfaces. These modules exploit voltage, timing, and signal anomalies to bypass hardware security.

---

## Overview

Hardware glitch attacks work by sending precisely timed electrical pulses or clock disruptions to a target chip, causing it to skip security checks or expose protected memory. The Pandora Mk.1 (RP2040-based) is the primary tool for these attacks.

**Prerequisites:**
- Pandora Mk.1 connected to Pandora Omega/Titan via USB
- Target device connected to Mk.1 glitch output header
- Target identified and timing profile loaded

---

## How to Run Any Hardware Glitch Module

1. Connect Pandora Mk.1 to the target device's USB/UART/JTAG port
2. Open Janus TUI → **Hardware Glitch**
3. Select a module number (hw_001 through hw_100)
4. Set glitch parameters if prompted (voltage offset, timing delay)
5. Execute and monitor the log pane for success/retry signals

---

## Module Index by Function

| Range | Focus Area |
|---|---|
| hw_001 – hw_010 | Voltage fault injection (VFI) basics |
| hw_011 – hw_020 | Clock glitching — CPU timing attacks |
| hw_021 – hw_030 | JTAG/UART unlocking and debug port exposure |
| hw_031 – hw_040 | Secure boot bypass via power rail manipulation |
| hw_041 – hw_050 | Bootloader unlock via glitch timing profiles |
| hw_051 – hw_060 | Flash memory extraction under fault conditions |
| hw_061 – hw_070 | Microcontroller (MCU) security fuse bypass |
| hw_071 – hw_080 | SIM card cloning via hardware interface |
| hw_081 – hw_090 | Smartcard and NFC chip fault attacks |
| hw_091 – hw_100 | TPM and secure enclave glitch extraction |

---

## Key Concepts

**Voltage Fault Injection (VFI):** A brief power spike causes the CPU to misbehave — often skipping a security comparison instruction. Modules hw_001–010 use the Mk.1's voltage rail tap.

**Clock Glitching:** Injecting a narrow pulse into the clock line causes the CPU to execute an extra or partial instruction cycle. Modules hw_011–020 use the Mk.1's clock output header.

**JTAG Unlock:** Many devices have JTAG debug ports disabled by fuse bits. Modules hw_021–030 use glitch + JTAG sequences to re-enable the port.

---

## Expected Output (all modules)

```
HARDWARE GLITCH MODULE [N]: ARMED
TARGET: [DEVICE / CHIP]
GLITCH PARAMETERS: V=+0.3V | DELAY=200ns | DURATION=50ns
ATTEMPT 1/10...
SUCCESS: TARGET RESPONDED AT ATTEMPT 3
DATA CAPTURED
```

---

## Tips

- If a module fails 10 attempts, try adjusting the voltage offset (±0.1V increments)
- hw_031–040 (secure boot bypass) are the most effective against modern Qualcomm and MediaTek chips
- Always run hw_001 first to characterize the target's power profile before running advanced modules
- The Pandora Titan can run glitch modules wirelessly against the Mk.1 via Bluetooth 5.3
