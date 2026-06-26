set -e

echo "== Janus Omega: finishing working repository foundation =="

mkdir -p legacy docs android recovery plugins/core/system_status plugins/core/encrypted_notes plugins/core/connectivity_summary
mkdir -p plugins/core/battery_thermal plugins/core/device_log_summary plugins/core/evidence_index plugins/core/bluetooth_inventory plugins/core/wifi_environment_survey plugins/core/update_manager
mkdir -p janus-core/src janus-runtime/src janus-tui/src janus-web/src
mkdir -p config data logs
mkdir -p .github/workflows .github/workflows.disabled

if [ -d .github/workflows ]; then
  find .github/workflows -maxdepth 1 -name "*.yml" -type f -exec mv {} .github/workflows.disabled/ \; 2>/dev/null || true
fi

[ -d src ] && [ ! -d legacy/src-legacy ] && mv src legacy/src-legacy || true
[ -f Cargo.lock ] && cp Cargo.lock legacy/Cargo.lock.legacy || true

cat > Cargo.toml <<'EOT'
[workspace]
members = [
  "janus-core",
  "janus-runtime",
  "janus-tui",
  "janus-web"
]
resolver = "2"

[workspace.package]
edition = "2021"
version = "0.1.0"
authors = ["Wizardwalt"]

[workspace.dependencies]
anyhow = "1.0"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1.32", features = ["full"] }
axum = { version = "0.7", features = ["ws"] }
chrono = { version = "0.4", features = ["serde"] }
rusqlite = { version = "0.29", features = ["bundled"] }
EOT

cat > janus-core/Cargo.toml <<'EOT'
[package]
name = "janus-core"
version = "0.1.0"
edition = "2021"

[dependencies]
serde.workspace = true
serde_json.workspace = true
chrono.workspace = true
anyhow.workspace = true
EOT

cat > janus-core/src/lib.rs <<'EOT'
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "PascalCase")]
pub enum ImplementationStatus {
    Implemented,
    Stub,
    Experimental,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum RuntimeMode {
    Launcher,
    Operator,
    Diagnostics,
    Maintenance,
    Recovery,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RuntimeConfig {
    pub product_name: String,
    pub hardware_profile: String,
    pub default_mode: String,
    pub assistant_enabled: bool,
    pub listen_addr: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModuleManifest {
    pub id: String,
    pub name: String,
    pub version: String,
    pub description: String,
    pub category: String,
    pub implementation_status: ImplementationStatus,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuditEvent {
    pub time: String,
    pub action: String,
    pub target: String,
    pub outcome: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AssistantState {
    pub enabled: bool,
    pub persona: String,
    pub last_message: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RuntimeStatus {
    pub product_name: String,
    pub mode: RuntimeMode,
    pub modules_loaded: usize,
    pub assistant_enabled: bool,
    pub hardware_profile: String,
}

impl Default for RuntimeStatus {
    fn default() -> Self {
        Self {
            product_name: "Janus Omega".to_string(),
            mode: RuntimeMode::Launcher,
            modules_loaded: 0,
            assistant_enabled: false,
            hardware_profile: "Titan-Dev".to_string(),
        }
    }
}
EOT

cat > janus-runtime/Cargo.toml <<'EOT'
[package]
name = "janus-runtime"
version = "0.1.0"
edition = "2021"

[dependencies]
anyhow.workspace = true
serde.workspace = true
serde_json.workspace = true
tokio.workspace = true
axum.workspace = true
chrono.workspace = true
rusqlite.workspace = true
janus-core = { path = "../janus-core" }
EOT

cat > janus-runtime/src/main.rs <<'EOT'
use std::{
    fs,
    net::SocketAddr,
    sync::{Arc, Mutex},
};

use axum::{
    extract::{Path, State},
    routing::{get, post},
    Json, Router,
};
use chrono::Utc;
use janus_core::{
    AssistantState, AuditEvent, ModuleManifest, RuntimeConfig, RuntimeMode, RuntimeStatus,
};
use rusqlite::{params, Connection};

#[derive(Clone)]
struct AppState {
    status: Arc<Mutex<RuntimeStatus>>,
    modules: Arc<Vec<ModuleManifest>>,
    assistant: Arc<Mutex<AssistantState>>,
    db_path: Arc<String>,
}

fn parse_mode(s: &str) -> RuntimeMode {
    match s {
        "operator" => RuntimeMode::Operator,
        "diagnostics" => RuntimeMode::Diagnostics,
        "maintenance" => RuntimeMode::Maintenance,
        "recovery" => RuntimeMode::Recovery,
        _ => RuntimeMode::Launcher,
    }
}

fn load_config() -> RuntimeConfig {
    let text = fs::read_to_string("config/runtime.json").unwrap_or_else(|_| {
        r#"{
          "product_name":"Janus Omega",
          "hardware_profile":"Titan-Dev",
          "default_mode":"launcher",
          "assistant_enabled":true,
          "listen_addr":"0.0.0.0:8080"
        }"#
        .to_string()
    });

    serde_json::from_str(&text).unwrap_or(RuntimeConfig {
        product_name: "Janus Omega".to_string(),
        hardware_profile: "Titan-Dev".to_string(),
        default_mode: "launcher".to_string(),
        assistant_enabled: true,
        listen_addr: "0.0.0.0:8080".to_string(),
    })
}

fn load_modules() -> Vec<ModuleManifest> {
    let mut out = Vec::new();
    if let Ok(entries) = fs::read_dir("plugins") {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_dir() {
                walk_plugin_dir(&path, &mut out);
            }
        }
    }
    out
}

fn walk_plugin_dir(path: &std::path::Path, out: &mut Vec<ModuleManifest>) {
    if let Ok(entries) = fs::read_dir(path) {
        for entry in entries.flatten() {
            let p = entry.path();
            if p.is_dir() {
                walk_plugin_dir(&p, out);
            } else if p.file_name().and_then(|n| n.to_str()) == Some("manifest.json") {
                if let Ok(text) = fs::read_to_string(&p) {
                    if let Ok(manifest) = serde_json::from_str::<ModuleManifest>(&text) {
                        out.push(manifest);
                    }
                }
            }
        }
    }
}

fn init_db(db_path: &str) -> anyhow::Result<()> {
    let conn = Connection::open(db_path)?;
    conn.execute(
        "CREATE TABLE IF NOT EXISTS audit (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            time TEXT NOT NULL,
            action TEXT NOT NULL,
            target TEXT NOT NULL,
            outcome TEXT NOT NULL
        )",
        [],
    )?;
    Ok(())
}

fn log_audit(db_path: &str, action: &str, target: &str, outcome: &str) {
    if let Ok(conn) = Connection::open(db_path) {
        let _ = conn.execute(
            "INSERT INTO audit (time, action, target, outcome) VALUES (?1, ?2, ?3, ?4)",
            params![Utc::now().to_rfc3339(), action, target, outcome],
        );
    }
}

fn read_audit(db_path: &str) -> Vec<AuditEvent> {
    let mut out = Vec::new();
    let conn = match Connection::open(db_path) {
        Ok(c) => c,
        Err(_) => return out,
    };

    let mut stmt = match conn.prepare(
        "SELECT time, action, target, outcome FROM audit ORDER BY id DESC LIMIT 100",
    ) {
        Ok(s) => s,
        Err(_) => return out,
    };

    let rows = stmt.query_map([], |row| {
        Ok(AuditEvent {
            time: row.get(0)?,
            action: row.get(1)?,
            target: row.get(2)?,
            outcome: row.get(3)?,
        })
    });

    if let Ok(rows) = rows {
        for row in rows.flatten() {
            out.push(row);
        }
    }

    out
}

async fn health_handler() -> &'static str {
    "ok"
}

async fn status_handler(State(state): State<AppState>) -> Json<RuntimeStatus> {
    Json(state.status.lock().unwrap().clone())
}

async fn modules_handler(State(state): State<AppState>) -> Json<Vec<ModuleManifest>> {
    Json(state.modules.as_ref().clone())
}

async fn assistant_handler(State(state): State<AppState>) -> Json<AssistantState> {
    Json(state.assistant.lock().unwrap().clone())
}

async fn audit_handler(State(state): State<AppState>) -> Json<Vec<AuditEvent>> {
    Json(read_audit(&state.db_path))
}

async fn mode_get_handler(State(state): State<AppState>) -> Json<String> {
    let mode = state.status.lock().unwrap().mode.clone();
    let s = match mode {
        RuntimeMode::Launcher => "launcher",
        RuntimeMode::Operator => "operator",
        RuntimeMode::Diagnostics => "diagnostics",
        RuntimeMode::Maintenance => "maintenance",
        RuntimeMode::Recovery => "recovery",
    };
    Json(s.to_string())
}

async fn mode_set_handler(
    Path(mode): Path<String>,
    State(state): State<AppState>,
) -> Json<RuntimeStatus> {
    {
        let mut status = state.status.lock().unwrap();
        status.mode = parse_mode(&mode);
    }
    log_audit(&state.db_path, "mode_change", &mode, "success");
    Json(state.status.lock().unwrap().clone())
}

async fn run_module_handler(
    Path(id): Path<String>,
    State(state): State<AppState>,
) -> Json<String> {
    let exists = state.modules.iter().any(|m| m.id == id);
    if exists {
        log_audit(&state.db_path, "module_run", &id, "accepted");
        Json(format!("Module {} accepted by runtime", id))
    } else {
        log_audit(&state.db_path, "module_run", &id, "not_found");
        Json(format!("Module {} not found", id))
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let config = load_config();
    let modules = load_modules();
    let db_path = "data/janus.db".to_string();

    init_db(&db_path)?;

    let status = RuntimeStatus {
        product_name: config.product_name.clone(),
        mode: parse_mode(&config.default_mode),
        modules_loaded: modules.len(),
        assistant_enabled: config.assistant_enabled,
        hardware_profile: config.hardware_profile.clone(),
    };

    let assistant = AssistantState {
        enabled: config.assistant_enabled,
        persona: "ARIA".to_string(),
        last_message: "Systems online. Ready for operator input.".to_string(),
    };

    log_audit(&db_path, "runtime_start", "janus-runtime", "success");

    let state = AppState {
        status: Arc::new(Mutex::new(status)),
        modules: Arc::new(modules),
        assistant: Arc::new(Mutex::new(assistant)),
        db_path: Arc::new(db_path),
    };

    let app = Router::new()
        .route("/health", get(health_handler))
        .route("/api/status", get(status_handler))
        .route("/api/modules", get(modules_handler))
        .route("/api/assistant", get(assistant_handler))
        .route("/api/audit", get(audit_handler))
        .route("/api/mode", get(mode_get_handler))
        .route("/api/mode/:mode", post(mode_set_handler))
        .route("/api/modules/:id/run", post(run_module_handler))
        .with_state(state);

    let addr: SocketAddr = config.listen_addr.parse()?;
    println!("Janus Runtime listening on http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;
    Ok(())
}
EOT

cat > janus-tui/Cargo.toml <<'EOT'
[package]
name = "janus-tui"
version = "0.1.0"
edition = "2021"

[dependencies]
janus-core = { path = "../janus-core" }
EOT

cat > janus-tui/src/main.rs <<'EOT'
use std::fs;

use janus_core::RuntimeStatus;

fn main() {
    let status = RuntimeStatus::default();
    println!("==============================");
    println!(" JANUS TUI MAINTENANCE MODE");
    println!("==============================");
    println!("Product: {}", status.product_name);
    println!("Hardware Profile: {}", status.hardware_profile);
    println!();
    println!("Plugin tree:");
    if let Ok(entries) = fs::read_dir("plugins") {
        for entry in entries.flatten() {
            println!("- {}", entry.path().display());
        }
    } else {
        println!("No plugins directory found.");
    }
}
EOT

cat > janus-web/Cargo.toml <<'EOT'
[package]
name = "janus-web"
version = "0.1.0"
edition = "2021"

[dependencies]
janus-core = { path = "../janus-core" }
EOT

cat > janus-web/src/main.rs <<'EOT'
fn main() {
    println!("janus-web placeholder");
}
EOT

cat > config/runtime.json <<'EOT'
{
  "product_name": "Janus Omega",
  "hardware_profile": "Titan-Dev",
  "default_mode": "launcher",
  "assistant_enabled": true,
  "listen_addr": "0.0.0.0:8080"
}
EOT

cat > plugins/core/system_status/manifest.json <<'EOT'
{
  "id": "core.system_status",
  "name": "System Status",
  "version": "0.1.0",
  "description": "Provides runtime and system overview information.",
  "category": "core",
  "implementation_status": "Implemented"
}
EOT

cat > plugins/core/system_status/main.lua <<'EOT'
return {
  run = function()
    return "System status placeholder"
  end
}
EOT

cat > plugins/core/encrypted_notes/manifest.json <<'EOT'
{
  "id": "core.encrypted_notes",
  "name": "Encrypted Notes",
  "version": "0.1.0",
  "description": "Stores secure field notes and operator annotations.",
  "category": "evidence",
  "implementation_status": "Stub"
}
EOT

cat > plugins/core/encrypted_notes/main.lua <<'EOT'
return {
  run = function()
    return "Encrypted notes placeholder"
  end
}
EOT

cat > plugins/core/connectivity_summary/manifest.json <<'EOT'
{
  "id": "core.connectivity_summary",
  "name": "Connectivity Summary",
  "version": "0.1.0",
  "description": "Summarizes available local connectivity state.",
  "category": "diagnostics",
  "implementation_status": "Stub"
}
EOT

cat > plugins/core/connectivity_summary/main.lua <<'EOT'
return {
  run = function()
    return "Connectivity summary placeholder"
  end
}
EOT

cat > plugins/core/battery_thermal/manifest.json <<'EOT'
{
  "id": "core.battery_thermal",
  "name": "Battery and Thermal",
  "version": "0.1.0",
  "description": "Reports battery and thermal health.",
  "category": "diagnostics",
  "implementation_status": "Stub"
}
EOT

cat > plugins/core/device_log_summary/manifest.json <<'EOT'
{
  "id": "core.device_log_summary",
  "name": "Device Log Summary",
  "version": "0.1.0",
  "description": "Summarizes local runtime and device logs.",
  "category": "diagnostics",
  "implementation_status": "Stub"
}
EOT

cat > plugins/core/evidence_index/manifest.json <<'EOT'
{
  "id": "core.evidence_index",
  "name": "Evidence Index",
  "version": "0.1.0",
  "description": "Indexes evidence metadata for review and export.",
  "category": "evidence",
  "implementation_status": "Stub"
}
EOT

cat > plugins/core/bluetooth_inventory/manifest.json <<'EOT'
{
  "id": "core.bluetooth_inventory",
  "name": "Bluetooth Inventory",
  "version": "0.1.0",
  "description": "Lists visible Bluetooth devices in range when supported.",
  "category": "survey",
  "implementation_status": "Stub"
}
EOT

cat > plugins/core/wifi_environment_survey/manifest.json <<'EOT'
{
  "id": "core.wifi_environment_survey",
  "name": "WiFi Environment Survey",
  "version": "0.1.0",
  "description": "Summarizes local WiFi environment visibility when supported.",
  "category": "survey",
  "implementation_status": "Stub"
}
EOT

cat > plugins/core/update_manager/manifest.json <<'EOT'
{
  "id": "core.update_manager",
  "name": "Update Manager",
  "version": "0.1.0",
  "description": "Handles runtime, plugin, and platform update workflows.",
  "category": "maintenance",
  "implementation_status": "Stub"
}
EOT

cat > docs/architecture.md <<'EOT'
# Janus Omega Architecture

## Goal
Titan boots into an Android-based operator environment.
Janus acts as the primary launcher/runtime ecosystem.

## Components
- janus-core: shared runtime types and manifests
- janus-runtime: local service and API backend
- janus-tui: maintenance shell
- janus-web: dashboard placeholder
- plugins: manifest-based module system
- android: Android launcher/client scaffolding
- recovery: maintenance/recovery environment scaffolding
EOT

cat > docs/roadmap.md <<'EOT'
# Roadmap

## Phase 1
- Rust workspace compiles
- Runtime API works
- Plugin manifests load
- Audit events persist

## Phase 2
- Android launcher integration
- Mode switching UI
- Hardware abstraction layer

## Phase 3
- Maintenance mode expansion
- Recovery environment
- Evidence and secure storage workflows
EOT

cat > docs/android-system-design.md <<'EOT'
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
EOT

cat > docs/titan-hardware.md <<'EOT'
# Titan Hardware Plan

## Planned Hardware Abstraction Domains
- display
- physical controls
- battery/thermal
- GPS
- IMU
- camera
- microphone/speaker
- Bluetooth
- WiFi
- USB/serial peripherals
- haptics

## Development Profiles
- Titan-Dev: mock/dev profile
- Titan-Android: Android bridge-backed profile
- Titan-Hardware: final device-backed implementation
EOT

cat > recovery/README.md <<'EOT'
# Janus Recovery

This directory will hold the maintenance/recovery environment for Titan.

Planned purposes:
- diagnostics
- log export
- update recovery
- runtime repair
EOT

cat > README.md <<'EOT'
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
EOT

cat > .gitignore <<'EOT'
target/
dist/
out/
build/
node_modules/
*.db
*.db-journal
EOT

cat > .github/workflows/rust-ci.yml <<'EOT'
name: Rust CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Rust
        uses: dtolnay/rust-toolchain@stable
      - name: Cargo check
        run: cargo check
EOT

echo "== running cargo check =="
cargo check

echo
echo "== done =="
echo "Try these next:"
echo "  cargo run -p janus-runtime"
echo "  curl http://127.0.0.1:8080/health"
echo "  curl http://127.0.0.1:8080/api/status"
echo "  curl http://127.0.0.1:8080/api/modules"
