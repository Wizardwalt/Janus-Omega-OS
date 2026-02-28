-- neural_frp.lua
function execute(device, options)
    overseer_speak("Neural FRP protocol engaged.")
    local success = neural_bypass_attempt(device)
    log_to_blackbox({module = "neural_frp", success = success})
end
