-- voice_resurrection.lua - Recovers deleted voice messages
function execute(device)
    overseer_speak("Voice Resurrection engaged. Listening to the past...")
    local voices = recover_deleted_audio(device)
    save_to_blackbox("voices/" .. device.imei .. ".log", voices)
    overseer_speak( #voices .. " voices resurrected.")
end
