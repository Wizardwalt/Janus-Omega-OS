# Janus-Omega-OS Workspace Architecture

## Overview

This repository uses a Cargo workspace to organize the Janus ecosystem into focused, modular crates:

```
Janus-Omega-OS/
├── Cargo.toml                 # Workspace root
├── janus-core/                # Shared types and core infrastructure
├── janus-runtime/             # Main runtime daemon
├── janus-tui/                 # Maintenance terminal UI
├── janus-web/                 # Web dashboard
├── android/                   # Android integration
├── plugins/                   # Plugin manifests and implementations
├── recovery/                  # Recovery environment
└── docs/                      # Architecture and guides
```

## Crates

### janus-core

**Purpose:** Shared library with all foundational types and infrastructure.  
**Responsibilities:**
- Type definitions for errors, configuration, modes, plugin metadata
- Capability registry and access control system
- Audit trail types and interfaces
- System state structures

**Dependents:** All other crates depend on this.  
**No external dependencies** (beyond serde, chrono, rusqlite)

### janus-runtime

**Purpose:** Main runtime daemon for Titan.  
**Responsibilities:**
- Plugin execution environment (Lua via mlua)
- HTTP/WebSocket API server (Axum)
- State management and SQLite persistence
- Audit logging
- Hardware abstraction layer
- Lua integration and core module loading

**Entry point:** `src/main.rs`  
**Binary:** `janus-runtime`

### janus-tui

**Purpose:** Terminal UI for maintenance and debugging.  
**Responsibilities:**
- Interactive terminal interface (ratatui)
- Lua REPL for live debugging
- Database inspection
- Plugin manual execution
- System diagnostics

**Entry point:** `src/main.rs`  
**Binary:** `janus-tui`

### janus-web

**Purpose:** Web dashboard and control panel.  
**Responsibilities:**
- Browser-based UI for system monitoring
- Frontend API proxy
- Real-time status dashboards
- Module result visualization

**Entry point:** `src/main.rs`  
**Binary:** `janus-web`

## Module Structure

### janus-core/src/

- `lib.rs` — Public API re-exports
- `error.rs` — Error types and Result alias
- `config.rs` — Configuration structures
- `modes.rs` — Execution and system modes
- `plugin.rs` — Plugin metadata and runtime instances
- `capabilities.rs` — Capability registry and access control
- `audit.rs` — Audit trail types and logging interfaces
- `state.rs` — System state and key-value storage

### janus-runtime/src/

- `main.rs` — CLI entry point, initialization
- `api.rs` — HTTP/WebSocket API server (Axum)
- `executor.rs` — Plugin execution engine
- `state.rs` — State management and persistence
- `lua/` (future) — Lua environment and module binding
- `hardware/` (future) — Hardware abstraction layer

### janus-tui/src/

- `main.rs` — CLI entry point
- `ui.rs` — Terminal UI components (ratatui)
- `repl.rs` — Lua REPL session

### janus-web/src/

- `main.rs` — HTTP server and dashboard routes
- `dashboard.rs` — Dashboard data structures

## Building

### Build all crates
```bash
cargo build --release
```

### Build specific crate
```bash
cargo build --release -p janus-runtime
cargo build --release -p janus-tui
cargo build --release -p janus-web
```

### Run
```bash
cargo run -p janus-runtime -- --help
cargo run -p janus-tui -- --help
cargo run -p janus-web -- --help
```

### Test
```bash
cargo test --all
cargo test -p janus-core
```

## Workspace Dependencies

Shared dependencies are declared at the workspace level in `Cargo.toml` with `[workspace.dependencies]`.
Each crate declares versions via `<dep>.workspace = true` to maintain consistency.

**Key dependencies:**
- `tokio` — Async runtime
- `axum` — Web framework
- `mlua` — Lua integration
- `rusqlite` — Embedded SQLite
- `ratatui` — Terminal UI
- `serde` — Serialization
- `tracing` — Structured logging

## Future Structure

As the project grows:

- **janus-plugins** — Plugin loading and manifest parsing
- **janus-hardware** — Hardware abstraction layer (split from runtime)
- **janus-crypto** — Cryptography utilities
- **janus-mesh** — Ghost Network mesh implementation

## Dependency Graph

```
janus-core
  ↑
  ├─ janus-runtime
  ├─ janus-tui
  └─ janus-web
  
(No circular dependencies)
```

## Development Workflow

1. **Core changes:** Modify `janus-core`, increment version if public API changes
2. **Feature development:** Add to appropriate crate (runtime/tui/web)
3. **Testing:** `cargo test --all` runs all tests
4. **Documentation:** Use rustdoc comments; `cargo doc --open`
5. **Formatting:** `cargo fmt --all`
6. **Linting:** `cargo clippy --all`

## Integration Points

- **janus-runtime** ↔ **janus-web**: HTTP API (janus-web calls runtime endpoints)
- **janus-runtime** ↔ **janus-tui**: Direct DB or IPC (future)
- **All** → **janus-core**: Type imports and error handling
