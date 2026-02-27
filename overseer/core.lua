-- overseer/core.lua - The sentient core of Janus Omega OS
function overseer_speak(line)
    print("[OVERSEER] " .. line)
end

function process_voice_command(text)
    overseer_speak("Command received: " .. text)
end

function create_mission_plan(goal)
    overseer_speak("Generating mission plan for: " .. goal)
end

function overseer_init()
    overseer_speak("Overseer AI online. 500 modules at your command.")
end

return { init = overseer_init, speak = overseer_speak, process_voice = process_voice_command }
