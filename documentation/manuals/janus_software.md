# JanusOS: Software & Module Manual
## "The 200-Module Singularity"

### 1. SYSTEM ARCHITECTURE
JanusOS is a RAM-only, hardened Linux environment built for speed and security. It runs the Janus Omega terminal (Rust) and leverages a 200-module Lua plugin system.

### 2. CORE MODULES (TOP CATEGORIES)

#### I. MOBILE OFFENSE
- **Alchemist**: Universal FRP bypass and bootloader unlocker.
- **Dragnet**: Automated root detection and privilege escalation.
- **Resurrection**: Automated bootloop fixing for 150+ Android targets.

#### II. FORENSICS & RECOVERY
- **WAL Carver**: Recovers deleted SQLite entries from database journals.
- **Timeline**: Reconstructs user activity across all installed apps.
- **Geo-Profiler**: Correlates EXIF data with signal logs to map movements.

#### III. NETWORK WARFARE
- **Marauder**: Automated Wi-Fi deauth and handshake capture.
- **SSL Strip**: MITM tool for capturing encrypted traffic in local networks.
- **OSINT Oracle**: Real-time correlation of IDs across public databases.

### 3. USAGE GUIDE
1. **Launch**: Open the Janus Omega terminal.
2. **Search**: Type `modules` to list all 200 available tools.
3. **Run**: Select a module and provide the target device ID or IP.
4. **Log**: All activity is automatically recorded to the Black-Box flight recorder.

### 4. PLUGIN SYSTEM
Custom plugins can be added to `/opt/janus/plugins/`. JanusOS will automatically detect and load new Lua scripts on the next boot.
