# Pandora Titan PCB Specification (Draft)

## Core Components
- **MCU**: RP2040 (Mk.1 compatibility) + Radxa CM5 SOM (8-Core ARM)
- **Radio Array (Hydra)**:
  - CC1101 (Sub-GHz)
  - PN532 (NFC)
  - RTL-SDR Integrated Circuit
  - DWM3000 (UWB)
- **Power Management**: Kinetic Harvester Controller + IP5328P (100W PD)
- **Sensors**: FLIR Lepton 3.5 (Thermal), MLX90614 (IR Temp), BME680 (CBRN)

## Layer Stackup
- 4-Layer PCB
- Top: Signal + Components
- Mid 1: Ground Plane
- Mid 2: Power Plane (3.3V, 5V, 12V)
- Bottom: Signal + Haptic Drivers

## Connectivity
- **5G/LTE Cellular**: Quectel RM520N-GL (Sub-6GHz/LTE Cat 19)
- **SIM**: Integrated Nano-SIM Slot + eSIM Support
- **Wi-Fi/BT**: Intel AX210 Wi-Fi 6E / Bluetooth 5.3
- **Wired**: Dual USB-C (1x Data, 1x Power/Glitch)
- **Antennas**: High-gain internal MIMO antenna array
- **Expansion**: 40-Pin GPIO Header (Internal)

## Storage Interface
- **M.2 NVMe**: 3x M.2 slots (PCIe Gen 4)
  - Slot 1: Primary OS Drive
  - Slot 2: Secondary Data Drive
  - Slot 3: Janus GPU Accelerator (Hailo-8/Orin Nano)
- **MicroSD**: 1x MicroSD Card Slot (UHS-I, Integrated into chassis)
- **Architecture**: PCIe lane muxing via Radxa CM5 for simultaneous multi-drive support.
