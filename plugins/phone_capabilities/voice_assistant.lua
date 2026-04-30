-- JanusOS Module: Voice Assistant
-- Voice command interface for Pandora Titan

local voice_assistant = {}
local voice_commands = {}
local is_listening = false

-- Initialize voice recognition
function voice_assistant.init()
    janus.log("VOICE ASSISTANT: Initializing...")
    
    -- Initialize audio input from Titan's microphone
    janus.exec_system_cmd("amixer set Capture cap")
    
    janus.log("VOICE ASSISTANT: READY")
    janus.log("Say 'Janus' to activate")
    
    return true
end

-- Start listening
function voice_assistant.start_listening()
    is_listening = true
    janus.log("LISTENING...")
    janus.haptic_pulse(100)
    
    return true
end

-- Stop listening
function voice_assistant.stop_listening()
    is_listening = false
    janus.log("LISTEN STOPPED")
    
    return true
end

-- Process voice command
function voice_assistant.process_command(command)
    command = string.lower(command)
    janus.log("COMMAND: " .. command)
    
    -- Phone commands
    if string.find(command, "dial") then
        local number = string.match(command, "dial%s+([0-9+%s%-]+)")
        if number then
            janus.log("Dialing " .. number)
            return "dialing"
        end
    end
    
    if string.find(command, "text") or string.find(command, "message") then
        janus.log("Ready to compose message")
        return "compose_sms"
    end
    
    -- Browser commands
    if string.find(command, "search") then
        local query = string.match(command, "search%s+(.+)")
        if query then
            janus.log("Searching for: " .. query)
            return "search:" .. query
        end
    end
    
    if string.find(command, "open") then
        local url = string.match(command, "open%s+(.+)")
        if url then
            janus.log("Opening: " .. url)
            return "navigate:" .. url
        end
    end
    
    -- System commands
    if string.find(command, "volume") then
        local level = string.match(command, "volume%s+([0-9]+)")
        if level then
            janus.log("Setting volume to " .. level)
            return "volume:" .. level
        end
    end
    
    if string.find(command, "screenshot") then
        janus.log("Taking screenshot")
        return "screenshot"
    end
    
    if string.find(command, "lock") then
        janus.log("Locking device")
        return "lock"
    end
    
    if string.find(command, "help") then
        voice_assistant.show_help()
        return "help"
    end
    
    janus.log("Command not recognized")
    return "unknown"
end

-- Text to speech response
function voice_assistant.speak(text)
    janus.log("SPEAKING: " .. text)
    
    -- Use espeak for text-to-speech
    local cmd = string.format('espeak -s 150 "%s"', text:gsub('"', '\\"'))
    janus.exec_system_cmd(cmd)
    
    return true
end

-- Show available commands
function voice_assistant.show_help()
    janus.log("=== VOICE COMMANDS ===")
    janus.log("Phone: 'dial [number]', 'text [contact]', 'call [contact]'")
    janus.log("Browser: 'search [query]', 'open [website]', 'go back'")
    janus.log("System: 'volume [0-100]', 'screenshot', 'lock', 'unlock'")
    janus.log("General: 'help', 'status', 'time', 'date'")
    
    return true
end

-- Register custom command
function voice_assistant.register_command(trigger, action)
    table.insert(voice_commands, {
        trigger = string.lower(trigger),
        action = action
    })
    
    janus.log("COMMAND REGISTERED: " .. trigger)
    return true
end

-- Listen and execute
function voice_assistant.listen_and_execute()
    janus.log("VOICE ASSISTANT: ACTIVE")
    janus.log("Listening for wake word: 'Janus'")
    
    -- Simulate voice input (in real implementation, would use audio input)
    voice_assistant.start_listening()
    
    return true
end

-- Dictation mode
function voice_assistant.dictation_mode()
    janus.log("DICTATION MODE: ACTIVE")
    voice_assistant.speak("Ready to transcribe. Start speaking.")
    
    -- In real implementation, would capture audio and use STT
    -- For now, log the mode
    janus.log("Listening for dictation...")
    
    return true
end

-- Set reminder with voice
function voice_assistant.set_reminder(text, time)
    janus.log("REMINDER: " .. text .. " at " .. time)
    return true
end

-- Get weather by voice
function voice_assistant.get_weather()
    janus.log("WEATHER: Checking current conditions")
    
    local weather = janus.exec_system_cmd("curl -s wttr.in?format=3")
    voice_assistant.speak(weather)
    
    return weather
end

-- Play audio response
function voice_assistant.play_response(response_type)
    local responses = {
        success = "Command executed",
        error = "Command failed",
        confirm = "Are you sure?",
        thanks = "No problem"
    }
    
    if responses[response_type] then
        voice_assistant.speak(responses[response_type])
    end
    
    return true
end

-- Main execution
function execute()
    janus.log("VOICE ASSISTANT MODULE: ARMED")
    
    voice_assistant.init()
    
    -- Register common commands
    voice_assistant.register_command("help", "show_help")
    voice_assistant.register_command("status", "show_status")
    
    janus.log("VOICE ASSISTANT: OPERATIONAL")
end

execute()
return voice_assistant
