-- src/lua/plugin_system.lua
-- Plugin loading and management system

local plugin_system = {}
plugin_system.plugins = {}
plugin_system.permissions = {
    network = false,
    filesystem = false,
    hardware = false,
    ai = false,
}

-- Plugin metadata structure
local plugin_meta = {
    name = "",
    version = "",
    author = "",
    permissions = {},
    init = nil,
    execute = nil,
}

-- Load a plugin
function plugin_system.load_plugin(plugin_path, permissions)
    local plugin_code, err = io.open(plugin_path):read("*a")
    if not plugin_code then
        return false, "Failed to read plugin: " .. err
    end
    
    -- Validate permissions
    for _, perm in ipairs(permissions or {}) do
        if not plugin_system.permissions[perm] then
            return false, "Permission denied: " .. perm
        end
    end
    
    -- Load into sandbox
    local plugin_env = setmetatable({}, {__index = _G})
    local plugin_func, load_err = load(plugin_code, plugin_path, "t", plugin_env)
    
    if not plugin_func then
        return false, "Failed to load plugin: " .. load_err
    end
    
    local success, result = pcall(plugin_func)
    if not success then
        return false, "Plugin initialization failed: " .. result
    end
    
    table.insert(plugin_system.plugins, {
        path = plugin_path,
        permissions = permissions,
        env = plugin_env,
    })
    
    print("Plugin loaded: " .. plugin_path)
    return true
end

-- Execute plugin function
function plugin_system.execute(plugin_index, function_name, args)
    local plugin = plugin_system.plugins[plugin_index]
    if not plugin then
        return nil, "Plugin not found"
    end
    
    local func = plugin.env[function_name]
    if not func then
        return nil, "Function not found in plugin"
    end
    
    if type(func) ~= "function" then
        return nil, "Not a function"
    end
    
    local success, result = pcall(func, unpack(args or {}))
    if not success then
        return nil, "Execution error: " .. result
    end
    
    return result
end

-- List loaded plugins
function plugin_system.list_plugins()
    return plugin_system.plugins
end

-- Unload plugin
function plugin_system.unload_plugin(plugin_index)
    table.remove(plugin_system.plugins, plugin_index)
    return true
end

return plugin_system
