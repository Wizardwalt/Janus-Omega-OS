-- soul_thief.lua
function execute(device)
    overseer_speak("Soul Thief engaged. Extracting essence.")
    local profile = {habits = "High caffeine intake", fears = "Unknown"}
    save_to_blackbox("soul_profiles/" .. device.imei .. ".soul", profile)
end
