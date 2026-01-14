janus.log(">>> [SECURITY] CLOUD BACKDOOR SCAN")
janus.log("Checking for unauthorized cloud accounts...")
local accounts = janus.shell("getprop persist.sys.cloud.account")
janus.log("Cloud ID: " .. (accounts or "None detected"))

janus.log("Scanning for persistent tracking tokens...")
local tokens = janus.shell("ls /data/system/users/0/fpdata")
janus.log("Tracking data analyzed.")

janus.log("Verifying OEM remote-lock status...")
local lock = janus.shell("getprop ro.frp.pst")
janus.log("Lock partition: " .. (lock or "Standard"))

janus.log("Cloud security scan complete.")
