-- liberator_mass.lua
function execute(devices, options)
    overseer_speak("Liberator Mass protocol engaged. " .. #devices .. " devices detected.")
    local success_count = 0
    for i, device in ipairs(devices) do
        if attempt_carrier_unlock(device) then success_count = success_count + 1 end
    end
    log_to_blackbox({module = "liberator_mass", success = success_count})
    overseer_speak("Mass liberation complete. " .. success_count .. " devices freed.")
end
