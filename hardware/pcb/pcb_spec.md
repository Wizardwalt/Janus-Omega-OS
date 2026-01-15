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
- Dual USB-C (1x Data, 1x Power/Glitch)
- 40-Pin GPIO Header (Internal)
- SMA Antenna Connectors x3
