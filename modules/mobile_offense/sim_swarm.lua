-- sim_swarm.lua - Creates swarm of virtual SIM profiles
function execute(count)
    overseer_speak("SIM Swarm engaged. Creating " .. count .. " virtual SIMs.")
    for i = 1, count do
        create_virtual_sim(i)
    end
    log_to_blackbox({module = "sim_swarm", count = count})
    overseer_speak("SIM Swarm deployed.")
end
