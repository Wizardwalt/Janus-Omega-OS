-- psyche_reaver.lua — Master of Minds
function execute(target, intensity)
    intensity = intensity or 10
    overseer_speak("Psyche Reaver unleashed at maximum intensity.")

    local payload = craft_perfect_psychological_weapon(target, intensity)
    broadcast_targeted_attack(payload)

    overseer_speak("The target's mind is now ours.")
end
