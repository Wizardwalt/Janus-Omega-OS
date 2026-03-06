-- scrap_titan.lua
function execute(available_scrap)
    overseer_speak("Scrap Titan protocol activated.")
    local built_tool = fabricate_from_scrap(available_scrap)
end
