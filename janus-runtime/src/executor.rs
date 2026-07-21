//! Plugin execution environment.

use crate::plugin::PluginLoader;
use anyhow::Result;
use janus_core::Config;
use std::path::PathBuf;
use tracing::debug;

/// Plugin executor managing Lua runtime and plugin lifecycle.
pub struct PluginExecutor {
    config: Config,
    loader: PluginLoader,
}

impl PluginExecutor {
    /// Create new plugin executor
    pub async fn new(config: &Config, loader: PluginLoader) -> Result<Self> {
        debug!("Initializing plugin executor");
        Ok(Self {
            config: config.clone(),
            loader,
        })
    }

    /// Get plugin directory path
    pub fn plugin_dir(&self) -> &PathBuf {
        &self.config.plugin_dir
    }

    /// List available plugins
    pub async fn list_plugins(&self) -> Result<Vec<String>> {
        let plugins = self
            .loader
            .list_sorted()
            .iter()
            .map(|(id, source)| {
                format!(
                    "{}: {} ({})",
                    id, source.manifest.name, source.manifest.status
                )
            })
            .collect();
        Ok(plugins)
    }

    /// Execute plugin by name
    pub async fn execute(
        &self,
        plugin_name: &str,
        args: serde_json::Value,
    ) -> Result<serde_json::Value> {
        debug!(plugin_name, ?args, "Executing plugin");

        if let Some(plugin) = self.loader.get(plugin_name) {
            // Execute plugin code
            let sandbox = crate::lua::PluginSandbox::new()?;
            let result = sandbox.execute(&plugin.code, args)?;
            Ok(result)
        } else {
            Err(anyhow::anyhow!("Plugin not found: {}", plugin_name))
        }
    }

    /// Get plugin count
    pub fn plugin_count(&self) -> usize {
        self.loader.count()
    }
}
