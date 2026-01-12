janus.log(">>> [SEC] ROOT SCANNER")
local res = janus.shell("ls /system/bin/su")
if string.find(res, "No such") then
    janus.log("Device is NOT Rooted.")
else
    janus.log("CRITICAL: Device is ROOTED.")
end
