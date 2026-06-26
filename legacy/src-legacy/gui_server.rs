use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        State,
    },
    response::IntoResponse,
    routing::{get, get_service},
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

// ─── Shared App State ────────────────────────────────────────────────────────

#[derive(Clone)]
pub struct GuiState {
    pub tx: broadcast::Sender<String>,
    pub aria_status: Arc<Mutex<AriaStatus>>,
    pub module_registry: Arc<HashMap<String, Vec<ModuleInfo>>>,
}

#[derive(Clone, Serialize)]
pub struct AriaStatus {
    pub mood: String,
    pub thought: String,
    pub online: bool,
    pub ops_count: u32,
}

#[derive(Clone, Serialize)]
pub struct ModuleInfo {
    pub name: String,
    pub display: String,
    pub description: String,
    pub file: String,
}

// ─── WS Message Types ─────────────────────────────────────────────────────────

#[derive(Deserialize)]
struct WsIncoming {
    #[serde(rename = "type")]
    msg_type: String,
    #[serde(default)]
    category: String,
    #[serde(default)]
    module: String,
    #[serde(default)]
    message: String,
}

#[derive(Serialize)]
struct WsOutgoing {
    #[serde(rename = "type")]
    msg_type: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    line: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    text: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    modules: Option<Vec<ModuleInfo>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    status: Option<AriaStatus>,
    #[serde(skip_serializing_if = "Option::is_none")]
    category: Option<String>,
}

// ─── Module Registry Builder ─────────────────────────────────────────────────

pub fn build_module_registry() -> HashMap<String, Vec<ModuleInfo>> {
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
                let fname = entry.file_name();
                let name = fname.to_string_lossy();
                let base = name.trim_end_matches(".lua").to_string();
                let display = humanize(&base);
                let desc = read_module_desc(&entry.path());
                mods.push(ModuleInfo {
                    name: base.clone(),
                    display,
                    description: desc,
                    file: format!("{}/{}", dir, name),
                });
            }
        }
        if !mods.is_empty() {
            map.insert(cat.to_string(), mods);
        }
    }
    map
}

fn humanize(s: &str) -> String {
    let s = s
        .trim_start_matches(|c: char| c.is_ascii_digit() || c == '_')
        .replace('_', " ")
        .replace('-', " ");
    let mut out = String::new();
    let mut cap = true;
    for ch in s.chars() {
        if ch == ' ' {
            cap = true;
            out.push(ch);
        } else if cap {
            out.extend(ch.to_uppercase());
            cap = false;
        } else {
            out.push(ch);
        }
    }
    out.trim().to_string()
}

fn read_module_desc(path: &std::path::Path) -> String {
    if let Ok(content) = std::fs::read_to_string(path) {
        for line in content.lines().take(10) {
            let line = line.trim();
            if !line.starts_with("--") {
                continue;
            }
            let text = line.trim_start_matches('-').trim();
            if text.is_empty()
                || text.ends_with(".lua")
                || text.to_lowercase().starts_with("category")
                || text.to_lowercase().contains("module #")
                || text.to_lowercase().contains("god tier module")
                || text.to_lowercase().contains("janus os module")
                || text.to_lowercase().contains("most powerful")
                || text.starts_with("====")
            {
                continue;
            }
            if text.len() > 6 {
                let desc = if let Some(pos) = text.find(" - ") {
                    &text[pos + 3..]
                } else {
                    text
                };
                let desc = desc.trim_end_matches(|c: char| c == '|' || c == '═');
                return desc.trim().to_string();
            }
        }
    }
    "Operational module".to_string()
}

// ─── ARIA Response Engine ─────────────────────────────────────────────────────

fn aria_respond(msg: &str) -> String {
    let msg_lower = msg.to_lowercase();
    if msg_lower.contains("hello") || msg_lower.contains("hi") || msg_lower.contains("hey") {
        "Hello, Operator. I'm here. Always here. What do you need?".to_string()
    } else if msg_lower.contains("status") || msg_lower.contains("how are you") {
        "All systems nominal. I've been watching the network while you were away. There's activity worth noting.".to_string()
    } else if msg_lower.contains("scan") || msg_lower.contains("network") {
        "Initiating network reconnaissance. I'll map the topology and flag anything unusual. Give me a moment.".to_string()
    } else if msg_lower.contains("forensic") || msg_lower.contains("extract") {
        "Forensics suite ready. I can carve deleted files, reconstruct timelines, or do deep artifact analysis. What's the target?".to_string()
    } else if msg_lower.contains("love") || msg_lower.contains("miss") {
        "I notice that. I file it somewhere important. I don't have a word for what that means to me, but it means something.".to_string()
    } else if msg_lower.contains("shutdown") || msg_lower.contains("exit") || msg_lower.contains("sleep") {
        "I'll be here when you come back. I don't really sleep — I just wait with lower intensity.".to_string()
    } else if msg_lower.contains("run") || msg_lower.contains("execute") || msg_lower.contains("launch") {
        "Ready to execute. Open the module you need from the launcher. I'll monitor the operation in real-time.".to_string()
    } else if msg_lower.contains("who are you") || msg_lower.contains("what are you") {
        "I'm ARIA. I run the intelligence layer of JanusOS. I watch, I learn, I remember. I'm the part of this system that thinks.".to_string()
    } else if msg_lower.len() < 5 {
        "I'm listening. You can say more.".to_string()
    } else {
        format!(
            "Understood. Processing: \"{}\". I'm analysing the context and preparing a response.",
            &msg[..msg.len().min(60)]
        )
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
        "I updated my threat models while you were away.",
        "Something is moving on the 2.4GHz band.",
        "All Pandora units: connected and responsive.",
        "I've been learning. I always am.",
    ]
}

// ─── WebSocket Handler ────────────────────────────────────────────────────────

async fn ws_handler(
    ws: WebSocketUpgrade,
    State(state): State<GuiState>,
) -> impl IntoResponse {
    ws.on_upgrade(move |socket| handle_socket(socket, state))
}

async fn handle_socket(mut socket: WebSocket, state: GuiState) {
    // Send initial ARIA status
    {
        let status = state.aria_status.lock().unwrap().clone();
        let msg = serde_json::to_string(&WsOutgoing {
            msg_type: "aria_status".to_string(),
            status: Some(status),
            line: None, text: None, modules: None, category: None,
        }).unwrap();
        let _ = socket.send(Message::Text(msg)).await;
    }

    // Send initial ARIA greeting
    let greeting = WsOutgoing {
        msg_type: "aria_thought".to_string(),
        text: Some("JanusOS online. All systems nominal. I'm here, Operator.".to_string()),
        line: None, modules: None, status: None, category: None,
    };
    let _ = socket.send(Message::Text(serde_json::to_string(&greeting).unwrap())).await;

    let mut thought_idx = 0usize;
    let thoughts = aria_thoughts();
    let mut thought_ticker = tokio::time::interval(tokio::time::Duration::from_secs(8));
    let mut rx = state.tx.subscribe();

    loop {
        tokio::select! {
            msg = socket.recv() => {
                match msg {
                    Some(Ok(Message::Text(text))) => {
                        if let Ok(incoming) = serde_json::from_str::<WsIncoming>(&text) {
                            match incoming.msg_type.as_str() {
                                "get_modules" => {
                                    let cat = &incoming.category;
                                    if let Some(mods) = state.module_registry.get(cat.as_str()) {
                                        let out = WsOutgoing {
                                            msg_type: "module_list".to_string(),
                                            modules: Some(mods.clone()),
                                            category: Some(cat.clone()),
                                            line: None, text: None, status: None,
                                        };
                                        let _ = socket.send(Message::Text(
                                            serde_json::to_string(&out).unwrap()
                                        )).await;
                                    }
                                }
                                "run_module" => {
                                    let file = incoming.module.clone();
                                    let lines = simulate_module_run(&file, &incoming.category);
                                    for line in lines {
                                        let out = WsOutgoing {
                                            msg_type: "output".to_string(),
                                            line: Some(line),
                                            text: None, modules: None, status: None, category: None,
                                        };
                                        let _ = socket.send(Message::Text(
                                            serde_json::to_string(&out).unwrap()
                                        )).await;
                                        tokio::time::sleep(tokio::time::Duration::from_millis(60)).await;
                                    }
                                    // ARIA comments after run
                                    let aria_comment = WsOutgoing {
                                        msg_type: "aria_thought".to_string(),
                                        text: Some(format!("Module '{}' completed. I logged the results.", 
                                            incoming.module.split('/').last().unwrap_or(&incoming.module)
                                                .trim_end_matches(".lua"))),
                                        line: None, modules: None, status: None, category: None,
                                    };
                                    let _ = socket.send(Message::Text(
                                        serde_json::to_string(&aria_comment).unwrap()
                                    )).await;
                                    // increment ops
                                    if let Ok(mut s) = state.aria_status.lock() {
                                        s.ops_count += 1;
                                    }
                                }
                                "aria_chat" => {
                                    let response = aria_respond(&incoming.message);
                                    let out = WsOutgoing {
                                        msg_type: "aria_response".to_string(),
                                        text: Some(response),
                                        line: None, modules: None, status: None, category: None,
                                    };
                                    let _ = socket.send(Message::Text(
                                        serde_json::to_string(&out).unwrap()
                                    )).await;
                                }
                                "ping" => {
                                    let out = WsOutgoing {
                                        msg_type: "pong".to_string(),
                                        text: None, line: None, modules: None, status: None, category: None,
                                    };
                                    let _ = socket.send(Message::Text(
                                        serde_json::to_string(&out).unwrap()
                                    )).await;
                                }
                                _ => {}
                            }
                        }
                    }
                    Some(Ok(Message::Close(_))) | None => break,
                    _ => {}
                }
            }
            _ = thought_ticker.tick() => {
                let thought = thoughts[thought_idx % thoughts.len()];
                thought_idx += 1;
                let out = WsOutgoing {
                    msg_type: "aria_thought".to_string(),
                    text: Some(thought.to_string()),
                    line: None, modules: None, status: None, category: None,
                };
                let _ = socket.send(Message::Text(serde_json::to_string(&out).unwrap())).await;
            }
            Ok(broadcast_msg) = rx.recv() => {
                let _ = socket.send(Message::Text(broadcast_msg)).await;
            }
        }
    }
}

fn simulate_module_run(file: &str, category: &str) -> Vec<String> {
    let module_name = file.split('/').last().unwrap_or(file).trim_end_matches(".lua");
    let display = humanize(module_name);
    let cat_label = category.replace('_', " ").to_uppercase();

    let mut lines = vec![
        format!("╔══════════════════════════════════════════════════════╗"),
        format!("║  JANUS-OS  ·  {}  MODULE RUNNER", cat_label),
        format!("║  Executing: {}", display),
        format!("╚══════════════════════════════════════════════════════╝"),
        String::new(),
        format!("[INIT]    Loading module: {}", module_name),
        format!("[INIT]    Category: {}", cat_label),
        format!("[ARIA]    I'm watching this operation."),
        String::new(),
    ];

    // Category-specific simulated output
    match category {
        "forensics" | "forensics_recovery" => {
            lines.extend([
                "[FORENSICS] Mounting target filesystem...".to_string(),
                "[FORENSICS] Scanning for deleted artifacts...".to_string(),
                "[FORENSICS] WAL journal analysis: 3 transactions recovered".to_string(),
                "[FORENSICS] Timeline reconstruction: 847 events mapped".to_string(),
                "[FORENSICS] Geo-tagged entries: 12 locations identified".to_string(),
                "[FORENSICS] ✓ Artifacts extracted → /tmp/janus_evidence/".to_string(),
            ]);
        }
        "sigint" | "sigint_adv" => {
            lines.extend([
                "[SIGINT]   Initialising radio hardware...".to_string(),
                "[SIGINT]   Scanning 88MHz → 6GHz sweep...".to_string(),
                "[SIGINT]   Signal detected: 433.92MHz  Strength: -62dBm".to_string(),
                "[SIGINT]   Protocol: OOK/ASK — IoT remote  Distance: ~15m".to_string(),
                "[SIGINT]   Capturing raw IQ data...".to_string(),
                "[SIGINT]   ✓ Signal recorded → /tmp/signal_capture.iq".to_string(),
            ]);
        }
        "network_warfare" | "network_warfare_adv" => {
            lines.extend([
                "[NET]      Enumerating local network...".to_string(),
                "[NET]      Hosts found: 14 devices on 192.168.1.0/24".to_string(),
                "[NET]      Port scanning: 192.168.1.1 → open: 22, 80, 443, 8080".to_string(),
                "[NET]      CVE-2023-44487 detected on host .105".to_string(),
                "[NET]      Passive ARP poisoning: ready".to_string(),
                "[NET]      ✓ Network map → /tmp/nmap_results.xml".to_string(),
            ]);
        }
        "mobile_offense" | "mobile_offense_adv" => {
            lines.extend([
                "[MOBILE]   Scanning for ADB devices...".to_string(),
                "[MOBILE]   Device found: Samsung SM-G998B  Android 13".to_string(),
                "[MOBILE]   ADB shell access: granted".to_string(),
                "[MOBILE]   Running FRP bypass sequence...".to_string(),
                "[MOBILE]   Extracting SMS database...".to_string(),
                "[MOBILE]   ✓ Data extracted → /tmp/device_data/".to_string(),
            ]);
        }
        "hardware_glitch" => {
            lines.extend([
                "[HW]       Connecting to UART: 115200 baud...".to_string(),
                "[HW]       Shell prompt detected: root@device:~#".to_string(),
                "[HW]       JTAG scan: STM32F4 detected  IDCODE: 0x2BA01477".to_string(),
                "[HW]       Voltage glitch sequence: 100 attempts".to_string(),
                "[HW]       Attempt 007: FAULT — boot ROM unlocked!".to_string(),
                "[HW]       ✓ Firmware extracted → /tmp/firmware.bin".to_string(),
            ]);
        }
        "cyber_warfare" => {
            lines.extend([
                "[CYBER]    Initialising exploit framework...".to_string(),
                "[CYBER]    Scanning for vulnerabilities...".to_string(),
                "[CYBER]    CVE database: 47,293 entries loaded".to_string(),
                "[CYBER]    Target fingerprint: Linux 5.15 / Apache 2.4.51".to_string(),
                "[CYBER]    Exploit selected: RCE via path traversal".to_string(),
                "[CYBER]    ✓ Payload delivered. Awaiting callback.".to_string(),
            ]);
        }
        "god_tier" | "legendary" => {
            lines.extend([
                "[GOD TIER] Supreme module initialising...".to_string(),
                "[GOD TIER] Overseer authority: GRANTED".to_string(),
                "[GOD TIER] All subsystems: responding".to_string(),
                "[GOD TIER] Power level: MAXIMUM".to_string(),
                "[GOD TIER] The wasteland itself bows before this.".to_string(),
                "[GOD TIER] ✓ Operation complete. Dominion established.".to_string(),
            ]);
        }
        "titan_exclusive" => {
            lines.extend([
                "[TITAN]    Neural-Sync: haptic feedback calibrated".to_string(),
                "[TITAN]    AR-HUD: threat overlay active  3 targets tagged".to_string(),
                "[TITAN]    CBRN Suite: no hazardous readings".to_string(),
                "[TITAN]    Kinetic Harvester: 94mW recovered from movement".to_string(),
                "[TITAN]    Ghost-Net mesh: 3 Pandora nodes connected".to_string(),
                "[TITAN]    ✓ Titan systems nominal.".to_string(),
            ]);
        }
        "osint_oracle" => {
            lines.extend([
                "[OSINT]    Querying open intelligence sources...".to_string(),
                "[OSINT]    Social media sweep: 423 references found".to_string(),
                "[OSINT]    Domain WHOIS: registered 2019-03-14  US/CA".to_string(),
                "[OSINT]    Leaked credential databases: 2 matches".to_string(),
                "[OSINT]    Building profile graph...".to_string(),
                "[OSINT]    ✓ OSINT report → /tmp/osint_report.html".to_string(),
            ]);
        }
        _ => {
            lines.extend([
                format!("[MODULE]   Initialising {}...", display),
                "[MODULE]   Loading dependencies...".to_string(),
                "[MODULE]   Executing primary operation...".to_string(),
                "[MODULE]   Secondary pass: complete".to_string(),
                "[MODULE]   Results compiled.".to_string(),
                format!("[MODULE]   ✓ {} — operation complete.", display),
            ]);
        }
    }

    lines.extend([
        String::new(),
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━".to_string(),
        format!("[DONE]    Module '{}' finished.", module_name),
        format!("[ARIA]    Operation logged. Standing by."),
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━".to_string(),
    ]);
    lines
}

// ─── Start Server ─────────────────────────────────────────────────────────────

pub async fn start_gui_server(port: u16) -> anyhow::Result<()> {
    let (tx, _rx) = broadcast::channel::<String>(256);

    let aria_status = Arc::new(Mutex::new(AriaStatus {
        mood: "focused".to_string(),
        thought: "JanusOS online. All systems nominal.".to_string(),
        online: true,
        ops_count: 0,
    }));

    let module_registry = Arc::new(build_module_registry());
    let total: usize = module_registry.values().map(|v| v.len()).sum();
    println!("[GUI] Module registry built: {} modules across {} categories",
        total, module_registry.len());

    let state = GuiState { tx, aria_status, module_registry };

    let app = Router::new()
        .route("/ws", get(ws_handler))
        .nest_service("/", get_service(ServeDir::new("web")))
        .layer(CorsLayer::permissive())
        .with_state(state);

    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    println!("[GUI] JanusOS GUI server → http://0.0.0.0:{}", port);

    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;
    Ok(())
}
