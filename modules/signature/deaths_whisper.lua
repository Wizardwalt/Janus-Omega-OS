-- deaths_whisper.lua — The final psychological weapon
function execute(target)
    overseer_speak("Death's Whisper deployed.")

    broadcast_subliminal_death_message(target)
    overseer_speak("They will hear the whisper until their last breath.")
end
