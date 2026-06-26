# Android System Design

## Goal
Titan boots into Android, and the Janus Launcher becomes the primary operator-facing shell.

## Components
- Android launcher UI
- Local Janus runtime bridge over localhost HTTP
- Operator Mode
- Diagnostics Mode
- Settings
- Evidence workflows

## Runtime API
- GET /api/status
- GET /api/modules
- GET /api/assistant
- GET /api/audit
- GET /api/mode
- POST /api/mode/:mode
- POST /api/modules/:id/run
