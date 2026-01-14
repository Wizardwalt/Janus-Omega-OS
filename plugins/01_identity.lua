janus.log(">>> [UPGRADE] ADB IDENTITY SCAN v2.0")
janus.log("Scanning baseband, bootloader, and secure patch level...")
local props = {"ro.product.model", "ro.build.version.release", "ro.build.version.security_patch", "ro.bootloader"}
for _, p in ipairs(props) do
    janus.log(p .. ": " .. (janus.shell("getprop " .. p) or "N/A"))
end
janus.log("Hardware Serial: " .. (janus.shell("getprop ro.serialno") or "UNKNOWN"))
