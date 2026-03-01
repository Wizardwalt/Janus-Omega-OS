-- directional_ghost.lua - Ghost direction finding
function execute(frequency)
    overseer_speak("Directional Ghost scanning " .. frequency .. " MHz.")
    local direction = calculate_signal_direction(frequency)
    overseer_speak("Signal source located at bearing " .. direction .. " degrees.")
end
