#!/usr/bin/env bash
set -euo pipefail

RUNTIME_URL="${JANUS_RUNTIME_URL:-http://127.0.0.1:8080}"
DASHBOARD_URL="${JANUS_DASHBOARD_URL:-http://127.0.0.1:5000}"

command -v curl >/dev/null || { echo "curl is required" >&2; exit 1; }

runtime="$(curl --fail --silent --show-error --max-time 10 "$RUNTIME_URL/health")"
echo "$runtime" | grep -q '"status":"ok"' || { echo "Runtime health response was invalid" >&2; exit 1; }

curl --fail --silent --show-error --max-time 10 "$DASHBOARD_URL/" >/dev/null

printf 'Janus runtime healthy: %s\n' "$RUNTIME_URL"
printf 'Janus dashboard reachable: %s\n' "$DASHBOARD_URL"
