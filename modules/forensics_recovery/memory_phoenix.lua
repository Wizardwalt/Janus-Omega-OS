-- memory_phoenix.lua
function execute(device)
    overseer_speak("Memory Phoenix rising from the ashes...")
    local recovered = carve_from_ram_dump(device)
    save_to_blackbox("phoenix_recoveries/" .. device.imei .. ".dat", recovered)
end
