# HARDWARE SPECS — Pandora Titan Series
**VAULT-TEC APPROVED • READY FOR MANUFACTURING**

## 1. Pandora Titan (Forearm-Mounted Tactical Singularity)

**Core Board (8-10 layer HDI PCB, ~125x85mm forearm-optimized):**
- SoC: Radxa CM5 (RK3588S class) or Snapdragon 8 Elite equivalent with strong Linux GPU drivers
- RAM: 32GB soldered LPDDR5X + configurable virtual RAM expansion up to 64GB (zRAM + fast UFS 4.0/NVMe swap via STAT tab slider)
- **Storage**: **3x M.2 bays** (user-accessible via internal hatch):
  - M.2 2280: Hailo-8 AI accelerator (PCIe Gen3 x2, high-speed)
  - M.2 2242: Primary NVMe storage (fast OS and data)
  - M.2 2230: Secondary NVMe or LimeSDR Mini (flexible expansion)
- AI Accelerator: Hailo-8 M.2 (PCIe Gen3 x2)
- SDR: LimeSDR Mini 2.0 (USB3 or direct PCIe bridge)
- Display: 7" 1280x480 ultra-widescreen capacitive touchscreen (MIPI-DSI)
- Controls: Brass master toggle, dual rotary knobs (sync/gain), 5-way joystick, chorded mechanical key array, guarded red panic toggle, haptic side-pads
- Connectivity: Dual SIM (waterproof), high-gain MIMO antenna array, multiple USB-C/Thunderbolt-style ports (one for docking/eGPU, one for Flipper Zero)
- Power: Mjolnir hot-swap 21700 battery system with wireless charging receiver (bottom of chassis)
- Protection: TVS diodes + ferrite beads on all I/O, EMP hardening, graphene thermal pads

**Housing (as per original spec):**
- High-impact reinforced polymer with 6061 Aluminum internal skeleton
- IP68 certified with silicone gaskets and sealed port covers
- MIL-STD-810H compliant rubberized bumpers and internal vibration dampening
- Olive-drab weathered retro-future Vault-Tec aesthetic with exposed brass hardware
- Ergonomic curved forearm mount with heavy-duty nylon straps
- Internal M.2 access hatch (shock-resistant, aligned with the 3 bays)

**Cost Impact of 3 M.2 Bays:** +$80–120 per unit (connectors, routing, thermal management).

**Ready for Manufacturing:**
- Send this file to PCB manufacturers (JLCPCB/PCBWay) for the main board.
- Send housing CAD descriptions (Fusion 360/STEP) for injection molding.
- The 3 M.2 bays are configured for maximum flexibility: AI, storage, and expansion.

## 2. Pandora Omega (Handheld Cyberdeck)
- Carbon fiber chassis, mechanical keyboard, trackball, shoulder triggers, antenna toggles, Faraday-lined storage, active cooling with graphene pads.

## 3. Monolith (Display Stand)
- Weighted black anodized aluminum base, 15W Qi wireless charging, USB-C 3.2 passthrough.

## 4. Forge (Battery Dock)
- Charges 4x Mjolnir 21700 batteries with 100W PD, cyan breathing LEDs per slot.

## 5. Dongle (Flipper Enhanced Companion)
- STM32H7 + ESP32, full Sub-GHz/NFC/IR/GPIO/BadUSB with direct Janus serial control.

## 6. Dual-Screen Tablet
- RK3588-based with dual MIPI displays, 16-24GB RAM, NVMe, convergence support.

**All files are ready for manufacturers.**
**Send this document + KiCad files + Fusion 360 models.**
