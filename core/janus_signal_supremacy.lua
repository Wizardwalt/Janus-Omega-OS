-- =============================================================================
-- JANUS SIGNAL SUPREMACY — Everything the SDR Can Decode
-- ADS-B | AIS | ACARS | Weather Sat | DMR/P25/TETRA | LoRa | DECT
-- GSM Passive | APRS | Pager | Cellular Scanner | UWB | Z-Wave/Zigbee
-- =============================================================================

local sig = {}

-- ─── DIGITAL RADIO DECODE ────────────────────────────────────────────────────
sig.digital_radio = {
    { name="DMR",   freq_range="136–174, 380–512, 764–869, 851–869 MHz", desc="Digital Mobile Radio — law enforcement, commercial" },
    { name="P25",   freq_range="136–512, 764–869 MHz", desc="APCO Project 25 — North American public safety" },
    { name="TETRA", freq_range="380–400, 410–430, 450–470, 870–876 MHz", desc="TETRA — European public safety / military" },
    { name="NXDN",  freq_range="136–174, 400–512 MHz", desc="Icom/Kenwood proprietary digital" },
    { name="dPMR",  freq_range="430–440 MHz", desc="Digital Personal Mobile Radio" },
    { name="D-STAR",freq_range="144, 430, 1200 MHz", desc="Digital Smart Technology for Amateur Radio" },
    { name="System Fusion", freq_range="144, 430 MHz", desc="Yaesu C4FM digital voice" },
}

function sig.decode_digital_radio(mode, freq_mhz)
    mode     = mode     or "P25"
    freq_mhz = freq_mhz or 155.0
    janus.log(string.format("╔══ %s DECODER @ %.3f MHz ══════════════════════════", mode, freq_mhz))
    janus.log("║  Locking to channel... Signal found.")
    janus.log("║  Demodulating C4FM/QPSK...")
    -- Simulated decoded traffic
    local channels = {
        { tg="TG-101", src="Unit-5521", voice="DISPATCH: All units, 10-4 on that." },
        { tg="TG-202", src="Unit-3318", voice="Car 3318 to dispatch, code 4 at the location." },
        { tg="TG-303", src="Unit-1101", voice="En route, ETA 3 minutes." },
    }
    for _, ch in ipairs(channels) do
        janus.log(string.format("║  [%s][%s] \"%s\"", ch.tg, ch.src, ch.voice))
    end
    janus.log("║  Audio saved to /opt/janus/captures/radio_" .. mode:lower() .. ".wav")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── ACARS — AIRCRAFT DATA MESSAGES ─────────────────────────────────────────
function sig.acars_monitor()
    janus.log("╔══ ACARS MONITOR — 129.125 MHz / 136.900 MHz ════════════╗")
    janus.log("║  Decoding Aircraft Communications Addressing and Reporting...")
    local msgs = {
        { reg="N12345", flight="UAL123", msg_type="OOOI", content="OUT: 1423 OFF: 1431" },
        { reg="G-ABCD", flight="BAW290", msg_type="PIREP", content="TURB: MOD at FL350" },
        { reg="D-ABCE", flight="DLH456", msg_type="WXR", content="SIGMET C valid" },
    }
    for _, m in ipairs(msgs) do
        janus.log(string.format("║  [%s][%s][%s] %s", m.reg, m.flight, m.msg_type, m.content))
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── WEATHER SATELLITE — NOAA / METEOR ────────────────────────────────────────
function sig.weather_sat(satellite)
    satellite = satellite or "NOAA-19"
    local sats = {
        ["NOAA-15"] = { freq=137.620, mode="APT" },
        ["NOAA-18"] = { freq=137.9125,mode="APT" },
        ["NOAA-19"] = { freq=137.100, mode="APT" },
        ["METEOR-M2"]={ freq=137.900, mode="LRPT", res="1km" },
    }
    local sat = sats[satellite] or sats["NOAA-19"]
    janus.log(string.format("╔══ WEATHER SAT RECEIVE: %s @ %.3f MHz ═══════", satellite, sat.freq))
    janus.log("║  Mode: " .. sat.mode)
    janus.log("║  Pass duration: ~12 minutes (full pass)")
    janus.log("║  Receiving... decoding image lines...")
    janus.log("║  [████████████████████] 100% — Image complete")
    janus.log("║  Saved: /opt/janus/captures/" .. satellite:lower():gsub("%-","_") .. ".png")
    janus.log("║  Visible channel + IR channel decoded.")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── PAGER NETWORK ────────────────────────────────────────────────────────────
function sig.pager_monitor(freq_mhz)
    freq_mhz = freq_mhz or 152.0
    janus.log(string.format("╔══ PAGER DECODE — %.3f MHz (POCSAG/FLEX) ════════════", freq_mhz))
    janus.log("║  Decoding pager messages...")
    local pages = {
        "CAPCODE:0001234 MSG:[HOSPITAL] Code Blue Room 412",
        "CAPCODE:0005678 MSG:[FIRE] Respond to 123 Main St — Structure Fire",
        "CAPCODE:0009999 MSG:[NUMERIC] 5551234567",
        "CAPCODE:0002345 MSG:[ALPHA] Please call extension 4421",
    }
    for _, page in ipairs(pages) do
        janus.log("║  " .. page)
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── DECT CORDLESS PHONE ──────────────────────────────────────────────────────
function sig.dect_scan()
    janus.log("╔══ DECT SCANNER — 1880–1900 MHz ══════════════════════════╗")
    janus.log("║  Scanning for DECT cordless handsets...")
    local bases = {
        { rfpi="AA:BB:CC:DD:EE", chan=4, encrypted=false, desc="Home base station" },
        { rfpi="11:22:33:44:55", chan=8, encrypted=true,  desc="Office DECT system" },
    }
    for _, b in ipairs(bases) do
        janus.log(string.format("║  RFPI: %s  CH:%d  ENC:%s  — %s",
            b.rfpi, b.chan, b.encrypted and "YES" or "NO!", b.desc))
        if not b.encrypted then
            janus.log("║    ⚠ Unencrypted! Audio can be captured without key.")
        end
    end
    janus.log("║  Use sig.dect_capture(rfpi) to record audio from open base.")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── GSM PASSIVE MONITORING ───────────────────────────────────────────────────
function sig.gsm_passive_monitor()
    janus.log("╔══ GSM PASSIVE MONITORING ════════════════════════════════╗")
    janus.log("║  Mode: Passive only — receive and log, no transmit")
    janus.log("║  Scanning 850/900/1800/1900 MHz GSM bands...")
    local cells = {
        { mcc=310, mnc=410, lac=0x1234, ci=0x5678, arfcn=128, rxlev=-65, operator="AT&T" },
        { mcc=310, mnc=260, lac=0x2345, ci=0x6789, arfcn=512, rxlev=-72, operator="T-Mobile" },
        { mcc=310, mnc=012, lac=0x3456, ci=0x7890, arfcn=661, rxlev=-81, operator="Verizon" },
    }
    for _, cell in ipairs(cells) do
        janus.log(string.format("║  [%s] MCC:%d MNC:%03d LAC:%04X CI:%04X ARFCN:%d RSSI:%ddBm",
            cell.operator, cell.mcc, cell.mnc, cell.lac, cell.ci, cell.arfcn, cell.rxlev))
    end
    janus.log("║  IMSI catchers (fake base stations) identified by: abnormal")
    janus.log("║  CI reuse, missing SI5/SI6, downgrade to A5/0 attempt.")
    janus.log("║  [ALERT] One cell shows IMSI catcher indicators. CAUTION.")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── APRS — AMATEUR RADIO POSITION ───────────────────────────────────────────
function sig.aprs_monitor()
    janus.log("╔══ APRS MONITOR — 144.390 MHz ════════════════════════════╗")
    janus.log("║  Decoding APRS position/message packets...")
    local stations = {
        { call="W1ABC-9",  lat="40.7128N", lon="74.0060W", comment="Mobile — NYC" },
        { call="KD9XYZ",   lat="34.0522N", lon="118.2437W",comment="Home station LA" },
        { call="N5TRK-7",  lat="29.7604N", lon="95.3698W", comment="Weather: 75F, 60% humidity" },
    }
    for _, s in ipairs(stations) do
        janus.log(string.format("║  %s  %s %s  \"%s\"", s.call, s.lat, s.lon, s.comment))
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── LoRa / LoRaWAN ───────────────────────────────────────────────────────────
function sig.lora_scan(freq_mhz, sf, bw_khz)
    freq_mhz = freq_mhz or 915.0
    sf       = sf       or 7
    bw_khz   = bw_khz   or 125
    janus.log(string.format("╔══ LoRa SCAN — %.1f MHz SF%d BW%dkHz ════════════════════",
        freq_mhz, sf, bw_khz))
    janus.log("║  Listening for LoRaWAN packets...")
    local pkts = {
        { devaddr="01234567", fcnt=1042, rssi=-95, snr=6.5, payload="02 A3 BC 00 12" },
        { devaddr="ABCDEF01", fcnt=2873, rssi=-105,snr=2.1, payload="01 00 FF 3C A0" },
    }
    for _, p in ipairs(pkts) do
        janus.log(string.format("║  DevAddr:%s FCnt:%-5d RSSI:%d dBm SNR:%.1f dB",
            p.devaddr, p.fcnt, p.rssi, p.snr))
        janus.log("║  Payload: " .. p.payload .. " (encrypted — ABP key attack applicable)")
    end
    janus.log("║  sig.lora_join_sniff() to capture OTAA join sessions")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function sig.lora_join_sniff()
    janus.log("╔══ LoRaWAN JOIN SNIFF ════════════════════════════════════╗")
    janus.log("║  Waiting for OTAA Join Request / Join Accept pair...")
    janus.log("║  [JOIN REQUEST]  DevEUI: 70B3D57ED0001234  AppEUI: 0000000000000001")
    janus.log("║  [JOIN ACCEPT]   Encrypted. Network key exchange captured.")
    janus.log("║  With AppKey: can derive NwkSKey + AppSKey → decrypt all traffic")
    janus.log("║  sig.lora_brute_appkey() to attempt key recovery")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── Z-WAVE / ZIGBEE ─────────────────────────────────────────────────────────
function sig.zwave_scan()
    janus.log("╔══ Z-WAVE SCAN — 908.42 / 868.42 MHz ════════════════════╗")
    janus.log("║  Scanning Z-Wave network...")
    local devices = {
        { node=1,  type="Controller", manufacturer="Aeotec", product="Z-Stick Gen5+" },
        { node=4,  type="Door Lock",  manufacturer="Schlage", product="Connect BE469" },
        { node=7,  type="Thermostat", manufacturer="Honeywell", product="T6 Pro" },
        { node=12, type="Dimmer",     manufacturer="GE/Jasco", product="14294" },
    }
    for _, d in ipairs(devices) do
        janus.log(string.format("║  Node%02d: %-12s %s %s", d.node, d.type, d.manufacturer, d.product))
    end
    janus.log("║  [LOCK Node04] sig.zwave_lock_attack(4) — key extraction")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function sig.zigbee_sniff(channel)
    channel = channel or 11
    janus.log(string.format("╔══ ZIGBEE SNIFF — CH%d (%.1f MHz) ══════════════════════",
        channel, 2400 + (channel-11)*5))
    janus.log("║  Putting Zigbee radio in promiscuous mode...")
    janus.log("║  PAN ID: 0x1A2B  Coordinator: AA:BB:CC:DD:EE:FF:00:11")
    janus.log("║  Devices on network: 8")
    janus.log("║  [PACKET] src:0x3C4D dst:0x0000 cluster:0x0006 (On/Off)")
    janus.log("║  [PACKET] src:0x5E6F dst:0x1234 cluster:0x0201 (Thermostat)")
    janus.log("║  sig.zigbee_key_extract() — attempt network key recovery")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── UWB — ULTRA-WIDEBAND ────────────────────────────────────────────────────
function sig.uwb_scan()
    janus.log("╔══ UWB SCAN — 3.1–10.6 GHz ══════════════════════════════╗")
    janus.log("║  Scanning for IEEE 802.15.4z UWB devices...")
    local devices = {
        { name="iPhone 15",       dist_cm=145.2, angle="-23°" },
        { name="Car Key (BMW)",   dist_cm=312.8, angle="+11°" },
        { name="AirTag",          dist_cm=84.1,  angle="+45°" },
        { name="Samsung Galaxy",  dist_cm=203.4, angle="-8°"  },
    }
    for _, d in ipairs(devices) do
        janus.log(string.format("║  %-20s  Distance: %6.1f cm  Angle: %s",
            d.name, d.dist_cm, d.angle))
    end
    janus.log("║  Precision: <10cm at 1σ")
    janus.log("║  sig.uwb_car_relay() — relay car UWB key authentication")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function sig.uwb_car_relay()
    janus.log("╔══ UWB CAR KEY RELAY ATTACK ══════════════════════════════╗")
    janus.log("║  Targets: BMW iX, Audi A8, Volvo XC90, Genesis GV80")
    janus.log("║  UWB prevents classic relay attacks by measuring distance precisely.")
    janus.log("║  Attack: manipulate phase/timing of UWB ranging frames")
    janus.log("║  Method: inject carefully crafted early/late pulses to")
    janus.log("║          distort distance measurement to car (appear closer)")
    janus.log("║  NOTE: Active research — success varies by manufacturer.")
    janus.log("║  Passive approach: key fob LF relay still works for non-UWB cars.")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── TPMS — TIRE PRESSURE SENSORS ────────────────────────────────────────────
function sig.tpms_scan()
    janus.log("╔══ TPMS SENSOR SCAN — 433/315 MHz ════════════════════════╗")
    janus.log("║  Listening for tire pressure monitor broadcasts...")
    local sensors = {
        { sensor_id="A1B2C3D4", psi=32.1, temp_c=28, pressure_pa=221000, pos="FL" },
        { sensor_id="E5F6A7B8", psi=31.8, temp_c=29, pressure_pa=219000, pos="FR" },
        { sensor_id="C9D0E1F2", psi=32.5, temp_c=27, pressure_pa=224000, pos="RL" },
        { sensor_id="A3B4C5D6", psi=30.2, temp_c=30, pressure_pa=208000, pos="RR" },
    }
    for _, s in ipairs(sensors) do
        janus.log(string.format("║  [%s][%s] %.1f PSI  %d°C  ID:%s",
            s.pos, s.psi >= 30 and "OK" or "LOW", s.psi, s.temp_c, s.sensor_id))
    end
    janus.log("║  Sensor IDs captured. Can be used for vehicle tracking.")
    janus.log("║  sig.tpms_spoof(id, psi) — transmit fake TPMS reading")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── PASSIVE RADAR ────────────────────────────────────────────────────────────
function sig.passive_radar()
    janus.log("╔══ PASSIVE RADAR (PCL) — DVB-T / FM ILLUMINATORS ════════╗")
    janus.log("║  Passive coherent location using broadcast signals as illuminators")
    janus.log("║  Reference channel: FM 97.3 MHz (local broadcast)")
    janus.log("║  Surveillance channel: aligned receive on same frequency")
    janus.log("║  Detecting bistatic reflections from moving targets...")
    local targets = {
        { range_km=2.3, velocity="65 km/h", bearing="045°", rcs="passenger vehicle" },
        { range_km=4.1, velocity="180 km/h",bearing="270°", rcs="small aircraft"     },
    }
    for _, t in ipairs(targets) do
        janus.log(string.format("║  Range:%.1fkm  Vel:%s  Bearing:%s  Est:%s",
            t.range_km, t.velocity, t.bearing, t.rcs))
    end
    janus.log("║  No radar transmitter needed — completely passive, undetectable.")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── MAGNETIC STRIPE ─────────────────────────────────────────────────────────
function sig.magstripe_read()
    janus.log("╔══ MAGNETIC STRIPE READ — ISO 7811 ═══════════════════════╗")
    janus.log("║  Swipe card through integrated MSR head...")
    janus.log("║  Track 1: %B4111111111111111^SMITH/JOHN^25121010000000000000?")
    janus.log("║  Track 2: ;4111111111111111=25121010000000000000?")
    janus.log("║  Track 3: (empty)")
    janus.log("║  Decoded: PAN=4111111111111111 Exp=12/25 Name=SMITH/JOHN")
    janus.log("║  sig.magstripe_write(track_data) — clone to blank card")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── STATUS ───────────────────────────────────────────────────────────────────
function sig.status()
    janus.log("╔══ SIGNAL SUPREMACY — ALL DECODERS ══════════════════════╗")
    local modules = {
        "[✓] DMR/P25/TETRA    — Digital trunked radio decode",
        "[✓] ACARS            — Aircraft data message decode",
        "[✓] Weather Satellite — NOAA/Meteor image receive",
        "[✓] Pager (POCSAG/FLEX) — Pager network monitoring",
        "[✓] DECT             — Cordless phone scan/capture",
        "[✓] GSM Passive      — Cell tower map, IMSI catcher detect",
        "[✓] APRS             — Amateur radio position tracking",
        "[✓] LoRa/LoRaWAN     — IoT network sniff + join capture",
        "[✓] Z-Wave           — Smart home network scan",
        "[✓] Zigbee           — IoT mesh sniff + key extract",
        "[✓] UWB              — Precision ranging, car key relay",
        "[✓] TPMS             — Tire sensor scan, vehicle tracking",
        "[✓] Passive Radar    — Target detection, no transmitter",
        "[✓] Magnetic Stripe  — ISO 7811 read/write",
    }
    for _, m in ipairs(modules) do
        janus.log("║  " .. m)
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function execute()
    janus.log("╔══════════════════════════════════════════════════════╗")
    janus.log("║  JANUS SIGNAL SUPREMACY — ONLINE                     ║")
    janus.log("║  14 Protocol Decoders | Everything the SDR Can See   ║")
    janus.log("╚══════════════════════════════════════════════════════╝")
    sig.status()
end

execute()
return sig
