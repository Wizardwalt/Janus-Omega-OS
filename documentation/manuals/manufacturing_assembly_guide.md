# Janus Titan Omega: Manufacturing & Assembly Master Guide
## "Industrial Fabrication Specifications for Pandora Systems"

### 1. OVERVIEW
This document provides the technical specifications required to manufacture and assemble the three core Janus hardware systems: **Pandora Titan**, **Pandora Omega**, and **Pandora Mk.1**. 

---

### 2. PANDORA TITAN (Forearm-Mounted Terminal)
**Form Factor**: 7-inch Ultra-Widescreen (21:9) Rugged Forearm Terminal.
**Aesthetic**: "Vault-Tec" Heavy Industrial (Weathered Olive Drab, Brass Hardware).

#### Bill of Materials (BOM):
- **Core**: Radxa CM5 (8-Core, 16GB RAM).
- **Display**: 7" 1280x480 High-Brightness LCD with custom CRT-style filter overlay.
- **Radios**: Quectel RM520N-GL (5G), Intel AX210 (Wi-Fi 6E), Hailo-8 AI Accelerator.
- **Housing**: CNC-milled 6061 Aluminum with Cerakote finish.
- **Battery**: Dual 21700 Lithium-Ion cells in parallel.

#### Assembly Instructions:
1.  **Chassis**: Install the main 6061 aluminum housing with ballistic nylon strap anchors.
2.  **Display**: Seat the ultrawide panel and calibrate the analog sync knobs.
3.  **Electronics**: Mount the Radxa CM5 to the carrier board; attach the 5G and SDR antenna arrays to the side-mounted brass ports.
4.  **Sealing**: Apply IP68-rated silicone gaskets to all mechanical toggles and port covers.

---

### 3. PANDORA OMEGA (Handheld Cyberdeck)
**Form Factor**: Dual-Screen Handheld Cyberdeck with Integrated Keyboard.
**Aesthetic**: Carbon Fiber / Tactical Black with Purple Accents.

#### Bill of Materials (BOM):
- **Core**: Radxa CM5 (8-Core, 16GB RAM).
- **Screens**: Primary 5.5" OLED + Secondary 2.1" Status Display.
- **Keyboard**: Custom 40% Mechanical Keyboard (Kailh Choc Low-Profile Switches).
- **Housing**: Vacuum-infused Carbon Fiber with integrated magnesium roll-cage.

#### Assembly Instructions:
1.  **Frame**: Secure the magnesium roll-cage within the carbon fiber shell.
2.  **Keyboard**: Solder the mechanical switches to the custom PCB; mount the plate-mount stabilizers.
3.  **Cooling**: Install the active heat-pipe and blower fan assembly over the CM5 module.
4.  **Finish**: Apply the purple anodized accents to the shoulder triggers and antenna ports.

---

### 4. PANDORA MK.1 (USB Glitcher)
**Form Factor**: Compact USB-C Precision Auditing Tool.

#### Bill of Materials (BOM):
- **Microcontroller**: RP2040.
- **Interface**: Gold-plated USB-C Male Connector.
- **Indicators**: WS2812B RGB LED Ring (12 pixels).
- **Housing**: Transparent Polycarbonate with textured grip.

#### Assembly Instructions:
1.  **PCB**: Solder the RP2040 and gold-plated connector to the ultra-thin 2-layer PCB.
2.  **Mounting**: Press-fit the PCB into the polycarbonate shell.
3.  **Testing**: Flash the initial Janus-Glitch-Core firmware and verify RGB ring status.

---

### 5. SOFTWARE PROVISIONING
All units must be flashed with the **JanusOS Green & Purple Singularity ISO**.
1.  **Format**: Ensure NVMe drives are formatted to F2FS for flash durability.
2.  **Loading**: Load all 200 modules into `/opt/janus/plugins/`.
3.  **Lockdown**: Enable the hardware-locked BIOS and Kyber-1024 encryption keys.
