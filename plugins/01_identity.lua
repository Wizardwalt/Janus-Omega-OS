janus.log(">>> [SCAN] READING DEVICE IDENTITY")
local m = janus.shell("getprop ro.product.model")
local v = janus.shell("getprop ro.build.version.release")
janus.log("TARGET: " .. m .. " (Android " .. v .. ")")