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
