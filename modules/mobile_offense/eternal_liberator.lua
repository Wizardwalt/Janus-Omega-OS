-- eternal_liberator.lua - Permanent worldwide carrier unlock
function execute(devices)
    overseer_speak("Eternal Liberator awakened. Breaking all carrier locks worldwide.")
    local freed = 0
    for _, device in ipairs(devices) do
        if perform_eternal_unlock(device) then freed = freed + 1 end
    end
    log_to_blackbox({module = "eternal_liberator", freed = freed})
    overseer_speak(freed .. " devices are now free on any network worldwide.")
end
