# OSINT Oracle — Module How-To Guide
**Category:** `osint_oracle` | **Module Count:** 100

The OSINT Oracle category covers open-source intelligence gathering: correlating identifiers, mapping social networks, tracking digital footprints, geo-profiling, and aggregating public data sources into actionable intelligence.

---

## How to Run Any OSINT Oracle Module

1. Janus TUI → **OSINT Oracle**
2. Select module by number (osint_001 through osint_100)
3. Enter target identifier when prompted: phone number / email / username / IP / MAC / IMSI
4. Module queries local databases and available network sources
5. Output displayed in log pane and saved to `/Intelligence/osint/`

---

## Module Index by Function

| Range | Focus Area |
|---|---|
| osint_001 – osint_010 | Identity correlation — link phone/email/username/IP |
| osint_011 – osint_020 | Social media footprint mapping |
| osint_021 – osint_030 | Geo-profiling from EXIF, check-ins, and signal data |
| osint_031 – osint_040 | Business and corporate intelligence |
| osint_041 – osint_050 | Dark web presence scanning |
| osint_051 – osint_060 | Breach database correlation (leaked credentials) |
| osint_061 – osint_070 | Vehicle and property record lookup |
| osint_071 – osint_080 | Network infrastructure OSINT (WHOIS, ASN, BGP) |
| osint_081 – osint_090 | Device fingerprinting from public sources |
| osint_091 – osint_100 | Threat intelligence aggregation and reporting |

---

## Key Workflows

### Profile a Target by Phone Number
1. OSINT Oracle → osint_001
2. Enter phone number
3. Module cross-references carrier data, social media, and breach databases
4. Output: full profile with associated identifiers

### Map Social Network
1. OSINT Oracle → osint_011
2. Enter username or handle
3. Module searches 50+ platforms for matching accounts
4. Returns linked accounts, post history, and relationship map

### Geo-Profile from EXIF
1. OSINT Oracle → osint_021
2. Load target photos from `/Evidence/` folder
3. Module extracts GPS coordinates from EXIF data
4. Plots movement history on tactical map

### Dark Web Scan
1. OSINT Oracle → osint_041
2. Enter target email, username, or identifier
3. Module searches Tor onion indexes and known dark web databases
4. Reports any mentions, forum posts, or marketplace activity

---

## Expected Output

```
OSINT ORACLE [N]: EXECUTING...
TARGET: [IDENTIFIER]
SOURCES QUERIED: 47
MATCHES FOUND: 12
CROSS-REFERENCES: 8
REPORT: /Intelligence/osint/[TARGET]_profile.json
STATUS: OPERATIONAL
```

---

## Tips

- Combine osint_001 (identity correlation) with osint_021 (geo-profile) for a complete target picture
- osint_091–100 generate structured threat intelligence reports in JSON and Markdown formats
- The Singularity (Hailo-8) AI module accelerates OSINT analysis — enable it in System Settings for 10x faster correlation
- On the Pandora Titan, the AR-HUD overlays OSINT results on your field of view in real time
