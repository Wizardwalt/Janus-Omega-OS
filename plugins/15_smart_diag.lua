janus.log(">>> [SYSTEM] SMART DIAGNOSTICS")
janus.log("Analyzing battery health cycle...")
local battery = janus.shell("dumpsys battery | grep 'level'")
janus.log("Battery: " .. battery)

janus.log("Scanning kernel panic history...")
local panic = janus.shell("ls /proc/last_kmsg")
janus.log("Kernel logs check: " .. (panic and "Available" or "Clean"))

janus.log("Diagnostics complete.")
