#!/usr/bin/env bash
set -euo pipefail

BACKUP_PATH="${1:?Usage: restore_database.sh BACKUP.sqlite [DATABASE.sqlite]}"
DATABASE_PATH="${2:-/var/lib/janus/janus.db}"

command -v sqlite3 >/dev/null || { echo "sqlite3 is required" >&2; exit 1; }
test -f "$BACKUP_PATH" || { echo "Backup not found: $BACKUP_PATH" >&2; exit 1; }
sqlite3 "$BACKUP_PATH" "PRAGMA integrity_check;" | grep -qx 'ok' || { echo "Backup integrity check failed" >&2; exit 1; }

printf 'This replaces %s with verified backup %s. Type RESTORE to continue: ' "$DATABASE_PATH" "$BACKUP_PATH"
read -r confirmation
test "$confirmation" = "RESTORE" || { echo "Restore cancelled"; exit 1; }
install -d "$(dirname "$DATABASE_PATH")"
TEMP_PATH="${DATABASE_PATH}.restore.$$"
sqlite3 "$BACKUP_PATH" ".backup '$TEMP_PATH'"
mv -f "$TEMP_PATH" "$DATABASE_PATH"
chmod 0600 "$DATABASE_PATH"
printf 'Database restored: %s\n' "$DATABASE_PATH"
