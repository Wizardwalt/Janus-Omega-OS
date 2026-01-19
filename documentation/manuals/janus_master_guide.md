# JanusOS Master Operations Manual: 200-Module Singularity

## I. HARDWARE INTERFACE: PANDORA TITAN (7" ULTRW-WIDE PIP-BOY)

### 1. Physical Controls & Buttons
- **The Brass Master Toggle (Side Left)**: Primary power. Flip up to engage the boot sequence.
- **Top Rotary Dial (Large)**: Screen Horizontal Sync. Adjust this if the monochrome green interface starts to "roll" or flicker.
- **Bottom Rotary Dial (Small)**: Brightness/Gain. Controls the intensity of the green/purple phosphor glow.
- **The Red 'Panic' Toggle (Recessed)**: Instant memory wipe. Flipping this and pressing the tactical button will initiate a Zero-Fill on the RAM and active NVMe partitions.
- **Haptic Side-Pads**: Located on the inner wrist. These detect neural haptics; tapping twice launches the "Neural-Sync" calibration module.
- **Mjolnir Hatch (Rear)**: Press and slide to hot-swap dual 21700 batteries without powering down.

---

## II. SOFTWARE INTERFACE: THE JANUS OMEGA TERMINAL

### 1. Navigation
- **Left/Right Arrows**: Cycle between **Dashboard** (System Health), **Ops** (Module Launcher), and **Hardware** (Radios/Antennas).
- **Up/Down Arrows**: Scroll through the 200-module list in the 'Ops' tab.
- **Enter Key**: Execute the selected module.
- **'Q' Key**: Clean exit. (Note: JanusOS is RAM-only; exiting will lose unsaved logs).
- **'G' Key**: Hardware Glitch Trigger. Manually fires the Pandora Mk.1 voltage injector if connected via USB.

---

## III. THE 200-MODULE SINGULARITY (OPERATIONS GUIDE)

The system contains 200 specialized Lua modules. Here is the operational breakdown by mission category:

### 1. Mobile Intelligence (60 Modules)
- **`alchemist.lua`**: Connect via USB (Mk.1 required). Bypass Google FRP and Bootloader locks using a voltage-injection glitch.
- **`dragnet.lua`**: Automated root extraction for Android. Use the "Sideload" option for devices with locked kernels.
- **`resurrection.lua`**: Un-brick device. Scans for valid firmware on the NVMe expansion and flashes via Fastboot/Odin protocol.
- **`timeline.lua`**: Reconstructs a user's day. Extracts SQLite databases and creates a chronologically merged map of texts, calls, and app activity.

### 2. Network Warfare (50 Modules)
- **`marauder.lua`**: Wireless interception. De-authenticates all users in range and captures WPA3 handshakes for local cracking.
- **`ssl_strip.lua`**: Downgrade attacks. Forces HTTPS connections into HTTP to capture login credentials on local Wi-Fi.
- **`cellular_scan.lua`**: Uses the 5G Hydra Radio to map all IMSI/IMEI numbers currently connected to the local cell tower.

### 3. Signals Intelligence - SIGINT (40 Modules)
- **`oracle.lua`**: Correlates radio signatures with OSINT databases. Tells you who own the device transmitting on a specific frequency.
- **`blackbox_rec.lua`**: 24/7 RF Recording. Logs every change in the local radio environment to the encrypted flight recorder.
- **`satellite_link.lua`**: GPS/GNSS spoofing and tracking.

### 4. Tactical & Defensive (50 Modules)
- **`chameleon.lua`**: Instant Skin Overlay. Changes the UI to look like a standard "Health Monitor" or "Smart Watch" to avoid suspicion.
- **`quantum_shield.lua`**: Engages Kyber-1024 encryption on all outbound traffic and local storage.
- **`cbrn_suite.lua`**: Visualizes data from the chemical and radiological sensors. Alerts if radiation or toxic gas levels exceed safe thresholds.

---

## IV. STEP-BY-STEP MISSION EXAMPLE

1.  **Preparation**: Strap the **Pandora Titan** to your forearm. Secure the ballistic plating.
2.  **Detection**: Navigate to the **Hardware** tab. Launch `cbrn_suite.lua` to ensure the environment is safe for operation.
3.  **Infiltration**: Go to **Ops**, select `marauder.lua`. Capture the Wi-Fi handshake.
4.  **Extraction**: Connect the target phone to the Titan's side USB port. Launch `alchemist.lua` to bypass security.
5.  **Exfiltration**: Once the phone is unlocked, run `timeline.lua`. Save the reconstructed data to the internal NVMe drive.
6.  **Cleanup**: Engage `chameleon.lua` before departing the zone.
