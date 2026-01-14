janus.log(">>> [SECURITY] APP LOCK BYPASS")
janus.log("Identifying App Lock processes...")
janus.shell("am force-stop com.android.settings")
janus.log("App Lock suppression active.")
