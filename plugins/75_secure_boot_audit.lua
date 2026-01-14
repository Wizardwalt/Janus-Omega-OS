janus.log(">>> [SYSTEM] UEFI SECURE BOOT AUDIT")
janus.log("Checking Secure Boot status...")
local sb = janus.shell("bootctl status | grep 'Secure Boot'")
janus.log("Secure Boot: " .. (sb or "Unknown"))
