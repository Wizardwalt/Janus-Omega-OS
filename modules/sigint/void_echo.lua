-- void_echo.lua
function execute(frequency, duration)
    overseer_speak("Void Echo engaged on " .. frequency .. " MHz.")
    configure_limesdr(frequency, "TX")
    log_to_blackbox({module = "void_echo", frequency = frequency})
end
