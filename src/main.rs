use std::fs;
use std::path::PathBuf;
use std::process::Command;
use std::sync::{Arc, Mutex};
use std::io::{self, Write};
use std::time::Duration;

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
                Ok(o) => Ok(String::from_utf8_lossy(&o.stdout).trim().to_string()),
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

        lua.globals().set("janus", janus).unwrap();
        match lua.load(&code).exec_async().await {
            Ok(_) => { let _ = db.lock().unwrap().execute("INSERT INTO audit (time, action) VALUES (?1, 'SUCCESS')", params![Local::now().to_string()]); },
            Err(e) => { logs.clone().lock().unwrap().push(format!("LUA ERROR: {}", e)); }
        }
    });
}

// --- MAIN ---
fn main() -> Result<(), Box<dyn std::error::Error>> {
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
        // FIXED: Explicit type annotation for scripts to prevent E0282
        let mut scripts: Vec<PathBuf> = Vec::new();
        
        if let Ok(paths) = fs::read_dir("plugins") {
            for path in paths {
                if let Ok(entry) = path {
                    let p = entry.path();
                    if p.extension().unwrap_or_default() == "lua" { 
                        scripts.push(p); 
                    }
                }
            }
        }
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
