set -e

mkdir -p legacy docs android recovery plugins/core/system_status plugins/core/encrypted_notes plugins/core/connectivity_summary
mkdir -p janus-core/src janus-runtime/src janus-tui/src janus-web/src
mkdir -p .github/workflows.disabled

mv .github/workflows/*.yml .github/workflows.disabled/ 2>/dev/null || true
[ -d src ] && mv src legacy/src-legacy || true
[ -f Cargo.toml ] && cp Cargo.toml legacy/Cargo.toml.legacy || true
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
pub enum ImplementationStatus {
    Implemented,
    Stub,
    Experimental,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum RuntimeMode {
    Launcher,
    Operator,
    Diagnostics,
    Maintenance,
    Recovery,
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
janus-core = { path = "../janus-core" }
EOT

cat > janus-runtime/src/main.rs <<'EOT'
use std::{fs, net::SocketAddr};

use axum::{extract::State, response::Json, routing::get, Router};
use janus_core::{ModuleManifest, RuntimeMode, RuntimeStatus};

#[derive(Clone)]
struct AppState {
    status: RuntimeStatus,
    modules: Vec<ModuleManifest>,
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

async fn status(State(state): State<AppState>) -> Json<RuntimeStatus> {
    Json(state.status)
}

async fn modules(State(state): State<AppState>) -> Json<Vec<ModuleManifest>> {
    Json(state.modules)
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let modules = load_modules();
    let status = RuntimeStatus {
        mode: RuntimeMode::Launcher,
        modules_loaded: modules.len(),
        assistant_enabled: true,
        ..RuntimeStatus::default()
    };

    let app = Router::new()
        .route("/api/status", get(status))
        .route("/api/modules", get(modules))
        .with_state(AppState { status, modules });

    let addr: SocketAddr = "0.0.0.0:8080".parse()?;
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
use janus_core::RuntimeStatus;

fn main() {
    let status = RuntimeStatus::default();
    println!("JANUS TUI MAINTENANCE MODE");
    println!("Product: {}", status.product_name);
    println!("Hardware Profile: {}", status.hardware_profile);
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

cat > docs/architecture.md <<'EOT'
# Janus Omega Architecture

Titan boots into an Android-based operator environment.
Janus acts as the primary launcher/runtime ecosystem.

Core components:
- janus-core
- janus-runtime
- janus-tui
- janus-web
- plugins
- android
- recovery
EOT

cat > docs/roadmap.md <<'EOT'
# Roadmap

- compile the workspace
- restore features incrementally
- add android launcher integration
- add maintenance and recovery modes
EOT

cat > README.md <<'EOT'
# Janus Omega OS

Janus Omega is being restructured into a Titan-targeted Android-first operator platform.

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

cargo check
