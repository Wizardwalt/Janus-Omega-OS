# Janus Omega OS

Janus Omega is a Titan-targeted Android-first operator platform under active development.

## Architecture
- `janus-core` — shared runtime types and manifests
- `janus-runtime` — local Rust runtime with HTTP API and audit logging
- `janus-tui` — maintenance shell
- `janus-web` — web/dashboard placeholder
- `plugins/` — manifest-based module system
- `android/` — Android launcher/client scaffolding
- `recovery/` — maintenance environment scaffolding

## Current Working Features
- Rust workspace builds
- Runtime API serves:
  - `/health`
  - `/api/status`
  - `/api/modules`
  - `/api/assistant`
  - `/api/audit`
  - `/api/mode`
- Module manifests are discovered from `plugins/`
- Audit records are persisted to SQLite

## Run
cargo run -p janus-runtime
