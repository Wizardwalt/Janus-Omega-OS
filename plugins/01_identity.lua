janus.log(">>> [SCAN] READING DEVICE IDENTITY")
local m = janus.shell("getprop ro.product.model")
janus.log("TARGET: " .. m)
