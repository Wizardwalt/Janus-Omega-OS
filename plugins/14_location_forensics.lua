janus.log(">>> [LOGISTICS] LOCATION BREADCRUMBS")
janus.log("Extracting last known GPS coordinates...")
local gps = janus.shell("dumpsys location | grep -m 1 'last location'")
janus.log("Last Loc: " .. (gps or "Cached data only"))

janus.log("Mapping cellular tower history...")
local towers = janus.shell("dumpsys telephony.registry | grep 'mServiceState'")
janus.log("Tower history logged.")

janus.log("Location forensics complete.")
