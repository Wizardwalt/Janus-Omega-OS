-- fear_cascade.lua
function execute(target, intensity)
    intensity = intensity or 7
    overseer_speak("Fear Cascade activated. Intensity: " .. intensity)
    broadcast_on_local_frequencies("You are being watched.")
    log_to_blackbox({module = "fear_cascade", intensity = intensity})
end
