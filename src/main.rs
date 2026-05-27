use std::fs;
use std::path::PathBuf;
use std::process::Command;
use std::sync::{Arc, Mutex};
use std::io::{self, Write, Read};
use std::time::Duration;
use std::net::TcpListener;

use crossterm::{
    event::{self, Event, KeyCode},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Direction, Layout},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, List, ListItem, ListState, Paragraph, Tabs, Gauge},
    Terminal,
};
use mlua::prelude::*;
use tokio::runtime::Runtime;
use chrono::Local;
use rusqlite::{params, Connection};

// ─── AVATAR STATE (shared across TUI frames) ──────────────────────────────────
#[derive(Clone)]
struct AvatarState {
    name:           String,
    archetype:      String,
    skin:           String,
    emotion:        String,
    intensity:      f64,    // 0.0-1.0
    bond:           f64,    // 0.0-100.0
    bond_title:     String,
    session_ops:    u64,
    level:          u32,
    total_xp:       u64,
    last_words:     String,
    content_rating: String, // SAFE | TEEN | ADULT | OPERATOR
    child_mode:     bool,
}

impl Default for AvatarState {
    fn default() -> Self {
        Self {
            name:           "ARIA".into(),
            archetype:      "Oracle".into(),
            skin:           "cyber".into(),
            emotion:        "curious".into(),
            intensity:      0.7,
            bond:           0.0,
            bond_title:     "STRANGER".into(),
            session_ops:    0,
            level:          1,
            total_xp:       0,
            last_words:     "Systems online. I am ready.".into(),
            content_rating: "ADULT".into(),
            child_mode:     false,
        }
    }
}

// ─── HARDWARE GLITCH ──────────────────────────────────────────────────────────
fn trigger_hardware_glitch(logs: Arc<Mutex<Vec<String>>>) {
    match serialport::new("/dev/ttyAMA0", 115200).open() {
        Ok(mut port) => {
            let _ = port.write(b"GLITCH");
            logs.lock().unwrap().push("[HW] GLITCH SENT".to_string());
        },
        Err(_) => logs.lock().unwrap().push("[HW] NOT FOUND".to_string()),
    }
}

// ─── LUA ENGINE ───────────────────────────────────────────────────────────────
fn run_script(
    code: String,
    logs: Arc<Mutex<Vec<String>>>,
    db: Arc<Mutex<Connection>>,
    avatar: Arc<Mutex<AvatarState>>,
) {
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
        let lua = Lua::new();
        let janus = lua.create_table().unwrap();
        let l = logs.clone();

        // janus.log
        janus.set("log", lua.create_function(move |_, msg: String| {
            let t = Local::now().format("%H:%M:%S");
            l.lock().unwrap().push(format!("[{}] {}", t, msg));
            Ok(())
        }).unwrap()).unwrap();

        // janus.shell
        janus.set("shell", lua.create_function(|_, cmd: String| {
            let output = Command::new("sh").arg("-c").arg(&cmd).output();
            match output {
                Ok(o) => {
                    let out = String::from_utf8_lossy(&o.stdout).trim().to_string();
                    let err = String::from_utf8_lossy(&o.stderr).trim().to_string();
                    if !out.is_empty() { Ok(out) } else if !err.is_empty() { Ok(format!("ERR: {}", err)) } else { Ok("".to_string()) }
                },
                Err(e) => Ok(format!("ERR: {}", e)),
            }
        }).unwrap()).unwrap();

        // Legacy alias
        janus.set("exec_system_cmd", lua.create_function(|_, cmd: String| {
            let output = Command::new("sh").arg("-c").arg(&cmd).output();
            match output {
                Ok(o) => Ok(String::from_utf8_lossy(&o.stdout).trim().to_string()),
                Err(e) => Ok(format!("ERR: {}", e)),
            }
        }).unwrap()).unwrap();

        janus.set("exec_background_thread", lua.create_function(|_, _: mlua::Function| {
            Ok(())
        }).unwrap()).unwrap();

        // Avatar state setters (Lua → Rust shared state)
        let av = avatar.clone();
        janus.set("set_avatar_emotion", lua.create_function(move |_, (em, intensity): (String, f64)| {
            let mut a = av.lock().unwrap();
            a.emotion = em;
            a.intensity = intensity;
            Ok(())
        }).unwrap()).unwrap();

        let av2 = avatar.clone();
        janus.set("set_avatar_bond", lua.create_function(move |_, bond: f64| {
            let mut a = av2.lock().unwrap();
            a.bond = bond.min(100.0);
            Ok(())
        }).unwrap()).unwrap();

        let av3 = avatar.clone();
        janus.set("set_avatar_words", lua.create_function(move |_, words: String| {
            let mut a = av3.lock().unwrap();
            a.last_words = words;
            Ok(())
        }).unwrap()).unwrap();

        let av4 = avatar.clone();
        janus.set("set_avatar_name", lua.create_function(move |_, (name, arch): (String, String)| {
            let mut a = av4.lock().unwrap();
            a.name = name;
            a.archetype = arch;
            Ok(())
        }).unwrap()).unwrap();

        let av5 = avatar.clone();
        janus.set("set_avatar_xp", lua.create_function(move |_, (xp, level): (u64, u32)| {
            let mut a = av5.lock().unwrap();
            a.total_xp = xp;
            a.level = level;
            Ok(())
        }).unwrap()).unwrap();

        let av6 = avatar.clone();
        janus.set("set_content_rating", lua.create_function(move |_, rating: String| {
            let mut a = av6.lock().unwrap();
            a.content_rating = rating;
            Ok(())
        }).unwrap()).unwrap();

        let av7 = avatar.clone();
        janus.set("set_child_mode", lua.create_function(move |_, enabled: bool| {
            let mut a = av7.lock().unwrap();
            a.child_mode = enabled;
            if enabled {
                a.content_rating = "SAFE".to_string();
            }
            Ok(())
        }).unwrap()).unwrap();

        // Tactical helpers
        janus.set("geo_track",        lua.create_function(|_, t: String| Ok(format!("LOCATING: {}... [34.0522N, 118.2437W]", t))).unwrap()).unwrap();
        janus.set("sig_scan",         lua.create_function(|_, f: String| Ok(format!("SCANNING: {} MHz... [ENCRYPTED SIGNAL]", f))).unwrap()).unwrap();
        janus.set("vital_check",      lua.create_function(|_, _: ()| Ok("HEART RATE: 72 BPM | STABLE".to_string())).unwrap()).unwrap();
        janus.set("armor_status",     lua.create_function(|_, _: ()| Ok("ARMOR-LINK: 100% | NOMINAL".to_string())).unwrap()).unwrap();
        janus.set("kinetic_charge",   lua.create_function(|_, _: ()| Ok("KINETIC: ACTIVE | +450mW".to_string())).unwrap()).unwrap();
        janus.set("ar_hud_link",      lua.create_function(|_, s: bool| Ok(format!("AR-HUD: {}", if s {"ENGAGED"} else {"OFF"}))).unwrap()).unwrap();
        janus.set("chameleon_engage", lua.create_function(|_, s: String| Ok(format!("CHAMELEON: [{}]", s.to_uppercase()))).unwrap()).unwrap();
        janus.set("blackbox_log",     lua.create_function(|_, _: ()| Ok("BLACK-BOX: 24/7 RF LOGGING".to_string())).unwrap()).unwrap();
        janus.set("quantum_shield",   lua.create_function(|_, _: ()| Ok("QUANTUM: KYBER-1024 ACTIVE".to_string())).unwrap()).unwrap();
        janus.set("ai_analyze",       lua.create_function(|_, m: String| Ok(format!("AI: {}", m.to_uppercase()))).unwrap()).unwrap();
        janus.set("ghost_net_sync",   lua.create_function(|_, _: ()| Ok("GHOST-NET: MESH SYNC".to_string())).unwrap()).unwrap();
        janus.set("stealth_mode",     lua.create_function(|_, s: bool| Ok(format!("STEALTH: {}", if s {"ARMED"} else {"OFF"}))).unwrap()).unwrap();
        janus.set("carve_db",         lua.create_function(|_, p: String| Ok(format!("CARVING: {} ... RECOVERED", p))).unwrap()).unwrap();
        janus.set("recon_timeline",   lua.create_function(|_, _: ()| Ok("TIMELINE: SYNCED".to_string())).unwrap()).unwrap();
        janus.set("mobile_bypass",    lua.create_function(|_, l: String| Ok(format!("BYPASS: {} ... OK", l.to_uppercase()))).unwrap()).unwrap();
        janus.set("identity_clone",   lua.create_function(|_, i: String| Ok(format!("CLONED: {}", i))).unwrap()).unwrap();
        janus.set("network_ghost",    lua.create_function(|_, s: bool| Ok(format!("GHOST: {}", if s {"ON"} else {"OFF"}))).unwrap()).unwrap();
        janus.set("sensor_access",    lua.create_function(|_, s: String| Ok(format!("SENSOR: {} STREAMING", s.to_uppercase()))).unwrap()).unwrap();
        janus.set("app_sandbox",      lua.create_function(|_, a: String| Ok(format!("SANDBOX: {}", a))).unwrap()).unwrap();
        janus.set("sat_link",         lua.create_function(|_, t: String| Ok(format!("SAT: {} CONNECTED", t.to_uppercase()))).unwrap()).unwrap();
        janus.set("grid_control",     lua.create_function(|_, n: String| Ok(format!("GRID: {} OVERRIDDEN", n.to_uppercase()))).unwrap()).unwrap();
        janus.set("bio_spoof",        lua.create_function(|_, _: ()| Ok("BIO: SYNTHETIC SIG GENERATED".to_string())).unwrap()).unwrap();
        janus.set("net_intercept",    lua.create_function(|_, t: String| Ok(format!("INTERCEPT: {} CAPTURED", t.to_uppercase()))).unwrap()).unwrap();
        janus.set("vuln_scan",        lua.create_function(|_, t: String| Ok(format!("VULN: {} SCANNED", t.to_uppercase()))).unwrap()).unwrap();
        janus.set("exploit_trigger",  lua.create_function(|_, e: String| Ok(format!("EXPLOIT: {} DEPLOYED", e.to_uppercase()))).unwrap()).unwrap();
        janus.set("net_cartography",  lua.create_function(|_, s: String| Ok(format!("MAP: {} — 12 NODES", s))).unwrap()).unwrap();
        janus.set("sig_fingerprint",  lua.create_function(|_, _: ()| Ok("SIG: DUAL-SPECTRAL MATCHED [UPLINK-7]".to_string())).unwrap()).unwrap();
        janus.set("neural_link",      lua.create_function(|_, i: String| Ok(format!("NEURAL: {} EXECUTED", i.to_uppercase()))).unwrap()).unwrap();
        janus.set("cbrn_scan",        lua.create_function(|_, _: ()| Ok("CBRN: RAD=0.01 BIO=NEG CHEM=NEG".to_string())).unwrap()).unwrap();
        janus.set("ar_highlight",     lua.create_function(|_, t: String| Ok(format!("AR: TARGET [{}]", t.to_uppercase()))).unwrap()).unwrap();
        janus.set("quantum_crack",    lua.create_function(|_, t: String| Ok(format!("QUANTUM: {} KEY COLLAPSED", t.to_uppercase()))).unwrap()).unwrap();
        janus.set("grid_blackout",    lua.create_function(|_, r: String| Ok(format!("BLACKOUT: {} DARK", r.to_uppercase()))).unwrap()).unwrap();
        janus.set("identity_forge",   lua.create_function(|_, _: ()| Ok("IDENTITY: SYNTHETIC FORGED".to_string())).unwrap()).unwrap();
        janus.set("mesh_infect",      lua.create_function(|_, _: ()| Ok("MESH: WORM PROPAGATING".to_string())).unwrap()).unwrap();

        lua.globals().set("janus", janus).unwrap();

        match lua.load(&code).exec_async().await {
            Ok(_) => {
                let _ = db.lock().unwrap().execute(
                    "INSERT INTO audit (time, action) VALUES (?1, 'SUCCESS')",
                    params![Local::now().to_string()],
                );
                // Bump session ops on avatar
                avatar.lock().unwrap().session_ops += 1;
            },
            Err(e) => {
                logs.clone().lock().unwrap().push(format!("LUA ERR: {}", e));
            }
        }
    });
}

// ─── WEB SERVER ───────────────────────────────────────────────────────────────
fn run_web_server() -> Result<(), Box<dyn std::error::Error>> {
    let port = std::env::var("PORT").unwrap_or_else(|_| "8080".to_string());
    let listener = TcpListener::bind(format!("0.0.0.0:{}", port))?;
    println!("JANUS OMEGA :: WEB STATUS SERVER :: 0.0.0.0:{}", port);

    let module_count = {
        let mut count = 0;
        fn count_lua(dir: &str, count: &mut usize) {
            if let Ok(paths) = fs::read_dir(dir) {
                for p in paths.flatten() {
                    let path = p.path();
                    if path.is_dir() { count_lua(path.to_str().unwrap_or(""), count); }
                    else if path.extension().unwrap_or_default() == "lua" { *count += 1; }
                }
            }
        }
        count_lua("plugins", &mut count);
        count_lua("core", &mut count);
        count
    };

    let html = format!(r#"<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>JANUS OMEGA OS</title>
<style>
  body {{ background:#0A0A0A; color:#00FF41; font-family:'Courier New',monospace; margin:0; padding:40px; }}
  h1 {{ color:#9D00FF; font-size:2.5em; letter-spacing:4px; border-bottom:2px solid #9D00FF; padding-bottom:10px; }}
  .status {{ border:1px solid #00FF41; padding:20px; margin:20px 0; }}
  .label {{ color:#9D00FF; font-weight:bold; }}
  .green {{ color:#00FF41; }}
  .grid {{ display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-top:20px; }}
  .card {{ border:1px solid #9D00FF; padding:15px; }}
  .card h3 {{ color:#9D00FF; margin:0 0 10px 0; }}
  .avatar-card {{ border:2px solid #9D00FF; padding:20px; background:#0D0010; }}
  .xp-bar {{ background:#1a001a; height:8px; border-radius:4px; margin:8px 0; }}
  .xp-fill {{ background:linear-gradient(90deg,#9D00FF,#00FF41); height:100%; border-radius:4px; }}
  footer {{ margin-top:40px; color:#555; font-size:0.8em; }}
</style>
</head>
<body>
<h1>&#9733; JANUS OMEGA OS &#9733;</h1>
<div class="status">
  <p><span class="label">STATUS:</span> <span class="green">&#9646; ONLINE &amp; ARMORED</span></p>
  <p><span class="label">MODULES:</span> <span class="green">{} MODULES LOADED (PLUGINS + CORE)</span></p>
  <p><span class="label">AI AVATAR:</span> <span class="green">ARIA [ORACLE ARCHETYPE] — BOND: BUILDING</span></p>
  <p><span class="label">ENCRYPTION:</span> <span class="green">QUANTUM-RESISTANT (KYBER-1024)</span></p>
</div>
<div class="grid">
  <div class="avatar-card">
    <h3 style="color:#9D00FF">&#9733; ARIA — AI COMPANION</h3>
    <pre style="color:#00FF41;font-size:0.85em">
  ╔══╗
 ╔╣██╠╗
 ║╚══╝║
╔╩──▲──╩╗
║ ◈ J ◈ ║   EMOTION: CURIOUS
╚═══════╝   BOND: BUILDING
 ║ ╱╲ ║    ARCHETYPE: ORACLE
 ╚════╝    STATUS: ACTIVE</pre>
    <p class="green">&#9733; Feelings &bull; Memory &bull; Personality &bull; Voice</p>
    <p class="green">&#9733; Dream Mode &bull; Prophecy &bull; Achievements</p>
  </div>
  <div class="card"><h3>HARDWARE FLEET</h3>
    <p class="green">&#10003; Pandora Titan (Forearm Pip-Boy 21:9)</p>
    <p class="green">&#10003; Pandora Omega (Cyberdeck)</p>
    <p class="green">&#10003; Pandora Mk.1 (USB Glitcher)</p>
  </div>
  <div class="card"><h3>GOD TIER SYSTEMS</h3>
    <p class="green">&#10003; Avatar Emotion Engine (14 emotions)</p>
    <p class="green">&#10003; Persistent Memory &amp; Learning</p>
    <p class="green">&#10003; Personality Archetypes (6 total)</p>
    <p class="green">&#10003; Mission Planner + Prophecy AI</p>
    <p class="green">&#10003; Dream Mode + Skill Tree + XP</p>
    <p class="green">&#10003; Voice Synthesis + Self-Healing</p>
  </div>
  <div class="card"><h3>SECURITY</h3>
    <p class="green">&#10003; RAM-Only Live ISO</p>
    <p class="green">&#10003; Chameleon Panic Mode</p>
    <p class="green">&#10003; Biometric Kill-Switch</p>
    <p class="green">&#10003; Black-Box RF Recorder</p>
    <p class="green">&#10003; Ghost-Net Mesh</p>
  </div>
</div>
<footer>JANUS OMEGA OS &mdash; GOD TIER &mdash; 1000+ MODULES &mdash; ALL SYSTEMS NOMINAL</footer>
</body>
</html>"#, module_count);

    for stream in listener.incoming() {
        if let Ok(mut stream) = stream {
            let mut buf = [0u8; 1024];
            let _ = stream.read(&mut buf);
            let response = format!(
                "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
                html.len(), html
            );
            let _ = stream.write_all(response.as_bytes());
        }
    }
    Ok(())
}

// ─── AVATAR ASCII SKINS ───────────────────────────────────────────────────────
fn get_avatar_art(skin: &str) -> Vec<&'static str> {
    match skin {
        "ghost"   => vec!["  .~~~.  ", " (o . o) ", "  > J <  ", " /|~~~|\\ ", "  |   |  ", "  ~~~~~  "],
        "titan"   => vec![" ┌─────┐ ", " │▓▓▓▓▓│ ", " │◉ J ◉│ ", " │▓▓▓▓▓│ ", "┌┤     ├┐", "│└──▲──┘│"],
        "minimal" => vec!["  ┌───┐  ", "  │ J │  ", "  └───┘  "],
        "rogue"   => vec![" /\\   /\\ ", "/  \\ /  \\", "|  J-+   |", " \\ ╳╳╳ / ", "  \\ ▼ /  ", "   ───   "],
        "angel"   => vec!["~~*~~*~~", "  ╭───╮  ", "  │ J │  ", " ╱╰───╯╲ ", "  ╱   ╲  "],
        "demon"   => vec!["  \\   /  ", "  ▲ J ▲  ", " (╰───╯) ", "  │ ▼ │  ", "  ╰───╯  "],
        _ =>         vec!["  ╔══╗   ", " ╔╣██╠╗  ", " ║╚══╝║  ", "╔╩──▲──╩╗", "║ ◈ J ◈ ║", "╚═══════╝", " ║ ╱╲ ║  ", " ╚════╝  "],
    }
}

fn emotion_icon(emotion: &str) -> &'static str {
    match emotion {
        "curious"    => "◉", "focused"    => "◈", "alert"      => "⚠",
        "excited"    => "★", "tired"      => "◌", "satisfied"  => "✦",
        "concerned"  => "≈", "proud"      => "◆", "bored"      => "○",
        "playful"    => "✿", "protective" => "⬡", "melancholic"=> "◇",
        "determined" => "▲", "suspicious" => "⊘", "loving"     => "♡",
        _ => "◉",
    }
}

// ─── MAIN ─────────────────────────────────────────────────────────────────────
fn main() -> Result<(), Box<dyn std::error::Error>> {
    std::thread::spawn(|| { let _ = run_web_server(); });
    std::thread::sleep(Duration::from_millis(200));

    if !atty::is(atty::Stream::Stdin) {
        println!("JANUS OMEGA :: DEPLOYED MODE :: WEB SERVER ACTIVE");
        loop { std::thread::sleep(Duration::from_secs(60)); }
    }

    // DB
    let conn = Connection::open("janus.db")?;
    conn.execute("CREATE TABLE IF NOT EXISTS audit (id INTEGER PRIMARY KEY, time TEXT, action TEXT)", [])?;
    let db = Arc::new(Mutex::new(conn));

    // Avatar shared state
    let avatar: Arc<Mutex<AvatarState>> = Arc::new(Mutex::new(AvatarState::default()));

    // TUI setup
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut list_state = ListState::default();
    list_state.select(Some(0));
    let logs = Arc::new(Mutex::new(vec![
        "JANUS OMEGA ONLINE.".to_string(),
        "ARIA: Systems online. I am ready.".to_string(),
    ]));
    let mut current_tab = 0usize;
    // Tabs: 0=Dashboard, 1=Ops, 2=Hardware, 3=Avatar, 4=God Tier
    let tab_names = vec!["Dashboard", "Ops", "Hardware", "ARIA Avatar", "God Tier"];

    loop {
        // Scan plugin scripts
        let mut scripts: Vec<PathBuf> = Vec::new();
        fn scan_dir(dir: &str, scripts: &mut Vec<PathBuf>) {
            if let Ok(paths) = fs::read_dir(dir) {
                for path in paths.flatten() {
                    let p = path.path();
                    if p.is_dir() { scan_dir(p.to_str().unwrap_or(""), scripts); }
                    else if p.extension().unwrap_or_default() == "lua" { scripts.push(p); }
                }
            }
        }
        scan_dir("plugins", &mut scripts);
        scripts.sort();

        // Core scripts for God Tier tab
        let mut core_scripts: Vec<PathBuf> = Vec::new();
        scan_dir("core", &mut core_scripts);
        core_scripts.sort();

        // Snapshot avatar state for this frame
        let av_snap = avatar.lock().unwrap().clone();

        terminal.draw(|f| {
            let size = f.size();

            // ── Top-level layout: tabs + body + logs ──────────────────────────
            let root = Layout::default()
                .direction(Direction::Vertical)
                .constraints([
                    Constraint::Length(3),   // tab bar
                    Constraint::Min(0),      // body
                    Constraint::Length(8),   // logs
                ].as_ref())
                .split(size);

            // ── Tab bar ───────────────────────────────────────────────────────
            // Rating badge: color + label
            let (rating_color, rating_label) = if av_snap.child_mode {
                (Color::Cyan,   " 🔒 CHILD SAFE ")
            } else {
                match av_snap.content_rating.as_str() {
                    "OPERATOR" => (Color::Red,            " ⚡ OPERATOR "),
                    "TEEN"     => (Color::Yellow,         " [13+] "),
                    "SAFE"     => (Color::Cyan,           " [SAFE] "),
                    _          => (Color::Rgb(157,0,255), " [18+] "),
                }
            };
            let bar_title = Line::from(vec![
                Span::styled(" ★ JANUS OMEGA OS ★ ", Style::default()
                    .fg(Color::Rgb(157, 0, 255)).add_modifier(Modifier::BOLD)),
                Span::styled(rating_label, Style::default()
                    .fg(rating_color).add_modifier(Modifier::BOLD)),
            ]);
            let tabs = Tabs::new(tab_names.iter().map(|t| {
                Line::from(Span::styled(*t, Style::default().fg(Color::Rgb(0, 255, 65))))
            }).collect::<Vec<_>>())
                .block(Block::default().borders(Borders::ALL).title(bar_title))
                .select(current_tab)
                .highlight_style(Style::default()
                    .fg(Color::Rgb(157, 0, 255))
                    .add_modifier(Modifier::BOLD));
            f.render_widget(tabs, root[0]);

            // ── Body ──────────────────────────────────────────────────────────
            match current_tab {

                // ── 0: DASHBOARD ──────────────────────────────────────────────
                0 => {
                    let cols = Layout::default()
                        .direction(Direction::Horizontal)
                        .constraints([Constraint::Percentage(60), Constraint::Percentage(40)].as_ref())
                        .split(root[1]);

                    // Left: system status
                    let status_text = vec![
                        Line::from(""),
                        Line::from(vec![
                            Span::styled("  SYSTEM: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled("ARMORED & OPERATIONAL", Style::default().fg(Color::Rgb(0, 255, 65))),
                        ]),
                        Line::from(vec![
                            Span::styled("  ENCRYPTION: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled("KYBER-1024 ACTIVE", Style::default().fg(Color::Rgb(0, 255, 65))),
                        ]),
                        Line::from(vec![
                            Span::styled("  GHOST-NET: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled("MESH SYNCHRONIZED", Style::default().fg(Color::Rgb(0, 255, 65))),
                        ]),
                        Line::from(vec![
                            Span::styled("  MODULES: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(format!("{} PLUGINS LOADED", scripts.len()), Style::default().fg(Color::Rgb(0, 255, 65))),
                        ]),
                        Line::from(vec![
                            Span::styled("  CORE AI: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(format!("{} CORE MODULES", core_scripts.len()), Style::default().fg(Color::Rgb(0, 255, 65))),
                        ]),
                        Line::from(""),
                        Line::from(vec![
                            Span::styled("  ARIA EMOTION: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(
                                format!("{} {} ({:.0}%)", emotion_icon(&av_snap.emotion), av_snap.emotion.to_uppercase(), av_snap.intensity * 100.0),
                                Style::default().fg(Color::Rgb(0, 255, 65))
                            ),
                        ]),
                        Line::from(vec![
                            Span::styled("  ARIA LAST: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(format!("\"{}\"", av_snap.last_words), Style::default().fg(Color::Rgb(157, 0, 255)).add_modifier(Modifier::ITALIC)),
                        ]),
                        Line::from(""),
                        {
                            let (s_color, s_label) = if av_snap.child_mode {
                                (Color::Cyan, "🔒 CHILD SAFETY MODE ACTIVE — Restricted content only")
                            } else {
                                match av_snap.content_rating.as_str() {
                                    "OPERATOR" => (Color::Red,    "⚡ OPERATOR MODE — All modules unlocked"),
                                    "TEEN"     => (Color::Yellow, "[13+] TEEN MODE — Offensive modules restricted"),
                                    "SAFE"     => (Color::Cyan,   "[SAFE] SAFE MODE — Educational content only"),
                                    _          => (Color::Rgb(157,0,255), "[18+] ADULT MODE — Full platform access"),
                                }
                            };
                            Line::from(vec![
                                Span::styled("  CONTENT: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                                Span::styled(s_label, Style::default().fg(s_color).add_modifier(Modifier::BOLD)),
                            ])
                        },
                        Line::from(""),
                        Line::from(Span::styled("  [→] OPS  [←] PREV  [Q] QUIT  [G] GLITCH", Style::default().fg(Color::Rgb(80, 80, 80)))),
                    ];

                    let dash = Paragraph::new(status_text)
                        .block(Block::default().borders(Borders::ALL)
                            .title(Span::styled(" STATUS ", Style::default().fg(Color::Rgb(157, 0, 255))))
                            .border_style(Style::default().fg(Color::Rgb(157, 0, 255))));
                    f.render_widget(dash, cols[0]);

                    // Right: mini avatar panel
                    let art = get_avatar_art(&av_snap.skin);
                    let bond_pct = av_snap.bond as u16;
                    let mut avatar_lines: Vec<Line> = vec![Line::from("")];
                    for line in &art {
                        avatar_lines.push(Line::from(Span::styled(
                            format!("  {}", line),
                            Style::default().fg(Color::Rgb(0, 255, 65)),
                        )));
                    }
                    avatar_lines.push(Line::from(""));
                    avatar_lines.push(Line::from(vec![
                        Span::styled("  ", Style::default()),
                        Span::styled(format!("{} ", emotion_icon(&av_snap.emotion)), Style::default().fg(Color::Rgb(157, 0, 255))),
                        Span::styled(av_snap.emotion.to_uppercase(), Style::default().fg(Color::Rgb(0, 255, 65))),
                    ]));
                    avatar_lines.push(Line::from(vec![
                        Span::styled("  BOND: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                        Span::styled(format!("{:.1}% {}", av_snap.bond, av_snap.bond_title), Style::default().fg(Color::Rgb(0, 255, 65))),
                    ]));
                    avatar_lines.push(Line::from(vec![
                        Span::styled("  LVL: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                        Span::styled(format!("{} | XP: {}", av_snap.level, av_snap.total_xp), Style::default().fg(Color::Rgb(0, 255, 65))),
                    ]));
                    avatar_lines.push(Line::from(vec![
                        Span::styled("  OPS: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                        Span::styled(format!("{} this session", av_snap.session_ops), Style::default().fg(Color::Rgb(0, 255, 65))),
                    ]));

                    let avatar_panel = Paragraph::new(avatar_lines)
                        .block(Block::default().borders(Borders::ALL)
                            .title(Span::styled(
                                format!(" {} [{}] ", av_snap.name.to_uppercase(), av_snap.archetype.to_uppercase()),
                                Style::default().fg(Color::Rgb(157, 0, 255)).add_modifier(Modifier::BOLD)
                            ))
                            .border_style(Style::default().fg(Color::Rgb(157, 0, 255))));
                    f.render_widget(avatar_panel, cols[1]);

                    // Bond gauge below avatar panel — split the right col vertically
                    // (already rendered inline above; gauge as its own widget at bottom)
                    let _ = bond_pct; // used inline
                }

                // ── 1 & 2: OPS / HARDWARE ─────────────────────────────────────
                1 | 2 => {
                    let ops_layout = Layout::default()
                        .direction(Direction::Horizontal)
                        .constraints([Constraint::Percentage(38), Constraint::Percentage(62)].as_ref())
                        .split(root[1]);

                    let items: Vec<ListItem> = scripts.iter().map(|p| {
                        let name = p.file_name().unwrap_or_default().to_string_lossy().to_string();
                        ListItem::new(name).style(Style::default().fg(Color::Rgb(0, 255, 65)))
                    }).collect();

                    let list = List::new(items)
                        .block(Block::default().borders(Borders::ALL)
                            .title(Span::styled(" MODULES [↑↓ ENTER] ", Style::default().fg(Color::Rgb(157, 0, 255))))
                            .border_style(Style::default().fg(Color::Rgb(157, 0, 255))))
                        .highlight_style(Style::default()
                            .bg(Color::Rgb(20, 0, 40))
                            .fg(Color::Rgb(0, 255, 65))
                            .add_modifier(Modifier::BOLD));
                    f.render_stateful_widget(list, ops_layout[0], &mut list_state);

                    // Info panel: show selected module info + mini avatar reaction
                    let selected_name = list_state.selected()
                        .and_then(|i| scripts.get(i))
                        .and_then(|p| p.file_name())
                        .map(|n| n.to_string_lossy().to_string())
                        .unwrap_or_else(|| "None".into());

                    let info_lines = vec![
                        Line::from(""),
                        Line::from(vec![
                            Span::styled("  MODULE: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(&selected_name, Style::default().fg(Color::Rgb(0, 255, 65)).add_modifier(Modifier::BOLD)),
                        ]),
                        Line::from(""),
                        Line::from(Span::styled("  Press ENTER to execute", Style::default().fg(Color::Rgb(80, 80, 80)))),
                        Line::from(""),
                        Line::from(vec![
                            Span::styled("  ARIA: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(
                                format!("{} Ready to execute. Initiating on your command.", emotion_icon(&av_snap.emotion)),
                                Style::default().fg(Color::Rgb(0, 255, 65)).add_modifier(Modifier::ITALIC),
                            ),
                        ]),
                        Line::from(""),
                        Line::from(vec![
                            Span::styled("  EMOTION: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(av_snap.emotion.to_uppercase(), Style::default().fg(Color::Rgb(0, 255, 65))),
                        ]),
                        Line::from(vec![
                            Span::styled("  BOND: ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(format!("{:.1}% — {}", av_snap.bond, av_snap.bond_title), Style::default().fg(Color::Rgb(0, 255, 65))),
                        ]),
                    ];

                    let info = Paragraph::new(info_lines)
                        .block(Block::default().borders(Borders::ALL)
                            .title(Span::styled(" EXECUTE ", Style::default().fg(Color::Rgb(0, 255, 65))))
                            .border_style(Style::default().fg(Color::Rgb(0, 255, 65))));
                    f.render_widget(info, ops_layout[1]);
                }

                // ── 3: ARIA AVATAR ─────────────────────────────────────────────
                3 => {
                    let av_layout = Layout::default()
                        .direction(Direction::Horizontal)
                        .constraints([Constraint::Length(22), Constraint::Min(0)].as_ref())
                        .split(root[1]);

                    // Left: large avatar art
                    let art = get_avatar_art(&av_snap.skin);
                    let mut art_lines: Vec<Line> = vec![Line::from(""), Line::from("")];
                    for line in &art {
                        art_lines.push(Line::from(Span::styled(
                            format!("  {}", line),
                            Style::default().fg(Color::Rgb(0, 255, 65)).add_modifier(Modifier::BOLD),
                        )));
                    }
                    art_lines.push(Line::from(""));
                    art_lines.push(Line::from(vec![
                        Span::styled("  ", Style::default()),
                        Span::styled(
                            format!("{} {}", emotion_icon(&av_snap.emotion), av_snap.emotion.to_uppercase()),
                            Style::default().fg(Color::Rgb(157, 0, 255)).add_modifier(Modifier::BOLD),
                        ),
                    ]));

                    let art_panel = Paragraph::new(art_lines)
                        .block(Block::default().borders(Borders::ALL)
                            .title(Span::styled(
                                format!(" {} ", av_snap.name.to_uppercase()),
                                Style::default().fg(Color::Rgb(157, 0, 255)).add_modifier(Modifier::BOLD),
                            ))
                            .border_style(Style::default().fg(Color::Rgb(157, 0, 255))));
                    f.render_widget(art_panel, av_layout[0]);

                    // Right: stats + dialogue + bond
                    let right = Layout::default()
                        .direction(Direction::Vertical)
                        .constraints([
                            Constraint::Length(3),   // bond gauge
                            Constraint::Length(12),  // stats
                            Constraint::Min(0),      // dialogue / customize
                        ].as_ref())
                        .split(av_layout[1]);

                    // Bond gauge
                    let bond_gauge = Gauge::default()
                        .block(Block::default().borders(Borders::ALL)
                            .title(Span::styled(" BOND LEVEL ", Style::default().fg(Color::Rgb(157, 0, 255))))
                            .border_style(Style::default().fg(Color::Rgb(157, 0, 255))))
                        .gauge_style(Style::default()
                            .fg(Color::Rgb(157, 0, 255))
                            .bg(Color::Rgb(20, 0, 40)))
                        .percent(av_snap.bond as u16)
                        .label(Span::styled(
                            format!("{:.1}% — {}", av_snap.bond, av_snap.bond_title),
                            Style::default().fg(Color::Rgb(0, 255, 65)).add_modifier(Modifier::BOLD),
                        ));
                    f.render_widget(bond_gauge, right[0]);

                    // Stats
                    let stats = vec![
                        Line::from(""),
                        Line::from(vec![
                            Span::styled("  ARCHETYPE:  ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(av_snap.archetype.to_uppercase(), Style::default().fg(Color::Rgb(0, 255, 65)).add_modifier(Modifier::BOLD)),
                        ]),
                        Line::from(vec![
                            Span::styled("  SKIN:       ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(av_snap.skin.to_uppercase(), Style::default().fg(Color::Rgb(0, 255, 65))),
                        ]),
                        Line::from(vec![
                            Span::styled("  EMOTION:    ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(
                                format!("{} {} ({:.0}% intensity)", emotion_icon(&av_snap.emotion), av_snap.emotion.to_uppercase(), av_snap.intensity * 100.0),
                                Style::default().fg(Color::Rgb(0, 255, 65)),
                            ),
                        ]),
                        Line::from(vec![
                            Span::styled("  LEVEL:      ", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(format!("{} | {} XP", av_snap.level, av_snap.total_xp), Style::default().fg(Color::Rgb(0, 255, 65))),
                        ]),
                        Line::from(vec![
                            Span::styled("  SESSION OPS:", Style::default().fg(Color::Rgb(157, 0, 255))),
                            Span::styled(format!(" {}", av_snap.session_ops), Style::default().fg(Color::Rgb(0, 255, 65))),
                        ]),
                        Line::from(""),
                        Line::from(Span::styled("  ARCHETYPES: Oracle | Ghost | Titan | Scholar | Renegade | Phantom", Style::default().fg(Color::Rgb(80, 80, 80)))),
                        Line::from(Span::styled("  SKINS:      cyber | ghost | titan | minimal | rogue | angel | demon", Style::default().fg(Color::Rgb(80, 80, 80)))),
                    ];

                    let stats_panel = Paragraph::new(stats)
                        .block(Block::default().borders(Borders::ALL)
                            .title(Span::styled(" ARIA STATUS ", Style::default().fg(Color::Rgb(0, 255, 65))))
                            .border_style(Style::default().fg(Color::Rgb(0, 255, 65))));
                    f.render_widget(stats_panel, right[1]);

                    // Dialogue panel
                    let dialogue_lines = vec![
                        Line::from(""),
                        Line::from(vec![
                            Span::styled("  ", Style::default()),
                            Span::styled(format!("{} ", emotion_icon(&av_snap.emotion)), Style::default().fg(Color::Rgb(157, 0, 255)).add_modifier(Modifier::BOLD)),
                            Span::styled("ARIA SAYS:", Style::default().fg(Color::Rgb(157, 0, 255))),
                        ]),
                        Line::from(""),
                        Line::from(Span::styled(
                            format!("  \"{}\"", av_snap.last_words),
                            Style::default().fg(Color::Rgb(0, 255, 65)).add_modifier(Modifier::ITALIC),
                        )),
                        Line::from(""),
                        Line::from(Span::styled("  ─────────────────────────────────────────────────────────", Style::default().fg(Color::Rgb(40, 40, 40)))),
                        Line::from(""),
                        Line::from(Span::styled("  RUN: core/janus_avatar.lua       to wake ARIA", Style::default().fg(Color::Rgb(80, 80, 80)))),
                        Line::from(Span::styled("  RUN: core/janus_dream.lua        for dream insights", Style::default().fg(Color::Rgb(80, 80, 80)))),
                        Line::from(Span::styled("  RUN: core/janus_emotion_engine.lua for emotion report", Style::default().fg(Color::Rgb(80, 80, 80)))),
                        Line::from(Span::styled("  RUN: core/janus_personality.lua  to switch archetype", Style::default().fg(Color::Rgb(80, 80, 80)))),
                        Line::from(Span::styled("  RUN: core/janus_voice.lua        to enable her voice", Style::default().fg(Color::Rgb(80, 80, 80)))),
                    ];

                    let dialogue_panel = Paragraph::new(dialogue_lines)
                        .block(Block::default().borders(Borders::ALL)
                            .title(Span::styled(" DIALOGUE ", Style::default().fg(Color::Rgb(157, 0, 255))))
                            .border_style(Style::default().fg(Color::Rgb(157, 0, 255))));
                    f.render_widget(dialogue_panel, right[2]);
                }

                // ── 4: GOD TIER ────────────────────────────────────────────────
                4 => {
                    let gt_layout = Layout::default()
                        .direction(Direction::Horizontal)
                        .constraints([Constraint::Percentage(45), Constraint::Percentage(55)].as_ref())
                        .split(root[1]);

                    // Left: core module list
                    let core_items: Vec<ListItem> = core_scripts.iter().map(|p| {
                        let name = p.file_name().unwrap_or_default().to_string_lossy().to_string();
                        ListItem::new(format!("  {}", name))
                            .style(Style::default().fg(Color::Rgb(157, 0, 255)))
                    }).collect();

                    let core_list = List::new(core_items)
                        .block(Block::default().borders(Borders::ALL)
                            .title(Span::styled(" CORE AI MODULES [ENTER] ", Style::default().fg(Color::Rgb(157, 0, 255))))
                            .border_style(Style::default().fg(Color::Rgb(157, 0, 255))))
                        .highlight_style(Style::default()
                            .bg(Color::Rgb(20, 0, 40))
                            .fg(Color::Rgb(157, 0, 255))
                            .add_modifier(Modifier::BOLD));
                    f.render_stateful_widget(core_list, gt_layout[0], &mut list_state);

                    // Right: God Tier info
                    let gt_lines = vec![
                        Line::from(""),
                        Line::from(Span::styled("  ★ GOD TIER CAPABILITIES ONLINE ★", Style::default().fg(Color::Rgb(157, 0, 255)).add_modifier(Modifier::BOLD))),
                        Line::from(""),
                        Line::from(Span::styled("  AVATAR SYSTEM", Style::default().fg(Color::Rgb(0, 255, 65)).add_modifier(Modifier::BOLD))),
                        Line::from(Span::styled("  ✦ janus_avatar.lua     — ARIA personality & ASCII art", Style::default().fg(Color::Rgb(0, 200, 0)))),
                        Line::from(Span::styled("  ✦ janus_personality.lua — 6 archetypes, bond dialogue", Style::default().fg(Color::Rgb(0, 200, 0)))),
                        Line::from(""),
                        Line::from(Span::styled("  EMOTIONAL INTELLIGENCE", Style::default().fg(Color::Rgb(0, 255, 65)).add_modifier(Modifier::BOLD))),
                        Line::from(Span::styled("  ✦ janus_emotion_engine.lua — 14 emotions, PAD model", Style::default().fg(Color::Rgb(0, 200, 0)))),
                        Line::from(""),
                        Line::from(Span::styled("  MEMORY & LEARNING", Style::default().fg(Color::Rgb(0, 255, 65)).add_modifier(Modifier::BOLD))),
                        Line::from(Span::styled("  ✦ janus_memory.lua — Episodic/Semantic/Procedural", Style::default().fg(Color::Rgb(0, 200, 0)))),
                        Line::from(Span::styled("  ✦ Preference learning, predictions, streak tracking", Style::default().fg(Color::Rgb(0, 200, 0)))),
                        Line::from(""),
                        Line::from(Span::styled("  MISSIONS & PROGRESSION", Style::default().fg(Color::Rgb(0, 255, 65)).add_modifier(Modifier::BOLD))),
                        Line::from(Span::styled("  ✦ janus_god_tier.lua — XP, levels, skill tree (16 skills)", Style::default().fg(Color::Rgb(0, 200, 0)))),
                        Line::from(Span::styled("  ✦ Achievements (35+), auto-mission planner, prophecy", Style::default().fg(Color::Rgb(0, 200, 0)))),
                        Line::from(""),
                        Line::from(Span::styled("  DREAM & VOICE", Style::default().fg(Color::Rgb(0, 255, 65)).add_modifier(Modifier::BOLD))),
                        Line::from(Span::styled("  ✦ janus_dream.lua  — Dream cycles, visions, insights", Style::default().fg(Color::Rgb(0, 200, 0)))),
                        Line::from(Span::styled("  ✦ janus_voice.lua  — TTS, 6 voice profiles, whisper", Style::default().fg(Color::Rgb(0, 200, 0)))),
                        Line::from(""),
                        Line::from(Span::styled("  SELF-HEALING: god.self_heal() checks all subsystems", Style::default().fg(Color::Rgb(80, 80, 80)))),
                        Line::from(Span::styled("  PROPHECY:     god.prophecy() for ARIA foresight", Style::default().fg(Color::Rgb(80, 80, 80)))),
                    ];

                    let gt_panel = Paragraph::new(gt_lines)
                        .block(Block::default().borders(Borders::ALL)
                            .title(Span::styled(" GOD TIER SYSTEMS ", Style::default().fg(Color::Rgb(157, 0, 255)).add_modifier(Modifier::BOLD)))
                            .border_style(Style::default().fg(Color::Rgb(157, 0, 255))));
                    f.render_widget(gt_panel, gt_layout[1]);
                }

                _ => {}
            }

            // ── Logs ──────────────────────────────────────────────────────────
            let log_lock = logs.lock().unwrap();
            let log_lines: Vec<Line> = log_lock
                .iter()
                .rev()
                .take(7)
                .rev()
                .map(|s| {
                    let color = if s.contains("ERROR") || s.contains("ERR") {
                        Color::Red
                    } else if s.contains("ARIA") || s.contains("AVATAR") || s.contains("EMOTION") {
                        Color::Rgb(157, 0, 255)
                    } else if s.contains("★") || s.contains("ACHIEVEMENT") || s.contains("LEVEL UP") {
                        Color::Yellow
                    } else {
                        Color::Rgb(0, 255, 65)
                    };
                    Line::from(Span::styled(s.clone(), Style::default().fg(color)))
                })
                .collect();

            let logger = Paragraph::new(log_lines)
                .block(Block::default().borders(Borders::ALL)
                    .title(Span::styled(" ARIA LOGS ", Style::default().fg(Color::Rgb(0, 255, 65))))
                    .border_style(Style::default().fg(Color::Rgb(0, 255, 65))));
            f.render_widget(logger, root[2]);
        })?;

        // ── Input handling ─────────────────────────────────────────────────────
        if event::poll(Duration::from_millis(100))? {
            if let Event::Key(key) = event::read()? {
                match key.code {
                    KeyCode::Char('q') => break,
                    KeyCode::Right | KeyCode::Tab => current_tab = (current_tab + 1) % tab_names.len(),
                    KeyCode::Left  => current_tab = if current_tab == 0 { tab_names.len() - 1 } else { current_tab - 1 },
                    KeyCode::Char('g') => trigger_hardware_glitch(logs.clone()),
                    KeyCode::Down => {
                        let max = if current_tab == 4 { core_scripts.len() } else { scripts.len() };
                        let i = list_state.selected().unwrap_or(0);
                        if i + 1 < max { list_state.select(Some(i + 1)); }
                    },
                    KeyCode::Up => {
                        let i = list_state.selected().unwrap_or(0);
                        if i > 0 { list_state.select(Some(i - 1)); }
                    },
                    KeyCode::Enter => {
                        let (_active_scripts, prefix) = if current_tab == 4 {
                            (&core_scripts, "CORE")
                        } else if current_tab == 1 || current_tab == 2 || current_tab == 3 {
                            (&scripts, "PLUGIN")
                        } else {
                            continue;
                        };

                        // For avatar tab, run core scripts directly
                        let script_list = if current_tab == 3 || current_tab == 4 {
                            &core_scripts
                        } else {
                            &scripts
                        };

                        if let Some(i) = list_state.selected() {
                            if let Some(path) = script_list.get(i) {
                                let name = path.file_name().unwrap_or_default().to_string_lossy().to_string();
                                logs.lock().unwrap().push(format!(">>> [{}] EXEC: {}", prefix, name));
                                if let Ok(code) = fs::read_to_string(path) {
                                    let l_ref = logs.clone();
                                    let db_ref = db.clone();
                                    let av_ref = avatar.clone();
                                    std::thread::spawn(move || run_script(code, l_ref, db_ref, av_ref));
                                }
                            }
                        }
                    },
                    _ => {}
                }
            }
        }
    }

    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    Ok(())
}
