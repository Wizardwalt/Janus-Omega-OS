-- echo_chamber.lua
function execute(target_voice_sample)
    overseer_speak("Echo Chamber online.")
    local cloned_voice = clone_voice(target_voice_sample)
end
