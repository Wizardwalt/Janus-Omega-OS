# HARDWARE SPECS — Pandora Titan Series (Draft; Not Manufacturing Approved)

> **Status: CONCEPT DRAFT — NOT READY FOR FABRICATION OR MANUFACTURING.** The component names and values below are unverified design candidates, not a released specification or validated bill of materials. No completed Titan prototype, production PCB layout, controlled CAD/Gerber package, antenna schedule, thermal/power validation, carrier approval, or RF/EMC/SAR evidence is recorded in this repository.


**Pandora Titan Core Board:**
- SoC: Radxa CM5 class
- RAM: 32GB LPDDR5X + 64GB virtual RAM
- **Storage**: **3x M.2 bays** (Hailo-8, primary NVMe, secondary NVMe/LimeSDR)
- **Flipper Zero Integration**: Built-in submodule (full Sub-GHz, NFC, IR, BadUSB, GPIO) + dedicated USB-C OTG port for external Flipper Zero
- Display: 7" 1280x480 ultra-widescreen
- Controls: Brass toggle, dual rotary knobs, haptic pads, panic toggle
- Housing: IP68 polymer with aluminum skeleton

**Manufacturing status: not approved.** Resolve conflicts with hardware/production_bom.md, hardware/pcb/pcb_spec.md, and hardware/pcb/schematic_master.md before selecting parts or ordering boards. In particular, the repository currently contains inconsistent memory/display/board descriptions, and the text block diagram is not a production schematic.
