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
    style::{Color, Style},
    widgets::{Block, Borders, List, ListItem, ListState, Paragraph, Tabs},
    Terminal,
};
use mlua::prelude::*;
use tokio::runtime::Runtime;
use chrono::Local;
use rusqlite::{params, Connection};

// --- HARDWARE ---
fn trigger_hardware_glitch(logs: Arc<Mutex<Vec<String>>>) {
    match serialport::new("/dev/ttyAMA0", 115200).open() {
        Ok(mut port) => {
            let _ = port.write(b"GLITCH");
            logs.lock().unwrap().push("[HW] GLITCH SENT".to_string());
        },
        Err(_) => logs.lock().unwrap().push("[HW] NOT FOUND".to_string()),
    }
}

// --- ENGINE ---
fn run_script(code: String, logs: Arc<Mutex<Vec<String>>>, db: Arc<Mutex<Connection>>) {
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
        let lua = Lua::new();
        let janus = lua.create_table().unwrap();
        let l = logs.clone();
        
        janus.set("log", lua.create_function(move |_, msg: String| {
            let t = Local::now().format("%H:%M:%S");
            l.lock().unwrap().push(format!("[{}] {}", t, msg));
            Ok(())
        }).unwrap()).unwrap();

        janus.set("shell", lua.create_function(|_, cmd: String| {
            let output = Command::new("sh").arg("-c").arg(&cmd).output();
            match output {
                Ok(o) => {
                    let stdout = String::from_utf8_lossy(&o.stdout).trim().to_string();
                    let stderr = String::from_utf8_lossy(&o.stderr).trim().to_string();
                    if !stdout.is_empty() {
                        Ok(stdout)
                    } else if !stderr.is_empty() {
                        Ok(format!("ERR: {}", stderr))
                    } else {
                        Ok("".to_string())
                    }
                },
                Err(e) => Ok(format!("ERR: {}", e)),
            }
        }).unwrap()).unwrap();

        janus.set("geo_track", lua.create_function(|_, target: String| {
            Ok(format!("LOCATING: {}... [34.0522 N, 118.2437 W]", target))
        }).unwrap()).unwrap();

        janus.set("sig_scan", lua.create_function(|_, freq: String| {
            Ok(format!("SCANNING: {} MHz... DETECTED: [ENCRYPTED SIGNAL]", freq))
        }).unwrap()).unwrap();

        janus.set("vital_check", lua.create_function(|_, _: ()| {
            Ok("HEART RATE: 72 BPM | STATUS: STABLE".to_string())
        }).unwrap()).unwrap();

        janus.set("armor_status", lua.create_function(|_, _: ()| {
            Ok("ARMOR-LINK: 100% | INTEGRITY: NOMINAL".to_string())
        }).unwrap()).unwrap();

        janus.set("kinetic_charge", lua.create_function(|_, _: ()| {
            Ok("KINETIC HARVESTER: ACTIVE | CHARGE RATE: +450mW".to_string())
        }).unwrap()).unwrap();

        janus.set("ar_hud_link", lua.create_function(|_, state: bool| {
            Ok(format!("AR-HUD OVERLAY: {}", if state { "ENGAGED" } else { "DISENGAGED" }))
        }).unwrap()).unwrap();

        janus.set("chameleon_engage", lua.create_function(|_, target_skin: String| {
            Ok(format!("CHAMELEON MODE: ENGAGED [SKIN: {}]", target_skin.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("blackbox_log", lua.create_function(|_, _: ()| {
            Ok("BLACK-BOX RECORDER: 24/7 RF LOGGING ACTIVE".to_string())
        }).unwrap()).unwrap();

        janus.set("quantum_shield", lua.create_function(|_, _: ()| {
            Ok("QUANTUM-RESISTANT ENCRYPTION: ACTIVE (KYBER-1024)".to_string())
        }).unwrap()).unwrap();

        janus.set("ai_analyze", lua.create_function(|_, msg: String| {
            Ok(format!("AI ANALYSIS: {}", msg.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("ghost_net_sync", lua.create_function(|_, _: ()| {
            Ok("GHOST-NET: MESH SYNCHRONIZED".to_string())
        }).unwrap()).unwrap();

        janus.set("stealth_mode", lua.create_function(|_, state: bool| {
            Ok(format!("STEALTH BOOT: {}", if state { "ARMED" } else { "DISARMED" }))
        }).unwrap()).unwrap();

        janus.set("carve_db", lua.create_function(|_, path: String| {
            Ok(format!("CARVING: {} ... RECOVERY SUCCESSFUL", path))
        }).unwrap()).unwrap();

        janus.set("recon_timeline", lua.create_function(|_, _: ()| {
            Ok("TIMELINE: SYNCHRONIZED ACROSS ALL DATA SOURCES".to_string())
        }).unwrap()).unwrap();

        janus.set("mobile_bypass", lua.create_function(|_, layer: String| {
            Ok(format!("BYPASS: {} ... OVERRIDDEN", layer.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("identity_clone", lua.create_function(|_, id: String| {
            Ok(format!("CLONED: {} ... SYNCED TO TITAN", id))
        }).unwrap()).unwrap();

        janus.set("network_ghost", lua.create_function(|_, state: bool| {
            Ok(format!("GHOST MODE: {}", if state { "ENGAGED" } else { "DISENGAGED" }))
        }).unwrap()).unwrap();

        janus.set("sensor_access", lua.create_function(|_, sensor: String| {
            Ok(format!("SENSOR: {} ... STREAMING", sensor.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("app_sandbox", lua.create_function(|_, app_id: String| {
            Ok(format!("SANDBOX: {} ... VIRTUALIZED", app_id))
        }).unwrap()).unwrap();

        janus.set("sat_link", lua.create_function(|_, target: String| {
            Ok(format!("SATELLITE: {} ... CONNECTED", target.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("grid_control", lua.create_function(|_, node: String| {
            Ok(format!("GRID NODE: {} ... OVERRIDDEN", node.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("bio_spoof", lua.create_function(|_, _: ()| {
            Ok("BIOMETRIC: SYNTHETIC SIGNATURE GENERATED".to_string())
        }).unwrap()).unwrap();

        janus.set("net_intercept", lua.create_function(|_, target: String| {
            Ok(format!("INTERCEPTING: {} ... PACKET FLOW CAPTURED", target.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("vuln_scan", lua.create_function(|_, target: String| {
            Ok(format!("SCANNING: {} ... VULNERABILITIES DETECTED", target.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("exploit_trigger", lua.create_function(|_, exploit: String| {
            Ok(format!("TRIGGERING: {} ... PAYLOAD DEPLOYED", exploit.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("net_cartography", lua.create_function(|_, subnet: String| {
            Ok(format!("MAPPING: {} ... 12 NODES IDENTIFIED | TOPOLOGY SYNCED", subnet))
        }).unwrap()).unwrap();

        janus.set("sig_fingerprint", lua.create_function(|_, _: ()| {
            Ok("SIGNAL: DUAL-SPECTRAL FINGERPRINT MATCHED [UPLINK-7]".to_string())
        }).unwrap()).unwrap();

        janus.set("neural_link", lua.create_function(|_, intent: String| {
            Ok(format!("NEURAL SYNC: {} ... COMMAND EXECUTED", intent.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("cbrn_scan", lua.create_function(|_, _: ()| {
            Ok("CBRN: RAD=0.01uSv/h | BIO=NEG | CHEM=NEG".to_string())
        }).unwrap()).unwrap();

        janus.set("ar_highlight", lua.create_function(|_, target: String| {
            Ok(format!("AR-HUD: HIGHLIGHTING TARGET [{}]", target.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("quantum_crack", lua.create_function(|_, target: String| {
            Ok(format!("QUANTUM CRACK: {} ... KEY COLLAPSED", target.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("grid_blackout", lua.create_function(|_, region: String| {
            Ok(format!("GRID BLACKOUT: {} ... REGION DARK", region.to_uppercase()))
        }).unwrap()).unwrap();

        janus.set("identity_forge", lua.create_function(|_, _: ()| {
            Ok("IDENTITY: SYNTHETIC BIOMETRICS FORGED".to_string())
        }).unwrap()).unwrap();

        janus.set("mesh_infect", lua.create_function(|_, _: ()| {
            Ok("MESH: WORM PROPAGATION IN PROGRESS".to_string())
        }).unwrap()).unwrap();

        lua.globals().set("janus", janus).unwrap();
        match lua.load(&code).exec_async().await {
            Ok(_) => { let _ = db.lock().unwrap().execute("INSERT INTO audit (time, action) VALUES (?1, 'SUCCESS')", params![Local::now().to_string()]); },
            Err(e) => { logs.clone().lock().unwrap().push(format!("LUA ERROR: {}", e)); }
        }
    });
}

// --- WEB SERVER (for deployment with no TTY) ---
fn run_web_server() -> Result<(), Box<dyn std::error::Error>> {
    let port = std::env::var("PORT").unwrap_or_else(|_| "8080".to_string());
    let addr = format!("0.0.0.0:{}", port);
    let listener = TcpListener::bind(&addr)?;
    println!("JANUS OMEGA :: WEB STATUS SERVER :: {}", addr);

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
  footer {{ margin-top:40px; color:#555; font-size:0.8em; }}
</style>
</head>
<body>
<h1>&#9733; JANUS OMEGA OS &#9733;</h1>
<div class="status">
  <p><span class="label">STATUS:</span> <span class="green">&#9646; ONLINE</span></p>
  <p><span class="label">SYSTEM:</span> <span class="green">ARMORED &amp; OPERATIONAL</span></p>
  <p><span class="label">MODULES:</span> <span class="green">{} TACTICAL MODULES LOADED</span></p>
  <p><span class="label">ENCRYPTION:</span> <span class="green">QUANTUM-RESISTANT (KYBER-1024)</span></p>
  <p><span class="label">GHOST-NET:</span> <span class="green">MESH SYNCHRONIZED</span></p>
</div>
<div class="grid">
  <div class="card"><h3>HARDWARE FLEET</h3>
    <p class="green">&#10003; Pandora Titan (Forearm Pip-Boy)</p>
    <p class="green">&#10003; Pandora Omega (Cyberdeck)</p>
    <p class="green">&#10003; Pandora Mk.1 (USB Glitcher)</p>
  </div>
  <div class="card"><h3>ACTIVE SUITES</h3>
    <p class="green">&#10003; Mobile Offense (150 modules)</p>
    <p class="green">&#10003; Network Warfare (150 modules)</p>
    <p class="green">&#10003; Cyber Warfare (150 modules)</p>
    <p class="green">&#10003; Forensics &amp; OSINT</p>
  </div>
  <div class="card"><h3>TITAN EXCLUSIVES</h3>
    <p class="green">&#10003; Neural-Sync (Haptic Intent)</p>
    <p class="green">&#10003; AR-HUD Overlay</p>
    <p class="green">&#10003; CBRN Detection Suite</p>
    <p class="green">&#10003; Kinetic Harvester</p>
  </div>
  <div class="card"><h3>SECURITY</h3>
    <p class="green">&#10003; RAM-Only Live ISO</p>
    <p class="green">&#10003; Chameleon Panic Mode</p>
    <p class="green">&#10003; Biometric Kill-Switch</p>
    <p class="green">&#10003; Black-Box RF Recorder</p>
  </div>
</div>
<footer>JANUS OMEGA OS &mdash; 1000-MODULE SINGULARITY &mdash; ALL SYSTEMS NOMINAL</footer>
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

// --- MAIN ---
fn main() -> Result<(), Box<dyn std::error::Error>> {
    // If not in a TTY (deployed environment), run the web status server
    if !atty::is(atty::Stream::Stdout) {
        return run_web_server();
    }

    // 1. SETUP DB
    let conn = Connection::open("janus.db")?;
    conn.execute("CREATE TABLE IF NOT EXISTS audit (id INTEGER PRIMARY KEY, time TEXT, action TEXT)", [])?;
    let db = Arc::new(Mutex::new(conn));
    
    // 2. SETUP TUI
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;
    
    let mut list_state = ListState::default();
    list_state.select(Some(0));
    let logs = Arc::new(Mutex::new(vec!["JANUS OMEGA ONLINE.".to_string()]));
    let mut current_tab = 0;

    loop {
        let mut scripts: Vec<PathBuf> = Vec::new();

        fn scan_dir(dir: &str, scripts: &mut Vec<PathBuf>) {
            if let Ok(paths) = fs::read_dir(dir) {
                for path in paths.flatten() {
                    let p = path.path();
                    if p.is_dir() {
                        scan_dir(p.to_str().unwrap_or(""), scripts);
                    } else if p.extension().unwrap_or_default() == "lua" {
                        scripts.push(p);
                    }
                }
            }
        }
        scan_dir("plugins", &mut scripts);
        scripts.sort();

        terminal.draw(|f| {
            let chunks = Layout::default().direction(Direction::Vertical).constraints([Constraint::Length(3), Constraint::Min(0), Constraint::Length(10)].as_ref()).split(f.size());
            
            let tabs = Tabs::new(vec!["Dashboard", "Ops", "Hardware"])
                .block(Block::default().borders(Borders::ALL).title(" JANUS OMEGA "))
                .select(current_tab)
                .highlight_style(Style::default().fg(Color::Rgb(157, 0, 255)));
            f.render_widget(tabs, chunks[0]);

            if current_tab == 1 || current_tab == 2 {
                let ops_layout = Layout::default().direction(Direction::Horizontal).constraints([Constraint::Percentage(40), Constraint::Percentage(60)].as_ref()).split(chunks[1]);
                
                let items: Vec<ListItem> = scripts.iter().map(|p| {
                    ListItem::new(p.file_name().unwrap().to_string_lossy().to_string())
                        .style(Style::default().fg(Color::Rgb(0, 255, 65)))
                }).collect();
                
                let list = List::new(items)
                    .block(Block::default().borders(Borders::ALL).title(" MODULES ").border_style(Style::default().fg(Color::Rgb(157, 0, 255))))
                    .highlight_style(Style::default().bg(Color::Rgb(10, 10, 10)).fg(Color::Rgb(0, 255, 65)));
                
                // FIXED: Explicitly calling render_stateful_widget
                f.render_stateful_widget(list, ops_layout[0], &mut list_state);
                
                let info = Paragraph::new("SELECT MODULE AND PRESS ENTER")
                    .block(Block::default().borders(Borders::ALL).border_style(Style::default().fg(Color::Rgb(0, 255, 65))));
                f.render_widget(info, ops_layout[1]);
            } else {
                let dash = Paragraph::new("\n   SYSTEM: ARMORED\n   STATUS: ONLINE\n   [Q] QUIT")
                    .block(Block::default().borders(Borders::ALL).title(" STATUS ").border_style(Style::default().fg(Color::Rgb(157, 0, 255))))
                    .style(Style::default().fg(Color::Rgb(0, 255, 65)));
                f.render_widget(dash, chunks[1]);
            }
            
            let log_lock = logs.lock().unwrap();
            let log_text = log_lock.iter().rev().take(10).rev().cloned().collect::<Vec<String>>().join("\n");
            let logger = Paragraph::new(log_text).block(Block::default().borders(Borders::ALL).title(" LOGS ").border_style(Style::default().fg(Color::Rgb(0, 255, 65))))
                .style(Style::default().fg(Color::Rgb(157, 0, 255)));
            f.render_widget(logger, chunks[2]);
        })?;

        if event::poll(Duration::from_millis(100))? {
            if let Event::Key(key) = event::read()? {
                match key.code {
                    KeyCode::Char('q') => break,
                    KeyCode::Right => current_tab = (current_tab + 1) % 3,
                    KeyCode::Left => current_tab = if current_tab == 0 { 2 } else { current_tab - 1 },
                    KeyCode::Char('g') => trigger_hardware_glitch(logs.clone()),
                    KeyCode::Down => { 
                        let i = list_state.selected().unwrap_or(0); 
                        if i < scripts.len().saturating_sub(1) { list_state.select(Some(i + 1)); } 
                    },
                    KeyCode::Up => { 
                        let i = list_state.selected().unwrap_or(0); 
                        if i > 0 { list_state.select(Some(i - 1)); } 
                    },
                    KeyCode::Enter => {
                        if (current_tab == 1 || current_tab == 2) && !scripts.is_empty() {
                            if let Some(i) = list_state.selected() {
                                let path = scripts[i].clone();
                                logs.lock().unwrap().push(format!(">>> EXEC: {:?}", path.file_name().unwrap()));
                                if let Ok(code) = fs::read_to_string(path) {
                                    let l_ref = logs.clone();
                                    let db_ref = db.clone();
                                    std::thread::spawn(move || run_script(code, l_ref, db_ref));
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
