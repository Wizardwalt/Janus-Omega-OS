janus.log(">>> [SEC] THREAT DRAGNET (50+ CHECKS)")
local paths = {
    "/system/bin/su", "/sbin/su", "/data/local/xbin/su", 
    "/data/data/com.flexispy.android", "/data/data/com.mnspy.application"
}
for _, p in ipairs(paths) do
    local res = janus.shell("ls " .. p)
    if not string.find(res, "No such") then janus.log("CRITICAL THREAT: " .. p) end
end
