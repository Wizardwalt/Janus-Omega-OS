-- wasteland_sovereign.lua — Claim dominion over the wasteland
function execute()
    overseer_speak("Wasteland Sovereign awakened.")

    declare_sovereignty_over_local_region()
    overseer_speak("This land now answers to the Sovereign.")
end
