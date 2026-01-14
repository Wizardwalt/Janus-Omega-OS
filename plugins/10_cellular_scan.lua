janus.log(">>> [INTEL] CELLULAR ANALYSIS")
janus.log("Scanning baseband version...")
local baseband = janus.shell("getprop gsm.version.baseband")
janus.log("Baseband: " .. (baseband or "Unknown"))

janus.log("Checking IMEI status...")
local imei = janus.shell("service call iphonesubinfo 1")
janus.log("IMEI Data retrieved.")

janus.log("Analyzing SIM state...")
local sim = janus.shell("getprop gsm.sim.state")
janus.log("SIM State: " .. (sim or "N/A"))

janus.log("Cellular scan complete.")
