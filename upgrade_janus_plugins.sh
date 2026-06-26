set -e

echo "== Upgrading Janus plugin system =="

cat > janus-core/src/lib.rs <<'EOT'
use serde::{Deserialize, Serialize};
use serde_json::Value;

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

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NoteRecord {
    pub id: i64,
    pub title: String,
    pub body: String,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EvidenceRecord {
    pub id: i64,
    pub label: String,
    pub details: String,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModuleRunResult {
    pub module_id: String,
    pub status: String,
    pub message: String,
    pub data: Value,
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
    AssistantState, AuditEvent, EvidenceRecord, ModuleManifest, ModuleRunResult, NoteRecord,
    RuntimeConfig, RuntimeMode, RuntimeStatus,
};
use rusqlite::{params, Connection};
use serde_json::json;

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
    conn.execute(
        "CREATE TABLE IF NOT EXISTS notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            created_at TEXT NOT NULL
        )",
        [],
    )?;
    conn.execute(
        "CREATE TABLE IF NOT EXISTS evidence (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label TEXT NOT NULL,
            details TEXT NOT NULL,
            created_at TEXT NOT NULL
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

fn list_notes(db_path: &str) -> Vec<NoteRecord> {
    let mut out = Vec::new();
    let conn = match Connection::open(db_path) {
        Ok(c) => c,
        Err(_) => return out,
    };
    let mut stmt = match conn.prepare(
        "SELECT id, title, body, created_at FROM notes ORDER BY id DESC LIMIT 100",
    ) {
        Ok(s) => s,
        Err(_) => return out,
    };
    let rows = stmt.query_map([], |row| {
        Ok(NoteRecord {
            id: row.get(0)?,
            title: row.get(1)?,
            body: row.get(2)?,
            created_at: row.get(3)?,
        })
    });
    if let Ok(rows) = rows {
        for row in rows.flatten() {
            out.push(row);
        }
    }
    out
}

fn list_evidence(db_path: &str) -> Vec<EvidenceRecord> {
    let mut out = Vec::new();
    let conn = match Connection::open(db_path) {
        Ok(c) => c,
        Err(_) => return out,
    };
    let mut stmt = match conn.prepare(
        "SELECT id, label, details, created_at FROM evidence ORDER BY id DESC LIMIT 100",
    ) {
        Ok(s) => s,
        Err(_) => return out,
    };
    let rows = stmt.query_map([], |row| {
        Ok(EvidenceRecord {
            id: row.get(0)?,
            label: row.get(1)?,
            details: row.get(2)?,
            created_at: row.get(3)?,
        })
    });
    if let Ok(rows) = rows {
        for row in rows.flatten() {
            out.push(row);
        }
    }
    out
}

fn create_note(db_path: &str, title: &str, body: &str) {
    if let Ok(conn) = Connection::open(db_path) {
        let _ = conn.execute(
            "INSERT INTO notes (title, body, created_at) VALUES (?1, ?2, ?3)",
            params![title, body, Utc::now().to_rfc3339()],
        );
    }
}

fn create_evidence(db_path: &str, label: &str, details: &str) {
    if let Ok(conn) = Connection::open(db_path) {
        let _ = conn.execute(
            "INSERT INTO evidence (label, details, created_at) VALUES (?1, ?2, ?3)",
            params![label, details, Utc::now().to_rfc3339()],
        );
    }
}

fn run_module_logic(db_path: &str, module_id: &str) -> ModuleRunResult {
    match module_id {
        "core.system_status" => ModuleRunResult {
            module_id: module_id.to_string(),
            status: "ok".to_string(),
            message: "System status collected".to_string(),
            data: json!({
                "runtime": "online",
                "storage": "available",
                "db_path": db_path
            }),
        },
        "core.encrypted_notes" => {
            create_note(
                db_path,
                "Operator Note",
                "Placeholder secure note created by encrypted_notes module.",
            );
            ModuleRunResult {
                module_id: module_id.to_string(),
                status: "ok".to_string(),
                message: "Note created".to_string(),
                data: json!({
                    "notes_total": list_notes(db_path).len()
                }),
            }
        }
        "core.connectivity_summary" => ModuleRunResult {
            module_id: module_id.to_string(),
            status: "ok".to_string(),
            message: "Connectivity summary generated".to_string(),
            data: json!({
                "network": "unknown_in_replit",
                "wifi": "stub",
                "bluetooth": "stub"
            }),
        },
        "core.battery_thermal" => ModuleRunResult {
            module_id: module_id.to_string(),
            status: "stub".to_string(),
            message: "Battery and thermal data require device-specific integration".to_string(),
            data: json!({
                "battery": "stub",
                "thermal": "stub"
            }),
        },
        "core.device_log_summary" => ModuleRunResult {
            module_id: module_id.to_string(),
            status: "ok".to_string(),
            message: "Audit summary available".to_string(),
            data: json!({
                "recent_audit_events": read_audit(db_path).len()
            }),
        },
        "core.evidence_index" => {
            create_evidence(
                db_path,
                "Sample Evidence",
                "Placeholder evidence item created by evidence_index module.",
            );
            ModuleRunResult {
                module_id: module_id.to_string(),
                status: "ok".to_string(),
                message: "Evidence indexed".to_string(),
                data: json!({
                    "evidence_total": list_evidence(db_path).len()
                }),
            }
        }
        "core.bluetooth_inventory" => ModuleRunResult {
            module_id: module_id.to_string(),
            status: "stub".to_string(),
            message: "Bluetooth inventory requires platform hardware support".to_string(),
            data: json!({
                "devices": []
            }),
        },
        "core.wifi_environment_survey" => ModuleRunResult {
            module_id: module_id.to_string(),
            status: "stub".to_string(),
            message: "WiFi survey requires platform hardware support".to_string(),
            data: json!({
                "access_points": []
            }),
        },
        "core.update_manager" => ModuleRunResult {
            module_id: module_id.to_string(),
            status: "stub".to_string(),
            message: "Update workflows are not yet implemented".to_string(),
            data: json!({
                "update_channel": "none"
            }),
        },
        _ => ModuleRunResult {
            module_id: module_id.to_string(),
            status: "error".to_string(),
            message: "Unknown module".to_string(),
            data: json!({}),
        },
    }
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

async fn notes_handler(State(state): State<AppState>) -> Json<Vec<NoteRecord>> {
    Json(list_notes(&state.db_path))
}

async fn evidence_handler(State(state): State<AppState>) -> Json<Vec<EvidenceRecord>> {
    Json(list_evidence(&state.db_path))
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
) -> Json<ModuleRunResult> {
    let exists = state.modules.iter().any(|m| m.id == id);
    if !exists {
        log_audit(&state.db_path, "module_run", &id, "not_found");
        return Json(ModuleRunResult {
            module_id: id,
            status: "error".to_string(),
            message: "Module not found".to_string(),
            data: json!({}),
        });
    }

    let result = run_module_logic(&state.db_path, &id);
    log_audit(&state.db_path, "module_run", &id, &result.status);
    Json(result)
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
        .route("/api/notes", get(notes_handler))
        .route("/api/evidence", get(evidence_handler))
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

cat > plugins/core/system_status/main.lua <<'EOT'
return {
  id = "core.system_status",
  run = function()
    return "Runtime-backed system status"
  end
}
EOT

cat > plugins/core/encrypted_notes/main.lua <<'EOT'
return {
  id = "core.encrypted_notes",
  run = function()
    return "Runtime-backed encrypted notes placeholder"
  end
}
EOT

cat > plugins/core/connectivity_summary/main.lua <<'EOT'
return {
  id = "core.connectivity_summary",
  run = function()
    return "Runtime-backed connectivity summary placeholder"
  end
}
EOT

cat > plugins/core/battery_thermal/main.lua <<'EOT'
return {
  id = "core.battery_thermal",
  run = function()
    return "Battery/thermal placeholder"
  end
}
EOT

cat > plugins/core/device_log_summary/main.lua <<'EOT'
return {
  id = "core.device_log_summary",
  run = function()
    return "Device log summary placeholder"
  end
}
EOT

cat > plugins/core/evidence_index/main.lua <<'EOT'
return {
  id = "core.evidence_index",
  run = function()
    return "Evidence index placeholder"
  end
}
EOT

cat > plugins/core/bluetooth_inventory/main.lua <<'EOT'
return {
  id = "core.bluetooth_inventory",
  run = function()
    return "Bluetooth inventory placeholder"
  end
}
EOT

cat > plugins/core/wifi_environment_survey/main.lua <<'EOT'
return {
  id = "core.wifi_environment_survey",
  run = function()
    return "WiFi environment survey placeholder"
  end
}
EOT

cat > plugins/core/update_manager/main.lua <<'EOT'
return {
  id = "core.update_manager",
  run = function()
    return "Update manager placeholder"
  end
}
EOT

echo "== cargo check =="
cargo check

echo
echo "== Plugin upgrade complete =="
echo "Run:"
echo "  cargo run -p janus-runtime"
echo
echo "Then test:"
echo "  curl http://127.0.0.1:8080/api/modules"
echo "  curl -X POST http://127.0.0.1:8080/api/modules/core.system_status/run"
echo "  curl -X POST http://127.0.0.1:8080/api/modules/core.encrypted_notes/run"
echo "  curl http://127.0.0.1:8080/api/notes"
echo "  curl -X POST http://127.0.0.1:8080/api/modules/core.evidence_index/run"
echo "  curl http://127.0.0.1:8080/api/evidence"
