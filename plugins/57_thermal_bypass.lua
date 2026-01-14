janus.log(">>> [SYSTEM] THERMAL THROTTLE BYPASS")
janus.log("Disabling CPU thermal throttling for high-performance processing...")
janus.shell("echo 0 > /sys/class/thermal/thermal_zone0/mode")
janus.log("Thermal limits: DISABLED")
