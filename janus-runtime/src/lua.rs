//! Lua integration and module management.

use anyhow::Result;
use janus_core::Config;
use mlua::prelude::*;
use std::path::Path;
use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::{debug, error, warn};

/// Lua runtime environment.
pub struct LuaEnv {
    lua: Lua,
}

impl LuaEnv {
    /// Create new Lua environment
    pub fn new() -> Result<Self> {
        let lua = Lua::new();
        debug!("Lua 5.4 environment initialized");
        Ok(Self { lua })
    }

    /// Load core modules from filesystem
    pub async fn load_core_modules(&self, core_dir: &Path) -> Result<()> {
        if !core_dir.exists() {
            warn!("Core modules directory not found: {}", core_dir.display());
            return Ok(());
        }

        let entries = std::fs::read_dir(core_dir)?;
        let mut loaded = 0;
        let mut failed = 0;

        for entry in entries {
            let entry = entry?;
            let path = entry.path();

            if path.extension().and_then(|s| s.to_str()) == Some("lua") {
                match self.load_module_file(&path).await {
                    Ok(_) => loaded += 1,
                    Err(e) => {
                        error!("Failed to load module {:?}: {}", path.file_name(), e);
                        failed += 1;
                    }
                }
            }
        }

        debug!(
            "Core modules loaded: {}, failed: {}",
            loaded, failed
        );
        Ok(())
    }

    /// Load single Lua module file
    async fn load_module_file(&self, path: &Path) -> Result<()> {
        let content = tokio::fs::read_to_string(path).await?;
        let module_name = path
            .file_stem()
            .and_then(|n| n.to_str())
            .ok_or_else(|| anyhow::anyhow!("Invalid module name"))?;

        self.lua
            .load(&content)
            .set_name(module_name)?
            .eval::<()>()?;

        debug!("Loaded module: {}", module_name);
        Ok(())
    }

    /// Execute Lua code
    pub fn execute(&self, code: &str) -> Result<LuaValue> {
        let result = self.lua.load(code).eval::<LuaValue>()?;
        Ok(result)
    }

    /// Call Lua function with arguments
    pub fn call_function(
        &self,
        func_name: &str,
        args: Vec<LuaValue>,
    ) -> Result<LuaValue> {
        let globals = self.lua.globals();
        let func: LuaFunction = globals.get(func_name)?;
        let result = func.call::<_, LuaValue>(mlua::MultiValue::from_vec(args))?;
        Ok(result)
    }

    /// Get global variable
    pub fn get_global(&self, name: &str) -> Result<LuaValue> {
        let globals = self.lua.globals();
        Ok(globals.get(name)?)
    }

    /// Set global variable
    pub fn set_global(&self, name: &str, value: LuaValue) -> Result<()> {
        let globals = self.lua.globals();
        globals.set(name, value)?;
        Ok(())
    }

    /// Create table from JSON value
    pub fn json_to_table(&self, value: &serde_json::Value) -> Result<LuaTable> {
        let table = self.lua.create_table()?;

        match value {
            serde_json::Value::Object(map) => {
                for (k, v) in map {
                    table.set(k.clone(), self.json_to_lua_value(v)?)?;
                }
            }
            _ => return Err(anyhow::anyhow!("Expected JSON object")),
        }

        Ok(table)
    }

    /// Convert JSON value to Lua value
    fn json_to_lua_value(&self, value: &serde_json::Value) -> Result<LuaValue> {
        Ok(match value {
            serde_json::Value::Null => LuaValue::Nil,
            serde_json::Value::Bool(b) => self.lua.pack(*b)?,
            serde_json::Value::Number(n) => {
                if let Some(i) = n.as_i64() {
                    self.lua.pack(i)?
                } else if let Some(f) = n.as_f64() {
                    self.lua.pack(f)?
                } else {
                    return Err(anyhow::anyhow!("Invalid JSON number"));
                }
            }
            serde_json::Value::String(s) => self.lua.pack(s.clone())?,
            serde_json::Value::Array(arr) => {
                let table = self.lua.create_table()?;
                for (i, v) in arr.iter().enumerate() {
                    table.set(i + 1, self.json_to_lua_value(v)?)?;
                }
                table.to_lua(self.lua.clone())?
            }
            serde_json::Value::Object(_) => {
                self.json_to_table(value)?.to_lua(self.lua.clone())?
            }
        })
    }

    /// Convert Lua value to JSON
    pub fn lua_to_json(&self, value: &LuaValue) -> Result<serde_json::Value> {
        Ok(match value {
            LuaValue::Nil => serde_json::Value::Null,
            LuaValue::Boolean(b) => serde_json::Value::Bool(*b),
            LuaValue::Integer(i) => serde_json::json!(*i),
            LuaValue::Number(n) => serde_json::json!(*n),
            LuaValue::String(s) => serde_json::Value::String(
                s.to_str()?
                    .ok_or_else(|| anyhow::anyhow!("Invalid string"))?
                    .to_string(),
            ),
            LuaValue::Table(table) => {
                let mut map = serde_json::Map::new();
                for pair in table.pairs::<String, LuaValue>() {
                    let (k, v) = pair?;
                    map.insert(k, self.lua_to_json(&v)?);
                }
                serde_json::Value::Object(map)
            }
            _ => serde_json::Value::Null,
        })
    }
}

/// Sandbox for plugin execution
pub struct PluginSandbox {
    lua: Arc<RwLock<Lua>>,
}

impl PluginSandbox {
    /// Create new plugin sandbox
    pub fn new() -> Result<Self> {
        let lua = Lua::new();
        Ok(Self {
            lua: Arc::new(RwLock::new(lua)),
        })
    }

    /// Execute plugin code with arguments
    pub async fn execute(
        &self,
        code: &str,
        args: serde_json::Value,
    ) -> Result<serde_json::Value> {
        let lua = self.lua.read().await;

        // Convert args to Lua
        let args_table = match args {
            serde_json::Value::Object(map) => {
                let table = lua.create_table()?;
                for (k, v) in map {
                    table.set(
                        k,
                        json_to_lua_value_inner(&lua, &v)?,
                    )?;
                }
                table
            }
            _ => lua.create_table()?,
        };

        // Execute plugin code
        let result = lua
            .load(code)
            .eval::<LuaValue>()?;

        // Convert result back to JSON
        lua_to_json_inner(&lua, &result)
    }
}

fn json_to_lua_value_inner(lua: &Lua, value: &serde_json::Value) -> Result<LuaValue> {
    Ok(match value {
        serde_json::Value::Null => LuaValue::Nil,
        serde_json::Value::Bool(b) => lua.pack(*b)?,
        serde_json::Value::Number(n) => {
            if let Some(i) = n.as_i64() {
                lua.pack(i)?
            } else if let Some(f) = n.as_f64() {
                lua.pack(f)?
            } else {
                return Err(anyhow::anyhow!("Invalid number"));
            }
        }
        serde_json::Value::String(s) => lua.pack(s.clone())?,
        serde_json::Value::Array(arr) => {
            let table = lua.create_table()?;
            for (i, v) in arr.iter().enumerate() {
                table.set(i + 1, json_to_lua_value_inner(lua, v)?)?;
            }
            table.to_lua(lua.clone())?
        }
        serde_json::Value::Object(map) => {
            let table = lua.create_table()?;
            for (k, v) in map {
                table.set(k.clone(), json_to_lua_value_inner(lua, v)?)?;
            }
            table.to_lua(lua.clone())?
        }
    })
}

fn lua_to_json_inner(lua: &Lua, value: &LuaValue) -> Result<serde_json::Value> {
    Ok(match value {
        LuaValue::Nil => serde_json::Value::Null,
        LuaValue::Boolean(b) => serde_json::Value::Bool(*b),
        LuaValue::Integer(i) => serde_json::json!(*i),
        LuaValue::Number(n) => serde_json::json!(*n),
        LuaValue::String(s) => serde_json::Value::String(
            s.to_str()?
                .ok_or_else(|| anyhow::anyhow!("Invalid string"))?
                .to_string(),
        ),
        LuaValue::Table(table) => {
            let mut map = serde_json::Map::new();
            for pair in table.pairs::<String, LuaValue>() {
                let (k, v) = pair?;
                map.insert(k, lua_to_json_inner(lua, &v)?);
            }
            serde_json::Value::Object(map)
        }
        _ => serde_json::Value::Null,
    })
}
