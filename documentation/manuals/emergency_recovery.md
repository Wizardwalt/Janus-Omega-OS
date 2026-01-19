# Janus Master Guide: Emergency Procedures Addendum

## 1. PHYSICAL RECOVERY
- **Hard Reset**: Hold the side tactical button on the **Pandora Titan** while flipping the brass master toggle. This bypasses the primary boot partition and loads the "Ouroboros" factory recovery image from the protected internal NAND.
- **Emergency Wipe**: Triggered by flipping the **Red Safety Toggle** and pressing the tactical button simultaneously. This initiates an immediate 7-pass overwrite of the system RAM and clears all Kyber-1024 encryption keys, rendering the device a total black-hole.

## 2. SIGNAL ISOLATION
- **Total Silence**: Activate `ghost_net.lua` and set mode to `ISOLATE`. This disables all active radio transmissions (5G, Wi-Fi, Bluetooth, SDR) while keeping the internal forensics engine active.
- **Faraday Protocol**: Place any captured device into the Pandora Omega's lined compartment and engage the physical latch. This provides -80dB of signal attenuation across all bands.

## 3. LEGAL & COUNTER-FORENSICS
- **Chameleon Mode (Advanced)**: When `chameleon.lua` is active, all internal logs are hidden behind a decoy "System Health" database. To access the true logs, enter the 8-digit haptic sequence on the Titan's haptic pads.
- **Self-Destruct (Soft)**: The system can be configured to self-wipe after 3 failed haptic gesture attempts.
