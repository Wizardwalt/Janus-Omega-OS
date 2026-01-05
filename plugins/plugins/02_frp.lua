janus.log(">>> [HACK] INJECTING BROWSER")
janus.shell("am start -a android.intent.action.VIEW -d 'https://www.google.com/maps'")
janus.log("Payload Sent.")