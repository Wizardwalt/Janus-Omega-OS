set -e

echo "== Upgrading Janus assistant/chat system =="

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
    pub attachment_path: String,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModuleRunResult {
    pub module_id: String,
    pub status: String,
    pub message: String,
    pub data: Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateNoteRequest {
    pub title: String,
    pub body: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateEvidenceRequest {
    pub label: String,
    pub details: String,
    pub attachment_path: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExportBundleResult {
    pub export_file: String,
    pub notes_count: usize,
    pub evidence_count: usize,
    pub audit_count: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatRequest {
    pub message: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatResponse {
    pub reply: String,
    pub recommended_modules: Vec<String>,
    pub remembered_messages: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MemoryRecord {
    pub id: i64,
    pub role: String,
    pub message: String,
    pub created_at: String,
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

cat > janus-runtime/src/main.rs <<'EOT'
use std::{
    fs,
    net::SocketAddr,
    path::Path,
    sync::{Arc, Mutex},
};

use axum::{
    extract::{Path as AxumPath, State},
    routing::{get, post},
    Json, Router,
};
use chrono::Utc;
use janus_core::{
    AssistantState, AuditEvent, ChatRequest, ChatResponse, CreateEvidenceRequest,
    CreateNoteRequest, EvidenceRecord, ExportBundleResult, MemoryRecord, ModuleManifest,
    ModuleRunResult, NoteRecord, RuntimeConfig, RuntimeMode, RuntimeStatus,
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
            attachment_path TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL
        )",
        [],
    )?;
    conn.execute(
        "CREATE TABLE IF NOT EXISTS memory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            role TEXT NOT NULL,
            message TEXT NOT NULL,
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
        "SELECT id, label, details, attachment_path, created_at FROM evidence ORDER BY id DESC LIMIT 100",
    ) {
        Ok(s) => s,
        Err(_) => return out,
    };
    let rows = stmt.query_map([], |row| {
        Ok(EvidenceRecord {
            id: row.get(0)?,
            label: row.get(1)?,
            details: row.get(2)?,
            attachment_path: row.get(3)?,
            created_at: row.get(4)?,
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

fn create_evidence(db_path: &str, label: &str, details: &str, attachment_path: &str) {
    if let Ok(conn) = Connection::open(db_path) {
        let _ = conn.execute(
            "INSERT INTO evidence (label, details, attachment_path, created_at) VALUES (?1, ?2, ?3, ?4)",
            params![label, details, attachment_path, Utc::now().to_rfc3339()],
        );
    }
}

fn export_bundle(db_path: &str) -> ExportBundleResult {
    let notes = list_notes(db_path);
    let evidence = list_evidence(db_path);
    let audit = read_audit(db_path);

    let timestamp = Utc::now().format("%Y%m%d-%H%M%S").to_string();
    let export_file = format!("exports/janus-export-{}.json", timestamp);

    let payload = json!({
        "generated_at": Utc::now().to_rfc3339(),
        "notes": notes,
        "evidence": evidence,
        "audit": audit
    });

    let _ = fs::write(&export_file, serde_json::to_string_pretty(&payload).unwrap_or_else(|_| "{}".to_string()));

    ExportBundleResult {
        export_file,
        notes_count: payload["notes"].as_array().map(|a| a.len()).unwrap_or(0),
        evidence_count: payload["evidence"].as_array().map(|a| a.len()).unwrap_or(0),
        audit_count: payload["audit"].as_array().map(|a| a.len()).unwrap_or(0),
    }
}

fn list_exports() -> Vec<String> {
    let mut out = Vec::new();
    if let Ok(entries) = fs::read_dir("exports") {
        for entry in entries.flatten() {
            let p = entry.path();
            if p.is_file() {
                if let Some(s) = p.to_str() {
                    out.push(s.to_string());
                }
            }
        }
    }
    out.sort();
    out.reverse();
    out
}

fn safe_attachment_path(p: &str) -> String {
    let clean = p.trim();
    if clean.is_empty() {
        return "".to_string();
    }
    let path = Path::new(clean);
    if path.is_absolute() {
        return "".to_string();
    }
    clean.to_string()
}

fn add_memory(db_path: &str, role: &str, message: &str) {
    if let Ok(conn) = Connection::open(db_path) {
        let _ = conn.execute(
            "INSERT INTO memory (role, message, created_at) VALUES (?1, ?2, ?3)",
            params![role, message, Utc::now().to_rfc3339()],
        );
    }
}

fn list_memory(db_path: &str) -> Vec<MemoryRecord> {
    let mut out = Vec::new();
    let conn = match Connection::open(db_path) {
        Ok(c) => c,
        Err(_) => return out,
    };
    let mut stmt = match conn.prepare(
        "SELECT id, role, message, created_at FROM memory ORDER BY id DESC LIMIT 50",
    ) {
        Ok(s) => s,
        Err(_) => return out,
    };
    let rows = stmt.query_map([], |row| {
        Ok(MemoryRecord {
            id: row.get(0)?,
            role: row.get(1)?,
            message: row.get(2)?,
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

fn recommend_modules(message: &str, modules: &[ModuleManifest]) -> Vec<String> {
    let msg = message.to_lowercase();
    let mut out = Vec::new();

    if msg.contains("status") || msg.contains("system") {
        out.push("core.system_status".to_string());
    }
    if msg.contains("note") || msg.contains("write") || msg.contains("remember") {
        out.push("core.encrypted_notes".to_string());
    }
    if msg.contains("evidence") || msg.contains("photo") || msg.contains("artifact") {
        out.push("core.evidence_index".to_string());
    }
    if msg.contains("wifi") {
        out.push("core.wifi_environment_survey".to_string());
    }
    if msg.contains("bluetooth") {
        out.push("core.bluetooth_inventory".to_string());
    }
    if msg.contains("log") || msg.contains("audit") {
        out.push("core.device_log_summary".to_string());
    }

    for m in modules {
        if out.len() >= 3 {
            break;
        }
        if !out.contains(&m.id) {
            out.push(m.id.clone());
        }
    }

    out.truncate(3);
    out
}

fn assistant_reply(message: &str, recommended: &[String]) -> String {
    let msg = message.to_lowercase();
    if msg.contains("hello") || msg.contains("hi") {
        return "Hello operator. Systems are online and ready.".to_string();
    }
    if msg.contains("status") {
        return "I recommend checking current runtime state and system status.".to_string();
    }
    if msg.contains("note") {
        return "I can help you record a note and keep it in session memory.".to_string();
    }
    if msg.contains("evidence") {
        return "I can help you index evidence and prepare an export bundle.".to_string();
    }
    format!(
        "I processed your request. Recommended modules: {}.",
        recommended.join(", ")
    )
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
                "",
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

async fn exports_handler() -> Json<Vec<String>> {
    Json(list_exports())
}

async fn memory_handler(State(state): State<AppState>) -> Json<Vec<MemoryRecord>> {
    Json(list_memory(&state.db_path))
}

async fn create_note_handler(
    State(state): State<AppState>,
    Json(payload): Json<CreateNoteRequest>,
) -> Json<NoteRecord> {
    create_note(&state.db_path, &payload.title, &payload.body);
    log_audit(&state.db_path, "note_create", &payload.title, "success");
    let latest = list_notes(&state.db_path).into_iter().next().unwrap_or(NoteRecord {
        id: 0,
        title: payload.title,
        body: payload.body,
        created_at: Utc::now().to_rfc3339(),
    });
    Json(latest)
}

async fn create_evidence_handler(
    State(state): State<AppState>,
    Json(payload): Json<CreateEvidenceRequest>,
) -> Json<EvidenceRecord> {
    let safe_path = safe_attachment_path(&payload.attachment_path);
    create_evidence(&state.db_path, &payload.label, &payload.details, &safe_path);
    log_audit(&state.db_path, "evidence_create", &payload.label, "success");
    let latest = list_evidence(&state.db_path).into_iter().next().unwrap_or(EvidenceRecord {
        id: 0,
        label: payload.label,
        details: payload.details,
        attachment_path: safe_path,
        created_at: Utc::now().to_rfc3339(),
    });
    Json(latest)
}

async fn export_bundle_handler(State(state): State<AppState>) -> Json<ExportBundleResult> {
    let result = export_bundle(&state.db_path);
    log_audit(&state.db_path, "export_bundle", &result.export_file, "success");
    Json(result)
}

async fn chat_handler(
    State(state): State<AppState>,
    Json(payload): Json<ChatRequest>,
) -> Json<ChatResponse> {
    add_memory(&state.db_path, "user", &payload.message);

    let recommended = recommend_modules(&payload.message, state.modules.as_ref());
    let reply = assistant_reply(&payload.message, &recommended);

    {
        let mut assistant = state.assistant.lock().unwrap();
        assistant.last_message = reply.clone();
    }

    add_memory(&state.db_path, "assistant", &reply);
    log_audit(&state.db_path, "assistant_chat", "assistant", "success");

    let remembered_messages = list_memory(&state.db_path).len();

    Json(ChatResponse {
        reply,
        recommended_modules: recommended,
        remembered_messages,
    })
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
    AxumPath(mode): AxumPath<String>,
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
    AxumPath(id): AxumPath<String>,
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
        .route("/api/exports", get(exports_handler))
        .route("/api/memory", get(memory_handler))
        .route("/api/assistant/chat", post(chat_handler))
        .route("/api/notes/create", post(create_note_handler))
        .route("/api/evidence/create", post(create_evidence_handler))
        .route("/api/export/bundle", post(export_bundle_handler))
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

echo "== cargo check =="
cargo check

echo
echo "== Assistant upgrade complete =="
echo "Run:"
echo "  cargo run -p janus-runtime"
echo
echo "Then test:"
echo "  curl -X POST http://127.0.0.1:8080/api/assistant/chat -H 'Content-Type: application/json' -d '{\"message\":\"hello janus\"}'"
echo "  curl -X POST http://127.0.0.1:8080/api/assistant/chat -H 'Content-Type: application/json' -d '{\"message\":\"I need a note for this session\"}'"
echo "  curl -X POST http://127.0.0.1:8080/api/assistant/chat -H 'Content-Type: application/json' -d '{\"message\":\"show me evidence tools\"}'"
echo "  curl http://127.0.0.1:8080/api/memory"
echo "  curl http://127.0.0.1:8080/api/assistant"
