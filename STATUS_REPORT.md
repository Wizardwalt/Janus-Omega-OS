# Janus Omega Status Report

## Current state
The repository has been restructured into a working Rust-first foundation.

## Working components
- Cargo workspace
- Runtime HTTP API
- Plugin manifest loading
- Mode switching API
- Audit log persistence
- Note/evidence storage
- Export bundle generation
- Assistant chat and memory
- Android launcher/operator scaffolding

## Known limitations
- Android app is scaffold-level and may require Android Studio/local SDK to build
- Hardware-backed modules remain stubs
- No real Titan HAL implementation yet
- No recovery boot image yet
- No encrypted vault implementation yet

## Suggested next milestones
1. Android JSON parsing and richer UI
2. HAL/peripheral manager
3. Secure storage improvements
4. Recovery environment
5. Device integration for Titan
