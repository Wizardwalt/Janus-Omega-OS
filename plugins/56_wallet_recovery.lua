janus.log(">>> [FORENSICS] CRYPTO WALLET RECOVERY")
janus.log("Searching for wallet.dat and seed phrase files...")
local wallets = janus.shell("find /sdcard -name '*wallet*' -o -name '*seed*'")
janus.log("Potential wallets: " .. (wallets or "None"))
