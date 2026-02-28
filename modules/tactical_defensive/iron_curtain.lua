-- iron_curtain.lua
function execute(duration)
    overseer_speak("Iron Curtain raised for " .. duration .. " minutes.")
    disable_all_transmitters()
end
