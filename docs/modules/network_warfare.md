# Network Warfare — Module How-To Guide
**Category:** `network_warfare` | **Module Count:** 150

The Network Warfare category covers Wi-Fi attacks, network reconnaissance, traffic interception, MITM operations, and infrastructure exploitation. The Pandora Titan's Intel AX210 Wi-Fi 6E adapter and Hydra Radio Array are the primary hardware tools.

---

## How to Run Any Network Warfare Module

1. Ensure the Pandora unit's Wi-Fi adapter is in monitor mode (auto-configured on boot)
2. Janus TUI → **Network Warfare**
3. Select module by name or number
4. Enter target SSID, BSSID, or IP range when prompted
5. Review output in real time in the log pane

---

## Key Named Modules

### Wi-Fi Marauder (nw_001–020 range)
Automated Wi-Fi deauthentication and WPA/WPA2/WPA3 handshake capture.

**How to run:**
1. Network Warfare → **Wi-Fi Marauder**
2. Scan nearby networks — select target SSID
3. Choose attack mode: Deauth / Handshake Capture / PMKID Attack
4. Capture saved to `/Evidence/wifi/` as `.pcap`

```
MARAUDER: TARGETING [SSID]
DEAUTH FRAMES: SENT (100)
HANDSHAKE: CAPTURED
SAVED: /Evidence/wifi/handshake.pcap
```

### SSL Strip (nw_021–040 range)
MITM tool that downgrades HTTPS connections to HTTP to capture plaintext traffic.

**How to run:**
1. Network Warfare → **SSL Strip**
2. Set interface (wlan0 by default)
3. Enable ARP poisoning to redirect target traffic
4. View captured credentials in real time

```
ARP POISON: ACTIVE
SSL STRIP: INTERCEPTING [TARGET IP]
CAPTURED: [URL + CREDENTIALS]
```

### OSINT Oracle (nw_041–060 range)
Real-time correlation of MAC addresses, device fingerprints, and network identifiers against public databases.

---

## Module Index by Function

| Range | Focus Area |
|---|---|
| nw_001 – nw_020 | Wi-Fi deauth, handshake capture, PMKID |
| nw_021 – nw_040 | MITM, SSL strip, ARP poisoning |
| nw_041 – nw_060 | Network OSINT, device fingerprinting |
| nw_061 – nw_080 | Port scanning, service enumeration (Nmap-based) |
| nw_081 – nw_100 | Packet injection and crafting |
| nw_101 – nw_120 | DNS poisoning, BGP monitoring, traffic redirection |
| nw_121 – nw_140 | Infrastructure attack — routers, switches, SCADA |
| nw_141 – nw_150 | Cellular network monitoring and analysis |

---

## Expected Output (numbered modules)

```
EXECUTING NETWORK_WARFARE [N]...
STATUS: OPERATIONAL
TARGET: [IP/SSID/RANGE]
RESULT: [CAPTURED/MAPPED/INTERCEPTED]
```

---

## Tips

- Always run a passive scan first (nw_061) before any active attacks to map the environment
- nw_081–100 packet injection modules require the Wi-Fi adapter to be in injection-capable mode — auto-set on Pandora Titan
- SCADA modules (nw_121–140) should only be used in isolated lab environments — they can cause real infrastructure disruption
- Combine Wi-Fi Marauder capture with the Password Attack modules in Cyber Warfare for offline WPA cracking
