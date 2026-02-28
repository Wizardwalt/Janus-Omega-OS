#!/bin/bash
# Janus Omega OS v7.0 Apotheosis — Full Automated Setup Script
# Run this in your repo root: bash setup-janus.sh

set -e

echo "=== JANUS OMEGA OS v7.0 APOTHEOSIS SETUP ==="
echo "Creating full legendary structure..."

# Create directory structure
mkdir -p website docs/hardware docs/software \
         modules/{mobile_offense,forensics_recovery,network_warfare,sigint,tactical_defensive,vault_engineering,creative_psych,god_protocols,apocalypse_engineering} \
         overseer marketplace scripts airootfs compositor/src

echo "Creating all core files..."

# ==================== README.md ====================
cat > README.md << 'EOF'
# JANUS OMEGA OS + PANDORA TITAN

**The Forearm-Mounted 500-Module Tactical Singularity**

A RAM-only immutable Linux OS with authentic Pip-Boy CRT aesthetic, sentient local Overseer AI, Ghost Network mesh, and complete open hardware.

**[Live Website & Demo](https://wizardwalt.github.io/Janus-Omega-OS)**

**500 Modules • Local AI • Physical Controls • Apotheosis Protocol**

Built for survivors who refuse to compromise.
