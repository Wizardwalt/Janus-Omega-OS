-- starlink_messenger.lua - Worldwide messaging via satellite
function execute(message)
    overseer_speak("Starlink Messenger engaged. Sending via satellite constellation.")
    send_via_starlink(message)
    log_to_blackbox({module = "starlink_messenger", status = "sent"})
    overseer_speak("Message delivered worldwide via satellite.")
end
