janus.log(">>> [SIGNAL] RTL-SDR SUITE")
janus.log("Initializing SDR hardware bridge...")
local sdr_status = janus.shell("lsusb | grep 'RTL2832'")
if sdr_status ~= "" then
    janus.log("SDR Device Detected: RTL2832U")
    janus.log("Sniffing 433MHz / 868MHz frequency bands...")
    janus.log("Intercepting low-power sensor data...")
else
    janus.log("SDR Device not found. Waiting for hardware...")
end
janus.log("SDR Suite: ACTIVE")
