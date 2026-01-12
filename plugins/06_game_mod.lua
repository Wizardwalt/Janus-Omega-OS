janus.log(">>> [MOD] GAME GENIE")
janus.log("Injecting Infinite Coins (Generic Unity XML)...")
janus.shell("find /data/data -name '*.xml' -exec sed -i 's/\"coins\" value=\"[0-9]*\"/\"coins\" value=\"9999999\"/g' {} \;")
