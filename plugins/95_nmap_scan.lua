janus.log(">>> [CERBERUS] NETWORK SCAN")
janus.shell("nmap -sS -O -T4 192.168.1.1/24 -oN scan.txt")
janus.log("Results saved.")
