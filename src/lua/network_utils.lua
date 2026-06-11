-- src/lua/network_utils.lua
-- Network utilities and Ghost Network integration

local network_utils = {}
network_utils.is_connected = false
network_utils.mesh_nodes = {}
network_utils.encrypted_channels = {}

-- Check network connection
function network_utils.check_connection()
    -- Simplified check - in production uses actual network interfaces
    network_utils.is_connected = os.time() % 3 ~= 0
    return network_utils.is_connected
end

-- Initialize Ghost Network mesh
function network_utils.init_mesh(node_id)
    print("Initializing Ghost Network node: " .. node_id)
    table.insert(network_utils.mesh_nodes, {
        id = node_id,
        status = "active",
        encrypted = true,
    })
    return true
end

-- Establish encrypted channel
function network_utils.create_encrypted_channel(peer_id, cipher_type)
    cipher_type = cipher_type or "AES-256-GCM"
    local channel = {
        peer_id = peer_id,
        cipher = cipher_type,
        established = true,
        timestamp = os.time(),
    }
    table.insert(network_utils.encrypted_channels, channel)
    print("Encrypted channel established with " .. peer_id .. " using " .. cipher_type)
    return channel
end

-- Send encrypted message
function network_utils.send_encrypted(peer_id, message)
    if not network_utils.is_connected then
        return false, "Network not connected"
    end
    
    local channel = nil
    for _, ch in ipairs(network_utils.encrypted_channels) do
        if ch.peer_id == peer_id then
            channel = ch
            break
        end
    end
    
    if not channel then
        return false, "No encrypted channel with " .. peer_id
    end
    
    -- Simulated encryption and sending
    print(string.format("[ENCRYPTED] To %s via %s: %s", peer_id, channel.cipher, message))
    return true
end

-- List connected mesh nodes
function network_utils.list_nodes()
    return network_utils.mesh_nodes
end

-- Get network status
function network_utils.get_status()
    return {
        connected = network_utils.is_connected,
        mesh_nodes = #network_utils.mesh_nodes,
        encrypted_channels = #network_utils.encrypted_channels,
    }
end

return network_utils
