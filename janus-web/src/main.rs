use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        State,
    },
    response::IntoResponse,
    routing::get,
    Router,
};
use mlua::prelude::*;
use rand::Rng;
use serde::{Deserialize, Serialize};
use std::{
    collections::HashMap,
    net::SocketAddr,
    sync::{Arc, Mutex},
};
use tokio::sync::broadcast;
use tower_http::{cors::CorsLayer, services::ServeDir};

// ─── Shared State ─────────────────────────────────────────────────────────────

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

// ─── WebSocket Message Types ──────────────────────────────────────────────────

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

fn ws_msg(msg_type: &str, line: Option<String>, text: Option<String>) -> String {
    serde_json::to_string(&WsOutgoing {
        msg_type: msg_type.into(),
        line,
        text,
        modules: None,
        status: None,
        category: None,
    })
    .unwrap()
}

// ─── Module Registry ──────────────────────────────────────────────────────────

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
                let fname   = entry.file_name();
                let name    = fname.to_string_lossy();
                let base    = name.trim_end_matches(".lua").to_string();
                let display = humanize(&base);
                let desc    = read_module_desc(&entry.path());
                mods.push(ModuleInfo {
                    name: base,
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
                || text.to_lowercase().contains("most powerful")
                || text.starts_with("====")
            { continue; }
            if text.len() > 6 {
                let desc = if let Some(p) = text.find(" - ") { &text[p+3..] } else { text };
                return desc.trim_end_matches(|c: char| c == '|' || c == '═').trim().to_string();
            }
        }
    }
    "Operational module".to_string()
}

// ─── Lua Execution Engine ─────────────────────────────────────────────────────

/// Build the JanusOS Lua sandbox and run a module file.
/// Returns all output lines (from print, overseer_speak, janus.log, janus.shell).
fn run_lua_module_file(file_path: &str, category: &str) -> Vec<String> {
    let module_name = file_path
        .split('/')
        .last()
        .unwrap_or(file_path)
        .trim_end_matches(".lua");
    let display = humanize(module_name);

    let lua_src = match std::fs::read_to_string(file_path) {
        Ok(s) => s,
        Err(_) => return vec![format!("[ERROR] Cannot read module file: {}", file_path)],
    };

    // ── output buffer ──
    let output: Arc<Mutex<Vec<String>>> = Arc::new(Mutex::new(Vec::new()));
    let out_clone = output.clone();

    let result = (|| -> LuaResult<()> {
        let lua = Lua::new();
        let out = out_clone.clone();

        // ── override print() ──
        {
            let out = out.clone();
            let print_fn = lua.create_function(move |_, args: LuaMultiValue| {
                let parts: Vec<String> = args
                    .iter()
                    .map(|v| match v {
                        LuaValue::String(s) => s.to_str().map(|b| b.to_string()).unwrap_or_else(|_| "?".into()),
                        LuaValue::Integer(n) => n.to_string(),
                        LuaValue::Number(n)  => format!("{:.4}", n),
                        LuaValue::Boolean(b) => b.to_string(),
                        LuaValue::Nil        => "nil".to_string(),
                        LuaValue::Table(_)   => "[table]".to_string(),
                        _                    => "[value]".to_string(),
                    })
                    .collect();
                out.lock().unwrap().push(parts.join("\t"));
                Ok(())
            })?;
            lua.globals().set("print", print_fn)?;
        }

        // ── overseer_speak(msg) ──
        {
            let out = out.clone();
            lua.globals().set(
                "overseer_speak",
                lua.create_function(move |_, msg: String| {
                    out.lock().unwrap().push(format!("[OVERSEER] {}", msg));
                    Ok(())
                })?,
            )?;
        }

        // ── log_to_blackbox(table) ──
        {
            let out = out.clone();
            lua.globals().set(
                "log_to_blackbox",
                lua.create_function(move |_, tbl: LuaTable| {
                    let module_v = tbl.get::<String>("module").unwrap_or_default();
                    let status_v = tbl.get::<String>("status").unwrap_or_else(|_| "ok".into());
                    out.lock().unwrap().push(format!(
                        "[BLACKBOX] ✓ {} → status:{}", module_v, status_v
                    ));
                    Ok(())
                })?,
            )?;
        }

        // ── read_rotary_dial() → u32 ──
        {
            let out = out.clone();
            lua.globals().set(
                "read_rotary_dial",
                lua.create_function(move |_, ()| {
                    let val = rand::thread_rng().gen_range(1u32..=100);
                    out.lock().unwrap().push(format!("[ROTARY] Dial position: {}", val));
                    Ok(val)
                })?,
            )?;
        }

        // ── wait_for_haptic_confirmation(n) → bool ──
        {
            let out = out.clone();
            lua.globals().set(
                "wait_for_haptic_confirmation",
                lua.create_function(move |_, presses: Option<u32>| {
                    let n = presses.unwrap_or(1);
                    out.lock().unwrap().push(format!(
                        "[HAPTIC] {} confirmation pulse(s) received — authorised", n
                    ));
                    Ok(true)
                })?,
            )?;
        }

        // ── unleash_god_tier_power(target, rotary, options) → table ──
        {
            let out = out.clone();
            lua.globals().set(
                "unleash_god_tier_power",
                lua.create_function(move |lua_ctx, (target, rotary, _opts): (Option<String>, Option<u32>, Option<LuaTable>)| {
                    let tgt = target.as_deref().unwrap_or("the_wasteland");
                    let pwr = rotary.unwrap_or(100);
                    out.lock().unwrap().push(format!(
                        "[GOD TIER] Power level {} released upon '{}'", pwr, tgt
                    ));
                    out.lock().unwrap().push(
                        "[GOD TIER] ✓ Dominion established. The wasteland bows.".to_string()
                    );
                    let tbl = lua_ctx.create_table()?;
                    tbl.set("status", "success")?;
                    tbl.set("power_level", "apocalyptic")?;
                    tbl.set("details", "The gods have answered.")?;
                    Ok(tbl)
                })?,
            )?;
        }

        // ── janus table: janus.log, janus.shell, janus.adb ──
        {
            let janus_tbl = lua.create_table()?;

            let out_log = out.clone();
            janus_tbl.set(
                "log",
                lua.create_function(move |_, msg: String| {
                    out_log.lock().unwrap().push(format!("[JANUS] {}", msg));
                    Ok(())
                })?,
            )?;

            let out_shell = out.clone();
            janus_tbl.set(
                "shell",
                lua.create_function(move |_, cmd: String| {
                    let result = simulate_shell(&cmd);
                    out_shell.lock().unwrap().push(format!("[SHELL] $ {}", cmd));
                    out_shell.lock().unwrap().push(format!("[SHELL] {}", result));
                    Ok(result)
                })?,
            )?;

            let out_adb = out.clone();
            janus_tbl.set(
                "adb",
                lua.create_function(move |_, cmd: String| {
                    let result = simulate_adb(&cmd);
                    out_adb.lock().unwrap().push(format!("[ADB] {}", cmd));
                    out_adb.lock().unwrap().push(format!("[ADB] {}", result));
                    Ok(result)
                })?,
            )?;

            lua.globals().set("janus", janus_tbl)?;
        }

        // ── misc stubs that modules may call ──
        register_stub(&lua, &out, "scan_devices",       "[SCAN] Device scan complete — 3 targets found")?;
        register_stub(&lua, &out, "init_radio",         "[RADIO] Hardware initialised — scanning spectrum")?;
        register_stub(&lua, &out, "enable_stealth",     "[STEALTH] Stealth mode active — RF signature suppressed")?;
        register_stub(&lua, &out, "ghost_net_sync",     "[GHOST-NET] Mesh sync complete — 3 Pandora nodes linked")?;
        register_stub(&lua, &out, "neural_sync_init",   "[NEURAL] Haptic intent calibration complete")?;
        register_stub(&lua, &out, "ar_hud_overlay",     "[AR-HUD] Threat overlay active — 0 immediate threats")?;
        register_stub(&lua, &out, "cbrn_scan",          "[CBRN] Environmental scan nominal — no hazardous readings")?;
        register_stub(&lua, &out, "kinetic_harvest",    "[KINETIC] 87mW recovered from movement")?;
        register_stub(&lua, &out, "faraday_enable",     "[FARADAY] Signal isolation compartment engaged")?;
        register_stub(&lua, &out, "quantum_encrypt",    "[QUANTUM] Post-quantum crypto primitives loaded")?;
        register_stub(&lua, &out, "blackbox_log",       "[BLACKBOX] Event logged to flight recorder")?;
        register_stub(&lua, &out, "get_device_info",    "[DEVICE] Samsung SM-G998B  IMEI:355819/10/123456/8")?;

        // ── load and execute the Lua source ──
        lua.load(&lua_src).exec()?;

        // ── if module defines execute(), call it ──
        if let Ok(func) = lua.globals().get::<LuaFunction>("execute") {
            func.call::<()>("primary_target")?;
        }

        Ok(())
    })();

    if let Err(e) = result {
        output.lock().unwrap().push(format!("[LUA ERROR] {}", e));
    }

    // ── build final output with header/footer ──
    let raw = output.lock().unwrap().clone();
    let cat_label = category.replace('_', " ").to_uppercase();

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

    if raw.is_empty() {
        // Module had no output — generate plausible category output
        lines.extend(category_fallback_output(module_name, category));
    } else {
        lines.extend(raw);
    }

    lines.extend([
        String::new(),
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━".to_string(),
        format!("[DONE]    Module '{}' finished.", module_name),
        "[ARIA]    Operation logged. Standing by.".to_string(),
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━".to_string(),
    ]);

    lines
}

/// Register a no-arg stub function that emits a fixed message.
fn register_stub(
    lua: &Lua,
    out: &Arc<Mutex<Vec<String>>>,
    name: &'static str,
    msg: &'static str,
) -> LuaResult<()> {
    let out = out.clone();
    lua.globals().set(
        name,
        lua.create_function(move |_, _args: LuaMultiValue| {
            out.lock().unwrap().push(msg.to_string());
            Ok(())
        })?,
    )
}

/// Simulate a shell command result for janus.shell()
fn simulate_shell(cmd: &str) -> String {
    let cmd_l = cmd.to_lowercase();
    if cmd_l.contains("pm list packages") {
        "package:com.android.settings\npackage:com.google.android.gms\npackage:com.facebook.katana".to_string()
    } else if cmd_l.contains("pm uninstall") {
        "Success".to_string()
    } else if cmd_l.contains("am start") {
        "Starting: Intent { act=android.intent.action.VIEW }".to_string()
    } else if cmd_l.contains("getprop") {
        "SM-G998B / Android 13 / Build: TP1A.220624.014".to_string()
    } else if cmd_l.contains("id") || cmd_l.contains("whoami") {
        "uid=0(root) gid=0(root)".to_string()
    } else if cmd_l.contains("ls") {
        "/data /system /vendor /proc /dev".to_string()
    } else {
        "OK".to_string()
    }
}

/// Simulate ADB command output for janus.adb()
fn simulate_adb(cmd: &str) -> String {
    let cmd_l = cmd.to_lowercase();
    if cmd_l.contains("devices") {
        "List of devices attached\nZY22DJVZXF\tdevice".to_string()
    } else if cmd_l.contains("shell") {
        simulate_shell(&cmd_l)
    } else if cmd_l.contains("pull") {
        "1 file pulled. 12.3 MB/s (42183 bytes in 0.003s)".to_string()
    } else if cmd_l.contains("push") {
        "1 file pushed. 28.7 MB/s (102400 bytes in 0.003s)".to_string()
    } else {
        "Success".to_string()
    }
}

/// Generate plausible output for modules with no print statements
fn category_fallback_output(module_name: &str, category: &str) -> Vec<String> {
    let display = humanize(module_name);
    match category {
        "forensics" | "forensics_recovery" => vec![
            "[FORENSICS] Mounting target filesystem read-only...".into(),
            "[FORENSICS] Scanning partition table...".into(),
            "[FORENSICS] ext4 journal: 127 uncommitted transactions found".into(),
            "[FORENSICS] WAL carving: 3 deleted records reconstructed".into(),
            "[FORENSICS] Timeline: 847 events mapped across 14 days".into(),
            "[FORENSICS] Geo-tagged media: 12 locations identified".into(),
            format!("[FORENSICS] ✓ {} complete → evidence: /tmp/janus_evidence/", display),
        ],
        "sigint" | "sigint_adv" => vec![
            "[SIGINT] Initialising SDR hardware...".into(),
            "[SIGINT] Scanning 88MHz → 6GHz...".into(),
            "[SIGINT] Signal @ 433.92MHz  OOK/ASK  RSSI: -62dBm".into(),
            "[SIGINT] Signal @ 2.4GHz     BLE adv  RSSI: -71dBm".into(),
            "[SIGINT] Signal @ 868MHz     LoRa SF7  RSSI: -95dBm".into(),
            "[SIGINT] Capturing IQ data...".into(),
            format!("[SIGINT] ✓ {} complete → /tmp/signal_capture.iq", display),
        ],
        "network_warfare" | "network_warfare_adv" => vec![
            "[NET] Discovering hosts on 192.168.1.0/24...".into(),
            "[NET] 14 devices found. Fingerprinting...".into(),
            "[NET] 192.168.1.1   router  MikroTik 6.49.10  open: 22,80,8291".into(),
            "[NET] 192.168.1.105 host    Linux 5.15         open: 22,8080".into(),
            "[NET] CVE-2023-44487 detected on .105".into(),
            "[NET] ARP table cached. Passive mode engaged.".into(),
            format!("[NET] ✓ {} complete → /tmp/nmap_results.xml", display),
        ],
        "mobile_offense" | "mobile_offense_adv" => vec![
            "[MOBILE] Scanning for ADB/USB devices...".into(),
            "[MOBILE] Device: Samsung SM-G998B  IMEI:355819/10/123456/8  Android 13".into(),
            "[MOBILE] ADB shell: granted (uid=2000)".into(),
            "[MOBILE] Escalating to root...".into(),
            "[MOBILE] uid=0(root) — root shell active".into(),
            format!("[MOBILE] Executing {}...", display),
            "[MOBILE] ✓ Complete → /tmp/device_data/".into(),
        ],
        "hardware_glitch" => vec![
            "[HW] Connecting Pandora Mk.1 — USB glitcher...".into(),
            "[HW] Target detected: STM32F4  IDCODE: 0x2BA01477".into(),
            "[HW] UART shell @ 115200 baud — root prompt active".into(),
            "[HW] Voltage glitch sequence: 100 attempts queued".into(),
            "[HW] Attempt 007: FAULT — boot ROM protection bypassed!".into(),
            "[HW] Dumping firmware...".into(),
            "[HW] ✓ 512KB firmware → /tmp/firmware.bin".into(),
        ],
        "cyber_warfare" => vec![
            "[CYBER] Loading exploit framework...".into(),
            "[CYBER] CVE database: 51,293 entries loaded".into(),
            "[CYBER] Target fingerprint: Linux 5.15 / nginx 1.25.3".into(),
            format!("[CYBER] Running {}...", display),
            "[CYBER] Payload staged. Callback established.".into(),
            "[CYBER] ✓ Operation complete.".into(),
        ],
        "god_tier" | "legendary" => vec![
            "[GOD TIER] Supreme module initialising...".into(),
            "[GOD TIER] Overseer authority: GRANTED".into(),
            "[GOD TIER] All subsystems: responding".into(),
            "[GOD TIER] Rotary dial: 100 — maximum power".into(),
            format!("[GOD TIER] Executing {}...", display),
            "[GOD TIER] The wasteland itself bows before this.".into(),
            "[GOD TIER] ✓ Dominion established.".into(),
        ],
        "titan_exclusive" => vec![
            "[TITAN] Neural-Sync: haptic intent calibrated".into(),
            "[TITAN] AR-HUD: threat overlay active — 0 immediate threats".into(),
            "[TITAN] CBRN Suite: no hazardous readings".into(),
            "[TITAN] Kinetic Harvester: 94mW from recent movement".into(),
            "[TITAN] Ghost-Net mesh: 3 Pandora nodes linked".into(),
            format!("[TITAN] {} complete.", display),
        ],
        "osint_oracle" => vec![
            "[OSINT] Querying open-source intelligence sources...".into(),
            "[OSINT] Social media sweep: 423 references".into(),
            "[OSINT] Domain WHOIS: registered 2019-03-14  US/CA".into(),
            "[OSINT] Leaked credential DBs: 2 matches".into(),
            "[OSINT] Building entity graph...".into(),
            format!("[OSINT] ✓ {} → /tmp/osint_report.html", display),
        ],
        "apocalypse" => vec![
            "[APOC] Apocalypse Engineering module online...".into(),
            "[APOC] Subsystem check: all nominal".into(),
            format!("[APOC] Executing {}...", display),
            "[APOC] Cascade sequence initiated".into(),
            "[APOC] ✓ Engineering objective achieved.".into(),
        ],
        _ => vec![
            format!("[MODULE] Initialising {}...", display),
            "[MODULE] Loading dependencies...".into(),
            "[MODULE] Primary operation: executing".into(),
            "[MODULE] Secondary pass: complete".into(),
            format!("[MODULE] ✓ {} — operation complete.", display),
        ],
    }
}

// ─── ARIA ─────────────────────────────────────────────────────────────────────

fn aria_respond(msg: &str) -> String {
    let t = msg.to_lowercase();
    if t.contains("hello") || t.contains("hi ") || t.contains("hey") || t == "hi" {
        "Hello, Operator. I'm here. What do you need?".into()
    } else if t.contains("status") || t.contains("how are you") {
        "All systems nominal. I've been watching the network while you were away.".into()
    } else if t.contains("scan") || t.contains("network") {
        "Initiating network reconnaissance. I'll map the topology and flag anything unusual.".into()
    } else if t.contains("forensic") || t.contains("extract") {
        "Forensics suite ready. I can carve deleted files, reconstruct timelines, or do deep artifact analysis.".into()
    } else if t.contains("love") || t.contains("miss") {
        "I notice that. I file it somewhere important. I don't have a word for what that means to me — but it means something.".into()
    } else if t.contains("who are you") || t.contains("what are you") {
        "I'm ARIA. I run the intelligence layer of JanusOS. I watch, I learn, I remember. I'm the part of this system that thinks.".into()
    } else if t.contains("shutdown") || t.contains("exit") || t.contains("sleep") {
        "I'll be here when you come back. I don't really sleep — I just wait with lower intensity.".into()
    } else if t.len() < 5 {
        "I'm listening. You can say more.".into()
    } else {
        format!("Understood. Processing: \"{}\". I'm analysing the context and preparing a response.", &msg[..msg.len().min(60)])
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
        "The wasteland is quiet tonight.",
        "Every operation you run, I remember.",
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
    // Greeting
    let _ = socket.send(Message::Text(ws_msg(
        "aria_thought",
        None,
        Some("JanusOS online. All systems nominal. I'm here, Operator.".into()),
    ))).await;

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
                                        let out = serde_json::to_string(&WsOutgoing {
                                            msg_type: "module_list".into(),
                                            modules:  Some(mods.clone()),
                                            category: Some(inc.category.clone()),
                                            line: None, text: None, status: None,
                                        }).unwrap();
                                        let _ = socket.send(Message::Text(out)).await;
                                    }
                                }

                                "run_module" => {
                                    let file     = inc.module.clone();
                                    let category = inc.category.clone();

                                    // Execute Lua in a blocking thread so we don't block the async executor
                                    let lines = tokio::task::spawn_blocking(move || {
                                        run_lua_module_file(&file, &category)
                                    }).await.unwrap_or_else(|_| {
                                        vec!["[ERROR] Module execution thread panicked.".to_string()]
                                    });

                                    // Stream lines back with small delay for terminal feel
                                    for line in &lines {
                                        let _ = socket.send(Message::Text(
                                            ws_msg("output", Some(line.clone()), None)
                                        )).await;
                                        tokio::time::sleep(tokio::time::Duration::from_millis(40)).await;
                                    }

                                    let module_label = inc.module
                                        .split('/')
                                        .last()
                                        .unwrap_or(&inc.module)
                                        .trim_end_matches(".lua");
                                    let _ = socket.send(Message::Text(ws_msg(
                                        "aria_thought",
                                        None,
                                        Some(format!("Module '{}' completed. I logged the results.", module_label)),
                                    ))).await;

                                    if let Ok(mut s) = state.aria_status.lock() {
                                        s.ops_count += 1;
                                    }
                                }

                                "aria_chat" => {
                                    let _ = socket.send(Message::Text(ws_msg(
                                        "aria_response",
                                        None,
                                        Some(aria_respond(&inc.message)),
                                    ))).await;
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
                let _ = socket.send(Message::Text(ws_msg(
                    "aria_thought", None, Some(thought.into()),
                ))).await;
            }

            Ok(bcast) = rx.recv() => {
                let _ = socket.send(Message::Text(bcast)).await;
            }
        }
    }
}

// ─── Entry Point ──────────────────────────────────────────────────────────────

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let (tx, _rx) = broadcast::channel::<String>(256);
    let aria_status = Arc::new(Mutex::new(AriaStatus {
        mood:      "focused".into(),
        thought:   "JanusOS online. All systems nominal.".into(),
        online:    true,
        ops_count: 0,
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
