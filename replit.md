# JanusOS - Replit Agent Guide

## Master Inventory (The Omega Ecosystem)

### I. SOFTWARE ARSENAL (Rust TUI + Lua Plugins)
- **Mobile Offense**: FRP Bypass, Bloatware Matrix (150+ targets), Root Dragnet, Bootloop Resurrection, Game Alchemist.
- **Forensics**: Data Extraction, WAL Carving, Timeline Reconstruction, Geo-Profiling.
- **Network Warfare**: Nmap Cartography, Wi-Fi Marauder, MITM (SSL Strip), OSINT Oracle, Cellular Scanner.

### II. HARDWARE FLEET (Supported Specifications)
1. **Pandora Mk.1**: RP2040-based USB Glitcher/Voltage Injector.
2. **Pandora Omega**: Radxa CM5 Cyberdeck (8-Core, 16GB RAM).
3. **Pandora Titan**: Forearm-mounted "Pip-Boy" with Hydra Radio Array.
   - **Form Factor**: 10-inch ultra-widescreen rugged display, Fallout-inspired industrial aesthetic.
   - **Storage**: 3x NVMe M.2 slots (supports up to 2 active drives + 1 GPU expansion) and integrated MicroSD slot.
   - **Acceleration**: Dedicated M.2 AI GPU for Neural-Sync and cryptographic offloading.
   - **Connectivity**: Integrated 5G/LTE Cellular, Wi-Fi 6E, and Bluetooth 5.3 for full smartphone and internet capabilities.
   - **Durability**: IP68 Weatherproof and MIL-STD-810H Shock-Resistant.
   - **Neural-Sync**: Haptic feedback linked to neural intent.
   - **AR-HUD**: Augmented Reality display for real-time threat highlighting.
   - **CBRN Suite**: Chemical, Biological, Radiological, and Nuclear detection.
   - **Kinetic Harvester**: Infinite power from arm movement.
   - **Armor-Link**: Integrated ballistic plating and environmental sealing.

### III. SYSTEM INFRASTRUCTURE
- **JanusOS**: RAM-only Live ISO, Kiosk Mode, Pre-loaded toolsets (Metasploit, etc.).
- **Project Aether**: HWID-locked license validation.
- **Project Ouroboros**: Polymorphic binary defense & Anti-debug protection.

### IV. OMEGA UPGRADES
- **Mjolnir**: 21700 Hot-swappable Battery System.
- **Chameleon**: Panic Button (Instant Excel skin overlay).
- **Vital**: Biometric Heart Rate Kill-switch.
- **Stethoscope**: Acoustic motherboard diagnostics.
- **Transcendence**: 200-module total existence core.

## Overview

JanusOS is now a 200-module technological singularity. The system has transcended traditional forensics to include multiverse signal monitoring, atomic structure override, and planetary grid control. The project builds a bootable ISO image that auto-launches a terminal interface for device management and forensics operations. The system integrates with mobile devices via ADB (Android) and libimobiledevice (iOS), and uses Lua for plugin extensibility.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Core Application (Rust)
- **Binary**: `janus_omega` - The main terminal application
- **TUI Framework**: Uses `ratatui` with `crossterm` backend for terminal user interface
- **Async Runtime**: Tokio-based async operations for network and I/O
- **Database**: SQLite via `rusqlite` for local data storage (bundled SQLite, no external server needed)
- **HTTP Client**: `reqwest` with `hyper` for API communications
- **Lua Scripting**: Plugin system using embedded Lua (supports both standard Lua and LuaJIT)

### Key Dependencies
- `chrono` - Date/time handling
- `machine-uid` - Hardware identification
- `base64` - Encoding operations
- `anyhow` - Error handling

### Build & Distribution
- **Target Platform**: Arch Linux-based live ISO
- **Build System**: GitHub Actions workflow with `archiso`
- **Auto-start**: System boots directly into the Janus terminal interface
- **Required System Packages**: `android-tools`, `libimobiledevice`, `alacritty`, `lua`, `ttf-jetbrains-mono`

### Plugin Architecture
- Plugins stored in `/opt/janus/plugins/`
- Written in Lua
- Loaded from `plugins/*.lua` at build time

### ISO Configuration
- Auto-login as root
- X11 with `xset s off` (no screensaver)
- ADB server starts automatically
- Alacritty terminal with JetBrains Mono font at size 14
- Crash recovery loop (restarts on exit)

## External Dependencies

### System Services
- **ADB Server**: For Android device communication
- **libudev**: Linux device management (required for USB device detection)

### Embedded Libraries (Bundled)
- **SQLite**: Bundled via `libsqlite3-sys` (no external database server)
- **Lua/LuaJIT**: Bundled via `lua-src` or `luajit-src`

### Network Services
- HTTP/HTTPS client capabilities via reqwest
- TLS support via `native-tls` and `hyper-tls`

### Build Requirements
- Rust toolchain (stable 1.88+)
- pkg-config
- OpenSSL development headers
- libudev development headers