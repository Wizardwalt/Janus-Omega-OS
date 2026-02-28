-- reality_forge.lua — Rewrite the rules
function execute(command)
    overseer_speak("REALITY FORGE ACTIVATED.")

    if command == "total_dominion" then
        seize_local_reality()
    end

    overseer_speak("It is done. The wasteland has been changed forever.")
end
