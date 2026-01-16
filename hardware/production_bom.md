# Janus Titan Omega - Production Bill of Materials (BOM)

## 1. Core Electronics (Pandora Titan)
| Item | Source | Est. Cost (USD) |
| :--- | :--- | :--- |
| Radxa CM5 SOM (16GB RAM) | OKDO / Radxa Distro | $150.00 |
| RP2040 Microcontroller | DigiKey / Mouser | $1.00 |
| 7" Ultra-Wide Touchscreen (1280x480) | Waveshare / BuyDisplay | $85.00 |
| Quectel RM520N-GL 5G Module | AliExpress / Quectel | $180.00 |
| Intel AX210 Wi-Fi 6E/BT 5.3 | Amazon / DigiKey | $25.00 |
| CC1101 Sub-GHz Transceiver | Amazon / TI | $15.00 |
| PN532 NFC Module | Adafruit / Amazon | $20.00 |
| RTL-SDR Integrated IC | DigiKey | $30.00 |
| FLIR Lepton 3.5 Thermal Cam | GroupGets / DigiKey | $250.00 |
| Custom 4-Layer Main PCB | JLCPCB / PCBWay | $50.00 (Batch) |
| 2x 1TB NVMe Gen 4 SSD | Samsung / WD | $160.00 |
| 1TB MicroSD Card (Extreme) | SanDisk | $90.00 |
| Hailo-8 M.2 AI Accelerator | Hailo / DigiKey | $180.00 |
| **Total Electronics** | | **~$1,271.00** |

## 2. Housing & Chassis
| Item | Source | Est. Cost (USD) |
| :--- | :--- | :--- |
| SLS 3D Printed Chassis (PA12-CF) | Shapeways / Protolabs | $200.00 |
| CNC Aluminum Faceplate (6061) | Xometry / SendCutSend | $80.00 |
| Gorilla Glass 5 Panel | Custom Fabricator | $40.00 |
| IP68 Gasket & Seal Kit | McMaster-Carr | $20.00 |
| Heavy Duty Nylon Straps | Amazon | $15.00 |
| **Total Housing** | | **~$355.00** |

## 3. Power & Accessories (Monolith & Forge)
| Item | Source | Est. Cost (USD) |
| :--- | :--- | :--- |
| 4x 21700 Li-ion Cells (Mjolnir) | 18650BatteryStore | $40.00 |
| IP5328P 100W PD Controller | AliExpress | $10.00 |
| Wireless Charging Qi Coils | DigiKey | $15.00 |
| Monolith Aluminum Stand Base | Xometry | $60.00 |
| Forge Charging Dock PCB | JLCPCB | $20.00 |
| **Total Power** | | **~$145.00** |

---

## Manufacturing & Assembly Guide

### 1. PCB Fabrication & SMT Assembly
- **Recommended**: [JLCPCB](https://jlcpcb.com) or [PCBWay](https://pcbway.com).
- **Process**: Upload the Gerber files (from `hardware/pcb/`) and the BOM/CPL files. They can source most components and perform SMT assembly for you.

### 2. Housing Fabrication
- **Plastic Parts**: Use [Protolabs](https://www.protolabs.com) or [Xometry](https://www.xometry.com) for SLS 3D printing in PA12 Carbon Fiber.
- **Metal Parts**: Use [SendCutSend](https://sendcutsend.com) or Xometry for CNC machining the aluminum faceplate.

### 3. Final Assembly
- **Process**: 
  1. Install the assembled PCB into the internal aluminum skeleton.
  2. Apply silicone gaskets to all mating surfaces.
  3. Mount the 10" display and Gorilla Glass.
  4. Seal the chassis and perform a vacuum pressure test for IP68 certification.
  5. Flash the JanusOS ISO to the Radxa CM5.

**Estimated Total Build Cost per Unit: ~$1,341.00** (Excluding labor/shipping)
