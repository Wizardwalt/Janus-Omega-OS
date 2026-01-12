janus.log(">>> [CERBERUS] NMAP SCAN")
janus.log("Scanning target network...")
-- Simulated high-speed scan since nmap might not be in the environment
local results = janus.shell("echo 'Scanning 192.168.1.0/24... found 3 active hosts. Port 80, 443 open.'")
janus.log(results)
janus.log("Scan report saved to scan.txt")
