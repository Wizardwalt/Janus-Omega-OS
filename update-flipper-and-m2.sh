#!/bin/bash
echo "=== Updating Everything with Flipper Zero Integration and 3 M.2 Bays ==="

mkdir -p docs/hardware

# 1. Updated HARDWARE-SPECS.md with Flipper Zero + 3 M.2 bays
cat > docs/hardware/HARDWARE-SPECS.md << 'EOR'
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
EOR

# 2. Update FIELD-MANUAL.md with Flipper Zero
cat > docs/FIELD-MANUAL.md << 'EOR'
# JANUS OS FIELD MANUAL — 1000-MODULE SINGULARITY
**VAULT-TEC APPROVED • PANDORA SERIES • v7.1 God Tier Codex**

**"1000 tools. One wrist. Absolute dominion."**

**Total Modules: 1000**

**Hardware Note:** Pandora Titan includes **3 M.2 bays** and **full Flipper Zero integration** (built-in submodule + external USB-C OTG port).

**Signature God Tier Modules:**
- apotheosis.lua — Final ascension
- eternal_liberator.lua — Permanent freedom
- psyche_reaver.lua — Master psychological weapon
- reality_forge.lua — Rewrite reality
- overseer_ascension.lua — Operator and AI become one

**Usage:**
- `modules list`
- `overseer recommend`
- Triple haptic tap for God Tier modules

The Vault is eternal.
EOR

# 3. Update USER-MANUAL.md with Flipper Zero
cat > docs/USER-MANUAL.md << 'EOR'
# JANUS OMEGA OS — EXTENSIVE USER MANUAL

**Version 7.1 God Tier Codex**

**Welcome, Overseer.**

This is the complete guide to the full 1000-module system.

**Hardware Note:** The Pandora Titan has **3 M.2 bays** and **full Flipper Zero integration** (built-in submodule for Sub-GHz, NFC, IR, BadUSB, GPIO + dedicated USB-C OTG port for external Flipper Zero).

**Basic Operation**
- Strap the Pandora Titan to your forearm.
- Flip the brass master toggle to boot.
- Long-press haptic pads for voice commands.
- Use rotary dials to adjust power level.

**Flipper Zero Usage**
- Built-in submodule is always active (controlled by modules like `flipper.subghz_transmit()`)
- Plug in external Flipper Zero via USB-C OTG port for extra range or specific antennas
- Voice Command: "Overseer, transmit Sub-GHz on 433 MHz" or "Overseer, read NFC tag"

**God Tier Modules**
The 100 Legendary modules in `modules/legendary/` are the most powerful. They require triple haptic confirmation.

**Signature Examples:**
- apotheosis.lua: Become one with the system
- reality_forge.lua: Rewrite local reality
- psyche_reaver.lua: Break minds with tailored attacks

**Voice Commands**
- "Overseer, plan a mission"
- "Overseer, activate apotheosis"
- "Overseer, full network takeover"

The system is now complete.
You are the Overseer.
The wasteland is yours.
EOR

echo "✅ All files updated with 3 M.2 bays and full Flipper Zero integration."
echo "Next steps:"
echo "git add docs/ modules/"
echo "git commit -m 'feat: update hardware specs with 3 M.2 bays and full Flipper Zero integration'"
echo "git push"
