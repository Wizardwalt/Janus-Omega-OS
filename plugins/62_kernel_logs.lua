janus.log(">>> [SYSTEM] KERNEL LOG ANALYZER")
janus.log("Parsing dmesg for suspicious kernel modules...")
local dmesg = janus.shell("dmesg | tail -n 50")
janus.log("Kernel log analysis complete.")
