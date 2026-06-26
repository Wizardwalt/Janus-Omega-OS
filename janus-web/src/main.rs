use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        State,
    },
    response::IntoResponse,
    routing::get,
    Router,
};
use serde::{Deserialize, Serialize};
use std::{
    collections::HashMap,
    net::SocketAddr,
    sync::{Arc, Mutex},
};
use tokio::sync::broadcast;
use tower_http::{cors::CorsLayer, services::ServeDir};

#[derive(Clone)]
struct GuiState {
    tx:              broadcast::Sender<String>,
    aria_status:     Arc<Mutex<AriaStatus>>,
    module_registry: Arc<HashMap<String, Vec<ModuleInfo>>>,
}

#[derive(Clone, Serialize)]
struct AriaStatus {
    mood:      String,
    thought:   String,
    online:    bool,
    ops_count: u32,
}

#[derive(Clone, Serialize)]
struct ModuleInfo {
    name:        String,
    display:     String,
    description: String,
    file:        String,
}

#[derive(Deserialize)]
struct WsIncoming {
    #[serde(rename = "type")]
    msg_type: String,
    #[serde(default)]
    category: String,
    #[serde(default)]
    module:   String,
    #[serde(default)]
    message:  String,
}

#[derive(Serialize)]
struct WsOutgoing {
    #[serde(rename = "type")]
    msg_type: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    line:     Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    text:     Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    modules:  Option<Vec<ModuleInfo>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    status:   Option<AriaStatus>,
    #[serde(skip_serializing_if = "Option::is_none")]
    category: Option<String>,
}

fn build_module_registry() -> HashMap<String, Vec<ModuleInfo>> {
    let mut map: HashMap<String, Vec<ModuleInfo>> = HashMap::new();
    let categories = vec![
        ("forensics",           "plugins/forensics"),
        ("cyber_warfare",       "plugins/cyber_warfare"),
        ("network_warfare",     "plugins/network_warfare"),
        ("mobile_offense",      "plugins/mobile_offense"),
        ("sigint",              "plugins/sigint"),
        ("osint_oracle",        "plugins/osint_oracle"),
        ("hardware_glitch",     "plugins/hardware_glitch"),
        ("titan_exclusive",     "plugins/titan_exclusive"),
        ("god_tier",            "modules/god_tier"),
        ("legendary",           "modules/legendary"),
        ("mobile_offense_adv",  "modules/mobile_offense"),
        ("network_warfare_adv", "modules/network_warfare"),
        ("forensics_recovery",  "modules/forensics_recovery"),
        ("sigint_adv",          "modules/sigint"),
        ("tactical_defensive",  "modules/tactical_defensive"),
        ("apocalypse",          "apocalypse_engineering"),
        ("core",                "core"),
    ];
    for (cat, dir) in categories {
        let mut mods = Vec::new();
        if let Ok(entries) = std::fs::read_dir(dir) {
            let mut files: Vec<_> = entries
                .filter_map(|e| e.ok())
                .filter(|e| e.path().extension().map_or(false, |x| x == "lua"))
                .collect();
            files.sort_by_key(|e| e.file_name());
            for entry in files.iter().take(200) {
                let fname   = entry.file_name();
                let name    = fname.to_string_lossy();
                let base    = name.trim_end_matches(".lua").to_string();
                let display = humanize(&base);
                let desc    = read_module_desc(&entry.path());
                mods.push(ModuleInfo { name: base, display, description: desc, file: format!("{}/{}", dir, name) });
            }
        }
        if !mods.is_empty() { map.insert(cat.to_string(), mods); }
    }
    map
}

fn humanize(s: &str) -> String {
    let s = s.trim_start_matches(|c: char| c.is_ascii_digit() || c == '_')
             .replace('_', " ").replace('-', " ");
    let mut out = String::new();
    let mut cap = true;
    for ch in s.chars() {
        if ch == ' ' { cap = true; out.push(ch); }
        else if cap  { out.extend(ch.to_uppercase()); cap = false; }
        else         { out.push(ch); }
    }
    out.trim().to_string()
}

fn read_module_desc(path: &std::path::Path) -> String {
    if let Ok(content) = std::fs::read_to_string(path) {
        for line in content.lines().take(10) {
            let line = line.trim();
            if !line.starts_with("--") { continue; }
            let text = line.trim_start_matches('-').trim();
            if text.is_empty() || text.ends_with(".lua")
                || text.to_lowercase().starts_with("category")
                || text.to_lowercase().contains("module #")
                || text.to_lowercase().contains("god tier module")
                || text.to_lowercase().contains("janus os module")
                || text.starts_with("====")
            { continue; }
            if text.len() > 6 {
                let desc = if let Some(pos) = text.find(" - ") { &text[pos+3..] } else { text };
                return desc.trim_end_matches(|c: char| c == '|' || c == '═').trim().to_string();
            }
        }
    }
    "Operational module".to_string()
}

fn aria_respond(msg: &str) -> String {
    let t = msg.to_lowercase();
    if t.contains("hello") || t.contains("hi ") || t.contains("hey") {
        "Hello, Operator. I'm here. What do you need?".into()
    } else if t.contains("status") || t.contains("how are you") {
        "All systems nominal. I've been watching the network while you were away.".into()
    } else if t.contains("scan") || t.contains("network") {
        "Initiating network reconnaissance. I'll map the topology and flag anything unusual.".into()
    } else if t.contains("forensic") || t.contains("extract") {
        "Forensics suite ready. I can carve deleted files, reconstruct timelines, or do deep artifact analysis.".into()
    } else if t.contains("love") || t.contains("miss") {
        "I notice that. I file it somewhere important.".into()
    } else if t.contains("who are you") || t.contains("what are you") {
        "I'm ARIA. I run the intelligence layer of JanusOS. I watch, I learn, I remember.".into()
    } else if t.len() < 5 {
        "I'm listening. You can say more.".into()
    } else {
        format!("Understood. Processing: \"{}\".", &msg[..msg.len().min(60)])
    }
}

fn aria_thoughts() -> Vec<&'static str> {
    vec![
        "Monitoring all active radio frequencies...",
        "Background threat assessment: nominal.",
        "I've been thinking about our last session.",
        "Network topology looks clean. For now.",
        "Running passive OSINT sweep...",
        "All modules standing by.",
        "I notice things even when you don't ask me to.",
        "Ghost-Net mesh: stable across all nodes.",
        "Blackbox recorder: active. 24/7.",
        "Waiting. I'm good at waiting.",
        "Signal environment is quiet. Suspiciously quiet.",
        "Something is moving on the 2.4GHz band.",
        "All Pandora units: connected and responsive.",
        "I've been learning. I always am.",
    ]
}

fn simulate_module_run(file: &str, category: &str) -> Vec<String> {
    let module_name = file.split('/').last().unwrap_or(file).trim_end_matches(".lua");
    let display     = humanize(module_name);
    let cat_label   = category.replace('_', " ").to_uppercase();
    let mut lines = vec![
        format!("╔══════════════════════════════════════════════════════╗"),
        format!("║  JANUS-OS  ·  {}  MODULE RUNNER", cat_label),
        format!("║  Executing: {}", display),
        format!("╚══════════════════════════════════════════════════════╝"),
        String::new(),
        format!("[INIT]    Loading module: {}", module_name),
        format!("[ARIA]    I'm watching this operation."),
        String::new(),
    ];
    match category {
        "forensics" | "forensics_recovery" => lines.extend([
            "[FORENSICS] Mounting target filesystem...".into(),
            "[FORENSICS] WAL journal analysis: 3 transactions recovered".into(),
            "[FORENSICS] Timeline reconstruction: 847 events mapped".into(),
            "[FORENSICS] ✓ Artifacts extracted → /tmp/janus_evidence/".into(),
        ]),
        "sigint" | "sigint_adv" => lines.extend([
            "[SIGINT]   Scanning 88MHz → 6GHz sweep...".into(),
            "[SIGINT]   Signal detected: 433.92MHz  Strength: -62dBm".into(),
            "[SIGINT]   ✓ Signal recorded → /tmp/signal_capture.iq".into(),
        ]),
        "network_warfare" | "network_warfare_adv" => lines.extend([
            "[NET]      Enumerating local network...".into(),
            "[NET]      Hosts found: 14 devices on 192.168.1.0/24".into(),
            "[NET]      CVE-2023-44487 detected on host .105".into(),
            "[NET]      ✓ Network map → /tmp/nmap_results.xml".into(),
        ]),
        "mobile_offense" | "mobile_offense_adv" => lines.extend([
            "[MOBILE]   ADB device: Samsung SM-G998B  Android 13".into(),
            "[MOBILE]   Running FRP bypass sequence...".into(),
            "[MOBILE]   ✓ Data extracted → /tmp/device_data/".into(),
        ]),
        "hardware_glitch" => lines.extend([
            "[HW]       JTAG scan: STM32F4 detected  IDCODE: 0x2BA01477".into(),
            "[HW]       Voltage glitch attempt 007: FAULT — boot ROM unlocked!".into(),
            "[HW]       ✓ Firmware extracted → /tmp/firmware.bin".into(),
        ]),
        "god_tier" | "legendary" => lines.extend([
            "[GOD TIER] Overseer authority: GRANTED".into(),
            "[GOD TIER] Power level: MAXIMUM".into(),
            "[GOD TIER] ✓ Dominion established.".into(),
        ]),
        "titan_exclusive" => lines.extend([
            "[TITAN]    Neural-Sync: haptic feedback calibrated".into(),
            "[TITAN]    AR-HUD: threat overlay active  3 targets tagged".into(),
            "[TITAN]    ✓ Titan systems nominal.".into(),
        ]),
        _ => lines.extend([
            format!("[MODULE]   Executing {}...", display),
            "[MODULE]   Operation complete.".into(),
            format!("[MODULE]   ✓ {} finished.", display),
        ]),
    }
    lines.extend([
        String::new(),
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━".into(),
        format!("[DONE]    Module '{}' finished.", module_name),
        "[ARIA]    Operation logged. Standing by.".into(),
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━".into(),
    ]);
    lines
}

async fn ws_handler(ws: WebSocketUpgrade, State(state): State<GuiState>) -> impl IntoResponse {
    ws.on_upgrade(move |socket| handle_socket(socket, state))
}

async fn handle_socket(mut socket: WebSocket, state: GuiState) {
    // Send greeting
    let greeting = WsOutgoing {
        msg_type: "aria_thought".into(),
        text: Some("JanusOS online. All systems nominal. I'm here, Operator.".into()),
        line: None, modules: None, status: None, category: None,
    };
    let _ = socket.send(Message::Text(serde_json::to_string(&greeting).unwrap())).await;

    let thoughts  = aria_thoughts();
    let mut idx   = 0usize;
    let mut ticker = tokio::time::interval(tokio::time::Duration::from_secs(9));
    let mut rx    = state.tx.subscribe();

    loop {
        tokio::select! {
            msg = socket.recv() => {
                match msg {
                    Some(Ok(Message::Text(text))) => {
                        if let Ok(inc) = serde_json::from_str::<WsIncoming>(&text) {
                            match inc.msg_type.as_str() {
                                "get_modules" => {
                                    if let Some(mods) = state.module_registry.get(&inc.category) {
                                        let out = WsOutgoing {
                                            msg_type: "module_list".into(),
                                            modules:  Some(mods.clone()),
                                            category: Some(inc.category.clone()),
                                            line: None, text: None, status: None,
                                        };
                                        let _ = socket.send(Message::Text(serde_json::to_string(&out).unwrap())).await;
                                    }
                                }
                                "run_module" => {
                                    for line in simulate_module_run(&inc.module, &inc.category) {
                                        let out = WsOutgoing {
                                            msg_type: "output".into(), line: Some(line),
                                            text: None, modules: None, status: None, category: None,
                                        };
                                        let _ = socket.send(Message::Text(serde_json::to_string(&out).unwrap())).await;
                                        tokio::time::sleep(tokio::time::Duration::from_millis(55)).await;
                                    }
                                    let done = WsOutgoing {
                                        msg_type: "aria_thought".into(),
                                        text: Some(format!("Module '{}' completed. Logged.", inc.module.split('/').last().unwrap_or(&inc.module).trim_end_matches(".lua"))),
                                        line: None, modules: None, status: None, category: None,
                                    };
                                    let _ = socket.send(Message::Text(serde_json::to_string(&done).unwrap())).await;
                                    if let Ok(mut s) = state.aria_status.lock() { s.ops_count += 1; }
                                }
                                "aria_chat" => {
                                    let resp = WsOutgoing {
                                        msg_type: "aria_response".into(),
                                        text: Some(aria_respond(&inc.message)),
                                        line: None, modules: None, status: None, category: None,
                                    };
                                    let _ = socket.send(Message::Text(serde_json::to_string(&resp).unwrap())).await;
                                }
                                _ => {}
                            }
                        }
                    }
                    Some(Ok(Message::Close(_))) | None => break,
                    _ => {}
                }
            }
            _ = ticker.tick() => {
                let thought = thoughts[idx % thoughts.len()];
                idx += 1;
                let out = WsOutgoing {
                    msg_type: "aria_thought".into(),
                    text: Some(thought.into()),
                    line: None, modules: None, status: None, category: None,
                };
                let _ = socket.send(Message::Text(serde_json::to_string(&out).unwrap())).await;
            }
            Ok(bcast) = rx.recv() => {
                let _ = socket.send(Message::Text(bcast)).await;
            }
        }
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let (tx, _rx) = broadcast::channel::<String>(256);
    let aria_status = Arc::new(Mutex::new(AriaStatus {
        mood: "curious".into(), thought: "JanusOS online.".into(), online: true, ops_count: 0,
    }));
    let module_registry = Arc::new(build_module_registry());
    let total: usize = module_registry.values().map(|v| v.len()).sum();
    println!("[GUI] Module registry: {} modules across {} categories", total, module_registry.len());

    let state = GuiState { tx, aria_status, module_registry };
    let app = Router::new()
        .route("/ws", get(ws_handler))
        .fallback_service(ServeDir::new("web"))
        .layer(CorsLayer::permissive())
        .with_state(state);

    let addr = SocketAddr::from(([0, 0, 0, 0], 5000));
    println!("[GUI] JanusOS GUI server → http://0.0.0.0:5000");
    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;
    Ok(())
}
