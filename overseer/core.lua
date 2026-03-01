function overseer_speak(line)
    print("[OVERSEER] " .. line)
end

function overseer_init()
    overseer_speak("Overseer AI online. 1000 modules at your command.")
end

return { init = overseer_init, speak = overseer_speak }
