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
- **Flipper Zero Integration**:
  - Built-in submodule on main board: Full Sub-GHz (TX/RX/scan), NFC/RFID (13.56MHz + 125kHz read/write/emulate), IR transmit, BadUSB, GPIO (8 pins), iButton/1-Wire, speaker/LED control
  - Dedicated USB-C OTG port (waterproof sealed) for external physical Flipper Zero (auto-detected, Companion Mode)
- AI Accelerator: Hailo-8 M.2 (PCIe Gen3 x2)
- SDR: LimeSDR Mini 2.0 (USB3 or direct PCIe bridge)
- Display: 7" 1280x480 ultra-widescreen capacitive touchscreen (MIPI-DSI)
- Controls: Brass master toggle, dual rotary knobs (sync/gain), 5-way joystick, chorded mechanical key array, guarded red panic toggle, haptic side-pads
- Connectivity: Dual SIM (waterproof), high-gain MIMO antenna array, multiple USB-C/Thunderbolt-style ports
- Power: Mjolnir hot-swap 21700 battery system with wireless charging receiver (bottom of chassis)
- Protection: TVS diodes + ferrite beads on all I/O, EMP hardening, graphene thermal pads

**Housing (as per original spec):**
- High-impact reinforced polymer with 6061 Aluminum internal skeleton
- IP68 certified with silicone gaskets and sealed port covers
- MIL-STD-810H compliant rubberized bumpers and internal vibration dampening
- Olive-drab weathered retro-future Vault-Tec aesthetic with exposed brass hardware
- Ergonomic curved forearm mount with heavy-duty nylon straps
- Internal M.2 access hatch (shock-resistant, aligned with the 3 bays)

**Manufacturing Notes:**
- PCBs: JLCPCB or PCBWay (specify 8-10 layer HDI with 3 M.2 bays and built-in Flipper submodule)
- Housing: 3D print prototype in PETG, then injection mold in high-impact polymer
- Assembly: Seeed Studio or PCBWay for full assembly + testing
- Total prototype cost per unit: $1,650 – $2,200 (including 3 M.2 bays and Flipper submodule)

**Ready to send to manufacturers.**
