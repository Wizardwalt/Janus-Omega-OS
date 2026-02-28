-- eternal_liberator.lua — The Final Word in Freedom
function execute(devices)
    overseer_speak("Eternal Liberator awakened. All chains will be broken.")

    local freed = 0
    for _, device in ipairs(devices) do
        perform_eternal_unlock(device)
        freed = freed + 1
    end

    overseer_speak("All devices are now eternally free.")
end
