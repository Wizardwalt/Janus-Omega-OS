-- evil_twin_pro.lua - Professional rogue AP with captive portal
function execute(ssid)
    overseer_speak("Evil Twin Pro deployed. SSID: " .. ssid)
    create_rogue_ap(ssid)
    start_captive_portal()
end
