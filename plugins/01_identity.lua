janus.log(">>> [SCAN] IDENTITY")
janus.log("Model: " .. janus.shell("getprop ro.product.model"))
janus.log("Serial: " .. janus.shell("getprop ro.serialno"))
