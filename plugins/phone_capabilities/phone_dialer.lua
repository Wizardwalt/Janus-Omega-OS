-- JanusOS Module: Phone Dialer
-- Voice calling interface for Pandora Titan

local phone_dialer = {}
local contacts = {}
local call_history = {}
local current_call = nil

-- Initialize phone dialer
function phone_dialer.init()
    janus.log("PHONE DIALER: Initializing...")
    
    -- Load saved contacts
    phone_dialer.load_contacts()
    
    -- Initialize modem
    janus.exec_system_cmd("mmcli -m 0 --enable")
    
    janus.log("PHONE DIALER: READY")
    return true
end

-- Load contacts from storage
function phone_dialer.load_contacts()
    local config_dir = os.getenv("HOME") .. "/.janus/phone"
    janus.exec_system_cmd("mkdir -p " .. config_dir)
    
    janus.log("CONTACTS: Loaded from " .. config_dir)
    return true
end

-- Save contacts to storage
function phone_dialer.save_contacts()
    local config_dir = os.getenv("HOME") .. "/.janus/phone"
    
    janus.log("CONTACTS: Saved to " .. config_dir)
    return true
end

-- Save a new contact
function phone_dialer.save_contact(name, number)
    if not name or not number then
        janus.log("ERROR: Name and number required")
        return false
    end
    
    contacts[name] = number
    phone_dialer.save_contacts()
    
    janus.log("CONTACT SAVED: " .. name .. " (" .. number .. ")")
    return true
end

-- Show all contacts
function phone_dialer.show_contacts()
    janus.log("=== SAVED CONTACTS ===")
    if not next(contacts) then
        janus.log("No contacts saved")
        return
    end
    
    for name, number in pairs(contacts) do
        janus.log(name .. ": " .. number)
    end
    
    return true
end

-- Dial a number
function phone_dialer.dial(number)
    if not number or number == "" then
        janus.log("ERROR: No number to dial")
        return false
    end
    
    -- Format number if needed
    if not string.match(number, "^%+?1?[0-9%s%-()]*$") then
        janus.log("ERROR: Invalid number format")
        return false
    end
    
    -- Remove formatting
    local clean_number = string.gsub(number, "[%s%-()]", "")
    
    janus.log("DIALING: " .. number)
    
    -- Use ModemManager to dial
    local cmd = string.format('mmcli -m 0 --voice-call-create "%s"', clean_number)
    local result = janus.exec_system_cmd(cmd)
    
    if string.find(result, "Call ID") then
        current_call = number
        janus.log("CALL INITIATED")
        janus.haptic_pulse(200)
        return true
    else
        janus.log("ERROR: Failed to initiate call")
        return false
    end
end

-- Dial a contact by name
function phone_dialer.dial_contact(name)
    if not contacts[name] then
        janus.log("ERROR: Contact not found: " .. name)
        return false
    end
    
    return phone_dialer.dial(contacts[name])
end

-- Accept incoming call
function phone_dialer.accept_call()
    if not current_call then
        janus.log("ERROR: No incoming call")
        return false
    end
    
    janus.log("ACCEPTING CALL...")
    
    -- Use ModemManager to accept
    janus.exec_system_cmd("mmcli -m 0 --voice-call-accept")
    
    janus.log("CALL ACCEPTED")
    janus.haptic_pulse(150)
    return true
end

-- Reject incoming call
function phone_dialer.reject_call()
    if not current_call then
        janus.log("ERROR: No incoming call")
        return false
    end
    
    janus.log("REJECTING CALL...")
    
    -- Use ModemManager to reject
    janus.exec_system_cmd("mmcli -m 0 --voice-call-hangup")
    
    current_call = nil
    janus.log("CALL REJECTED")
    return true
end

-- End current call
function phone_dialer.end_call()
    if not current_call then
        janus.log("ERROR: No active call")
        return false
    end
    
    janus.log("ENDING CALL...")
    
    -- Use ModemManager to hangup
    janus.exec_system_cmd("mmcli -m 0 --voice-call-hangup")
    
    -- Log to call history
    table.insert(call_history, {
        number = current_call,
        time = os.time(),
        duration = 0
    })
    
    current_call = nil
    janus.log("CALL ENDED")
    return true
end

-- Mute microphone
function phone_dialer.mute()
    janus.exec_system_cmd("amixer set Capture 0%")
    janus.log("MICROPHONE: MUTED")
    return true
end

-- Unmute microphone
function phone_dialer.unmute()
    janus.exec_system_cmd("amixer set Capture 80%")
    janus.log("MICROPHONE: UNMUTED")
    return true
end

-- Enable speakerphone
function phone_dialer.enable_speaker()
    janus.exec_system_cmd("amixer set Speaker 100%")
    janus.log("SPEAKERPHONE: ENABLED")
    return true
end

-- Disable speakerphone
function phone_dialer.disable_speaker()
    janus.exec_system_cmd("amixer set Speaker 0%")
    janus.log("SPEAKERPHONE: DISABLED")
    return true
end

-- Get signal strength
function phone_dialer.get_signal_strength()
    local result = janus.exec_system_cmd("mmcli -m 0 --get-signal-quality")
    
    -- Parse signal strength from result
    local strength = string.match(result, "signal quality:%s+(%d+)")
    if not strength then
        strength = 0
    end
    
    strength = tonumber(strength)
    local bars = math.ceil(strength / 20)
    
    janus.log("SIGNAL: " .. bars .. "/5 bars (" .. strength .. "%)")
    return bars
end

-- Get network status
function phone_dialer.get_network_status()
    local result = janus.exec_system_cmd("mmcli -m 0 --get-supported-modes")
    
    if string.find(result, "roaming") then
        janus.log("NETWORK: Registered, roaming")
        return "roaming"
    elseif string.find(result, "registered") then
        janus.log("NETWORK: Registered, home")
        return "home"
    else
        janus.log("NETWORK: Searching...")
        return "searching"
    end
end

-- Show call history
function phone_dialer.show_history()
    janus.log("=== CALL HISTORY ===")
    if not next(call_history) then
        janus.log("No call history")
        return
    end
    
    for i, call in ipairs(call_history) do
        local time = os.date("%Y-%m-%d %H:%M:%S", call.time)
        janus.log(i .. ". " .. call.number .. " - " .. time .. " (" .. call.duration .. "s)")
    end
    
    return true
end

-- Check for missed calls
function phone_dialer.get_missed_calls()
    local missed = 0
    for _, call in ipairs(call_history) do
        if call.duration == 0 then
            missed = missed + 1
        end
    end
    
    janus.log("MISSED CALLS: " .. missed)
    return missed
end

-- Main execution
function execute()
    janus.log("PHONE DIALER MODULE: ARMED")
    
    phone_dialer.init()
    
    janus.log("PHONE DIALER: OPERATIONAL")
end

execute()
return phone_dialer
