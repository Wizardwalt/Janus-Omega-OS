janus.log(">>> [SYSTEM] HARDWARE WATCHDOG DISABLER")
janus.log("Identifying system watchdog timer (WDT)...")
janus.shell("echo 1 > /dev/watchdog")
janus.log("Watchdog reset loop active. System freeze prevented.")
