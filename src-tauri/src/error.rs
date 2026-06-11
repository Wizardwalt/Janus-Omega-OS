// src-tauri/src/error.rs
// Error handling for Janus Omega OS

use std::fmt;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error("State Manager Error: {0}")]
    StateManager(String),
    
    #[error("Plugin Sandbox Error: {0}")]
    PluginSandbox(String),
    
    #[error("Ollama Bridge Error: {0}")]
    OllamaBridge(String),
    
    #[error("Cryptography Error: {0}")]
    Crypto(String),
    
    #[error("Hardware Error: {0}")]
    Hardware(String),
    
    #[error("Threat Detection Error: {0}")]
    ThreatDetection(String),
    
    #[error("IO Error: {0}")]
    Io(#[from] std::io::Error),
    
    #[error("JSON Error: {0}")]
    Json(#[from] serde_json::Error),
    
    #[error("Database Error: {0}")]
    Database(String),
    
    #[error("Network Error: {0}")]
    Network(String),
    
    #[error("Configuration Error: {0}")]
    Config(String),
}

pub type Result<T> = std::result::Result<T, Error>;

impl From<rusqlite::Error> for Error {
    fn from(err: rusqlite::Error) -> Self {
        Error::Database(err.to_string())
    }
}

impl From<mlua::Error> for Error {
    fn from(err: mlua::Error) -> Self {
        Error::PluginSandbox(err.to_string())
    }
}
