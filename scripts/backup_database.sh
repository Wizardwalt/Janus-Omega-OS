#!/usr/bin/env bash
set -euo pipefail

DATABASE_PATH="${1:-/var/lib/janus/janus.db}"
BACKUP_DIR="${JANUS_BACKUP_DIR:-/var/backups/janus}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BACKUP_PATH="$BACKUP_DIR/janus-$STAMP.sqlite"

command -v sqlite3 >/dev/null || { echo "sqlite3 is required" >&2; exit 1; }
test -f "$DATABASE_PATH" || { echo "Database not found: $DATABASE_PATH" >&2; exit 1; }
install -d -m 0700 "$BACKUP_DIR"

sqlite3 "$DATABASE_PATH" ".backup '$BACKUP_PATH'"
sqlite3 "$BACKUP_PATH" "PRAGMA integrity_check;" | grep -qx 'ok' || {
  rm -f "$BACKUP_PATH"
  echo "Backup integrity check failed" >&2
  exit 1
}
chmod 0600 "$BACKUP_PATH"
printf 'Verified backup created: %s\n' "$BACKUP_PATH"
