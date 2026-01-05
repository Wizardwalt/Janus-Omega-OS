use std::fs;
use std::process::Command;
use std::io;
use std::time::Duration;
use std::sync::{Arc, Mutex};

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

        lua.globals().set("janus", janus).unwrap();

        match lua.load(&code).exec_async().await {
            Ok(_) => { let _ = db.lock().unwrap().execute("INSERT INTO audit (time, action) VALUES (?1, 'SUCCESS')", params![Local::now().to_string()]); },
            Err(e) => { logs.clone().lock().unwrap().push(format!("LUA ERROR: {}", e)); }
        }
    });
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let conn = Connection::open("janus.db")?;
    conn.execute("CREATE TABLE IF NOT EXISTS audit (id INTEGER PRIMARY KEY, time TEXT, action TEXT)", [])?;
    let db = Arc::new(Mutex::new(conn));

    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let terminal = Terminal::new(backend)?;

    let mut list_state = ListState::default();
    list_state.select(Some(0));
    let logs = Arc::new(Mutex::new(vec!["JANUS OMEGA OS ONLINE.".to_string()]));
    let mut current_tab = 0;

    let terminal_ref = Arc::new(Mutex::new(terminal));
    let terminal_loop = terminal_ref.clone();

    loop {
        let mut scripts = Vec::new();
        let plugin_path = "/opt/janus/plugins"; // Linux Path
        if let Ok(paths) = fs::read_dir(plugin_path) {
            for path in paths {
                let p = path?.path();
                if p.extension().unwrap_or_default() == "lua" { scripts.push(p); }
            }
        } else {
            // Fallback for dev environment
             if let Ok(paths) = fs::read_dir("plugins") {
                for path in paths {
                    let p = path?.path();
                    if p.extension().unwrap_or_default() == "lua" { scripts.push(p); }
                }
            }
        }
        scripts.sort();

        terminal_loop.lock().unwrap().draw(|f| {
            let chunks = Layout::default().direction(Direction::Vertical).constraints([Constraint::Length(3), Constraint::Min(0), Constraint::Length(10)].as_ref()).split(f.size());
            let tabs = Tabs::new(vec!["Dashboard", "Ops", "Intel"]).block(Block::default().borders(Borders::ALL).title(" JANUS OMEGA ")).select(current_tab).highlight_style(Style::default().fg(Color::Cyan));
            f.render_widget(tabs, chunks[0]);

            if current_tab == 1 { 
                let items: Vec<ListItem> = scripts.iter().map(|p| ListItem::new(p.file_name().unwrap().to_string_lossy()).style(Style::default().fg(Color::Green))).collect();
                let list = List::new(items).block(Block::default().borders(Borders::ALL).title(" PLUGINS ")).highlight_style(Style::default().bg(Color::DarkGray));
                f.render_stateful_widget(list, chunks[1], &mut list_state);
            } else {
                let dash = Paragraph::new("\n   SYSTEM: SECURE\n   MODE: KIOSK\n\n   [<- ->] Nav   [Enter] Exec   [Q] Quit").block(Block::default().borders(Borders::ALL).title(" STATUS "));
                f.render_widget(dash, chunks[1]);
            }

            let log_lock = logs.lock().unwrap();
            let log_text = log_lock.iter().rev().take(10).rev().cloned().collect::<Vec<String>>().join("\n");
            let logger = Paragraph::new(log_text).block(Block::default().borders(Borders::ALL).title(" LOGS "));
            f.render_widget(logger, chunks[2]);
        })?;

        if event::poll(Duration::from_millis(100))? {
            if let Event::Key(key) = event::read()? {
                match key.code {
                    KeyCode::Char('q') => break,
                    KeyCode::Right => current_tab = (current_tab + 1) % 3,
                    KeyCode::Left => current_tab = if current_tab == 0 { 2 } else { current_tab - 1 },
                    KeyCode::Down => { let i = list_state.selected().unwrap_or(0); if i < scripts.len().saturating_sub(1) { list_state.select(Some(i + 1)); } },
                    KeyCode::Up => { let i = list_state.selected().unwrap_or(0); if i > 0 { list_state.select(Some(i - 1)); } },
                    KeyCode::Enter => {
                        if current_tab == 1 && !scripts.is_empty() {
                            if let Some(i) = list_state.selected() {
                                let path = scripts[i].clone();
                                logs.lock().unwrap().push(format!(">>> EXEC: {:?}", path.file_name().unwrap()));
                                let code = fs::read_to_string(path)?;
                                let l_ref = logs.clone();
                                let db_ref = db.clone();
                                std::thread::spawn(move || run_script(code, l_ref, db_ref));
                            }
                        }
                    },
                    _ => {}
                }
            }
        }
    }
    execute!(terminal_ref.lock().unwrap().backend_mut(), LeaveAlternateScreen)?;
    disable_raw_mode()?;
    Ok(())
}