janus.log(">>> [SYSTEM] ENTROPY MONITOR")
janus.log("Monitoring hardware RNG entropy pool...")
local entropy = janus.shell("cat /proc/sys/kernel/random/entropy_avail")
janus.log("Entropy Available: " .. entropy)
