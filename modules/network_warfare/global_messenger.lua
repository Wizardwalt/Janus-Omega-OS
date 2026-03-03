-- global_messenger.lua - Worldwide encrypted messaging over Ghost Network
function execute(message, recipients)
    overseer_speak("Global Messenger engaged. Sending encrypted message worldwide.")
    send_encrypted_message(message, recipients)
    log_to_blackbox({module = "global_messenger", recipients = #recipients})
    overseer_speak("Message delivered securely to all recipients.")
end
