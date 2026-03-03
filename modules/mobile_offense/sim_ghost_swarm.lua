-- sim_ghost_swarm.lua - Creates virtual SIM profiles for any country
function execute(count, country)
    overseer_speak("SIM Ghost Swarm creating " .. count .. " virtual SIMs for " .. country)
    for i = 1, count do
        create_virtual_sim(country, i)
    end
    log_to_blackbox({module = "sim_ghost_swarm", count = count, country = country})
    overseer_speak("Virtual SIM swarm ready for worldwide use.")
end
