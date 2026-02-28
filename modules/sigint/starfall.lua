-- starfall.lua
function execute(target_coords, duration)
    overseer_speak("Starfall protocol initiated.")
    spoof_gps_signals(target_coords)
end
