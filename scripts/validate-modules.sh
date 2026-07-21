#!/usr/bin/env bash
set -euo pipefail

# Inventory only: Lua files are never executed during validation.
python3 scripts/inventory_modules.py "$@"
