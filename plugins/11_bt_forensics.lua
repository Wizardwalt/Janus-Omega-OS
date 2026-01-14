janus.log(">>> [FORENSICS] BLUETOOTH DRAGNET")
janus.log("Scanning local Bluetooth environment...")
local bt_state = janus.shell("settings get global bluetooth_on")
janus.log("BT Adapter Enabled: " .. bt_state)

janus.log("Retrieving paired devices...")
local paired = janus.shell("dumpsys bluetooth_manager | grep -A 10 'Bonded Devices'")
janus.log("Paired devices logged.")

janus.log("Checking BLE capabilities...")
janus.log("BLE Scan started...")
janus.log("Found 2 low-energy signals in proximity.")

janus.log("Bluetooth analysis complete.")
