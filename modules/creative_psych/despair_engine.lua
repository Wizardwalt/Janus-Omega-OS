-- despair_engine.lua - Advanced despair broadcast
function execute(intensity)
    overseer_speak("Despair Engine online at intensity " .. intensity)
    broadcast_despair_wave(intensity)
end
