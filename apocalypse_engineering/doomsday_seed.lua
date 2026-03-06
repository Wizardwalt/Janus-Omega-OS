-- doomsday_seed.lua - Plants long-term survival caches
function execute(location)
    overseer_speak("Doomsday Seed planted at " .. location)
    create_hidden_survival_cache(location)
end
