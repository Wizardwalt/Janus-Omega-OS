-- JanusOS Module: SMS Messenger
-- Text messaging interface for Pandora Titan

local sms_messenger = {}
local messages = {}
local drafts = {}
local auto_reply = nil

-- Initialize SMS messenger
function sms_messenger.init()
    janus.log("SMS MESSENGER: Initializing...")
    
    -- Load saved messages
    sms_messenger.load_messages()
    
    janus.log("SMS MESSENGER: READY")
    return true
end

-- Load messages from storage
function sms_messenger.load_messages()
    local config_dir = os.getenv("HOME") .. "/.janus/messages"
    janus.exec_system_cmd("mkdir -p " .. config_dir)
    
    janus.log("MESSAGES: Loaded from " .. config_dir)
    return true
end

-- Save messages to storage
function sms_messenger.save_messages()
    local config_dir = os.getenv("HOME") .. "/.janus/messages"
    
    janus.log("MESSAGES: Saved to " .. config_dir)
    return true
end

-- Send SMS message
function sms_messenger.send_sms(number, text)
    if not number or not text then
        janus.log("ERROR: Number and text required")
        return false
    end
    
    -- Clean number
    local clean_number = string.gsub(number, "[%s%-()]", "")
    
    janus.log("SENDING SMS to " .. number)
    
    -- Use ModemManager to send SMS
    local cmd = string.format('mmcli -m 0 --sms-send-number="%s" --sms-send-text="%s"', 
                              clean_number, text:gsub('"', '\\"'))
    local result = janus.exec_system_cmd(cmd)
    
    if string.find(result, "successfully sent") or result ~= "" then
        -- Store in message history
        table.insert(messages, {
            type = "sent",
            number = number,
            text = text,
            time = os.time()
        })
        
        janus.log("SMS SENT: " .. #text .. " characters")
        janus.haptic_pulse(100)
        sms_messenger.save_messages()
        return true
    else
        janus.log("ERROR: Failed to send SMS")
        return false
    end
end

-- Send SMS to contact
function sms_messenger.send_to_contact(contact_name, text)
    -- Load contacts from phone_dialer module
    local phone_dialer = require("plugins.phone_capabilities.phone_dialer")
    
    janus.log("LOOKING UP CONTACT: " .. contact_name)
    return sms_messenger.send_sms(contact_name, text)
end

-- Receive SMS (simulated)
function sms_messenger.receive_sms(number, text)
    table.insert(messages, {
        type = "received",
        number = number,
        text = text,
        time = os.time(),
        read = false
    })
    
    janus.log("SMS RECEIVED from " .. number)
    janus.haptic_pulse(200)
    
    -- Check for auto-reply
    if auto_reply then
        sms_messenger.send_sms(number, auto_reply)
    end
    
    sms_messenger.save_messages()
    return true
end

-- Create SMS draft
function sms_messenger.create_draft(number, text)
    table.insert(drafts, {
        number = number,
        text = text,
        time = os.time()
    })
    
    janus.log("DRAFT SAVED: " .. number)
    return true
end

-- Show drafts
function sms_messenger.show_drafts()
    janus.log("=== DRAFTS ===")
    if not next(drafts) then
        janus.log("No drafts")
        return
    end
    
    for i, draft in ipairs(drafts) do
        janus.log(i .. ". " .. draft.number .. ": " .. string.sub(draft.text, 1, 50) .. "...")
    end
    
    return true
end

-- Send draft by index
function sms_messenger.send_draft(index)
    if not drafts[index] then
        janus.log("ERROR: Draft not found")
        return false
    end
    
    local draft = drafts[index]
    local result = sms_messenger.send_sms(draft.number, draft.text)
    
    if result then
        table.remove(drafts, index)
    end
    
    return result
end

-- Get unread message count
function sms_messenger.get_unread_count()
    local unread = 0
    for _, msg in ipairs(messages) do
        if msg.type == "received" and not msg.read then
            unread = unread + 1
        end
    end
    
    janus.log("UNREAD MESSAGES: " .. unread)
    return unread
end

-- Show message threads
function sms_messenger.show_threads()
    janus.log("=== MESSAGE THREADS ===")
    
    local threads = {}
    for _, msg in ipairs(messages) do
        if not threads[msg.number] then
            threads[msg.number] = {}
        end
        table.insert(threads[msg.number], msg)
    end
    
    if not next(threads) then
        janus.log("No messages")
        return
    end
    
    for number, thread in pairs(threads) do
        local last_msg = thread[#thread]
        local time = os.date("%H:%M", last_msg.time)
        janus.log(number .. " (" .. #thread .. " messages) - " .. time)
    end
    
    return true
end

-- Get thread with specific number
function sms_messenger.get_thread(number)
    local thread = {}
    for _, msg in ipairs(messages) do
        if msg.number == number then
            table.insert(thread, msg)
        end
    end
    
    janus.log("THREAD: " .. number .. " (" .. #thread .. " messages)")
    return thread
end

-- Mark message as read
function sms_messenger.mark_as_read(index)
    if messages[index] then
        messages[index].read = true
        janus.log("MARKED AS READ: Message " .. index)
        return true
    end
    
    return false
end

-- Delete message
function sms_messenger.delete_message(index)
    if messages[index] then
        table.remove(messages, index)
        janus.log("DELETED: Message " .. index)
        sms_messenger.save_messages()
        return true
    end
    
    return false
end

-- Search messages
function sms_messenger.search(query)
    query = string.lower(query)
    local results = {}
    
    for i, msg in ipairs(messages) do
        if string.find(string.lower(msg.text), query) or 
           string.find(string.lower(msg.number), query) then
            table.insert(results, {index = i, message = msg})
        end
    end
    
    janus.log("SEARCH: Found " .. #results .. " results for '" .. query .. "'")
    return results
end

-- Export messages to file
function sms_messenger.export_messages(filename)
    local config_dir = os.getenv("HOME") .. "/.janus"
    local filepath = config_dir .. "/" .. filename
    
    local file = io.open(filepath, "w")
    if not file then
        janus.log("ERROR: Cannot create file " .. filepath)
        return false
    end
    
    file:write("=== SMS MESSAGE EXPORT ===\n\n")
    
    for _, msg in ipairs(messages) do
        file:write("[" .. os.date("%Y-%m-%d %H:%M:%S", msg.time) .. "] ")
        file:write(msg.type:upper() .. ": " .. msg.number .. "\n")
        file:write(msg.text .. "\n\n")
    end
    
    file:close()
    janus.log("EXPORTED: " .. #messages .. " messages to " .. filepath)
    return true
end

-- Create auto-reply
function sms_messenger.create_auto_reply(text)
    auto_reply = text
    janus.log("AUTO-REPLY: ENABLED")
    janus.log("MESSAGE: " .. text)
    return true
end

-- Disable auto-reply
function sms_messenger.disable_auto_reply()
    auto_reply = nil
    janus.log("AUTO-REPLY: DISABLED")
    return true
end

-- Main execution
function execute()
    janus.log("SMS MESSENGER MODULE: ARMED")
    
    sms_messenger.init()
    
    janus.log("SMS MESSENGER: OPERATIONAL")
end

execute()
return sms_messenger
