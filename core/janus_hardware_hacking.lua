-- =============================================================================
-- JANUS HARDWARE HACKING SUITE — Debug Interfaces, Fault Injection, CAN Bus
-- UART | SPI | I2C | JTAG | SWD | CAN | OBD-II | Power Glitch | Logic Analyzer
-- The Titan PCB is a professional embedded security lab. No adapters needed.
-- =============================================================================

local hw = {}

-- ─── UART INTERFACE ───────────────────────────────────────────────────────────
hw.uart = {
    bauds = { 300,1200,2400,4800,9600,19200,38400,57600,115200,230400,460800,921600,1000000,1500000,2000000 },
    auto_detected = nil,
}

function hw.uart_connect(baud, port)
    baud = baud or 115200
    port = port or "TITAN-UART0"
    janus.log(string.format("╔══ UART — %d baud ════════════════════════════════════", baud))
    janus.log("║  Connecting to serial console...")
    janus.log("║  [OK] Shell prompt detected:")
    janus.log("║  root@device:~# ")
    janus.log("║  [TIP] hw.uart_login_brute() for credential attacks")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function hw.uart_autobaud()
    janus.log("╔══ UART AUTO-BAUD DETECTION ══════════════════════════════╗")
    janus.log("║  Cycling through " .. #hw.uart.bauds .. " baud rates...")
    for _, b in ipairs(hw.uart.bauds) do
        local detected = (b == 115200)  -- simulated detection
        local status = detected and "[MATCH] Readable output" or "[----] Noise/garbage"
        janus.log(string.format("║  %7d baud — %s", b, status))
        if detected then
            hw.uart.auto_detected = b
            break
        end
    end
    if hw.uart.auto_detected then
        janus.log("║  BAUD RATE: " .. hw.uart.auto_detected)
        janus.log("║  Run hw.uart_connect(" .. hw.uart.auto_detected .. ") to open shell")
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function hw.uart_login_brute()
    local wordlist = { "root/root", "admin/admin", "admin/password", "root/toor",
                       "admin/1234", "user/user", "guest/guest", "root/(blank)" }
    janus.log("╔══ UART LOGIN BRUTE FORCE ════════════════════════════════╗")
    for _, cred in ipairs(wordlist) do
        local parts = {}
        for p in cred:gmatch("[^/]+") do table.insert(parts, p) end
        local success = (cred == "root/root")  -- simulated
        janus.log(string.format("║  [%s] user:%-8s pass:%s", success and "✓ HIT " or "× FAIL",
            parts[1] or "?", parts[2] or "(blank)"))
        if success then
            janus.log("║  ROOT SHELL OBTAINED")
            break
        end
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── SPI FLASH DUMP ───────────────────────────────────────────────────────────
hw.spi = {
    common_flash_chips = {
        { mfr="Winbond", part="W25Q64", size_mb=8,  desc="Common router/camera firmware" },
        { mfr="Winbond", part="W25Q128",size_mb=16, desc="Smart device firmware" },
        { mfr="Macronix", part="MX25L6406",size_mb=8,desc="Set-top box" },
        { mfr="GigaDevice",part="GD25Q64",size_mb=8, desc="IoT device firmware" },
        { mfr="Micron",   part="MT25Q256",size_mb=32,desc="Network device" },
    },
}

function hw.spi_id()
    local chip = hw.spi.common_flash_chips[math.random(#hw.spi.common_flash_chips)]
    janus.log("╔══ SPI CHIP ID ════════════════════════════════════════════╗")
    janus.log("║  JEDEC ID read...")
    janus.log(string.format("║  Manufacturer: %s  Part: %s  Size: %d MB",
        chip.mfr, chip.part, chip.size_mb))
    janus.log("║  Desc: " .. chip.desc)
    janus.log("║  Run hw.spi_dump() to extract full firmware.")
    janus.log("╚══════════════════════════════════════════════════════════╝")
    return chip
end

function hw.spi_dump(output_file)
    output_file = output_file or "/tmp/firmware_dump.bin"
    local chip = hw.spi.common_flash_chips[math.random(#hw.spi.common_flash_chips)]
    janus.log("╔══ SPI FLASH DUMP ════════════════════════════════════════╗")
    janus.log(string.format("║  Reading %d MB at ~4 Mbit/s...", chip.size_mb))
    janus.log(string.format("║  ETA: ~%d seconds", chip.size_mb * 2))
    janus.log("║  [████████████████████] 100%")
    janus.log("║  SHA256: " .. hw.fake_hash())
    janus.log("║  Saved: " .. output_file)
    janus.log("║  Run hw.firmware_analyze() for strings/secrets extraction.")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function hw.firmware_analyze()
    janus.log("╔══ FIRMWARE ANALYSIS ═════════════════════════════════════╗")
    janus.log("║  Extracting strings...")
    local findings = {
        "  [CRED]  admin:password123 (plaintext in config blob)",
        "  [CRED]  WIFI_PASS=SuperSecretWifi2023",
        "  [KEY]   AES-128 key: 0xDEADBEEFCAFEBABE0102030405060708",
        "  [URL]   http://update.device.internal/firmware",
        "  [CERT]  Self-signed cert (expires 2025-01-01)",
        "  [DBG]   Debug port enabled — telnet on :23",
        "  [VER]   Linux 3.10.14 (EOL — 47 known CVEs)",
    }
    for _, f in ipairs(findings) do
        janus.log("║" .. f)
    end
    janus.log("║  Filesystem: " .. ({"SquashFS","JFFS2","UBI","CRAMFS"})[math.random(4)])
    janus.log("║  Run binwalk analysis for full extraction.")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── JTAG / SWD DEBUG INTERFACE ───────────────────────────────────────────────
hw.jtag = {
    vendors = {
        { name="Nordic nRF52840",   idcode="0x2BA01477", desc="BT SoC — common in IoT" },
        { name="STM32F4",           idcode="0x2BA01477", desc="STMicro ARM Cortex-M4" },
        { name="ESP32",             idcode="0x120034E5", desc="Espressif Wi-Fi/BT SoC" },
        { name="NXP LPC55S69",      idcode="0x0BE12477", desc="ARM Cortex-M33 secure" },
        { name="Texas Instruments", idcode="0x0BB11477", desc="CC2652 IoT radio SoC" },
    },
}

function hw.jtag_scan()
    janus.log("╔══ JTAG BOUNDARY SCAN ════════════════════════════════════╗")
    janus.log("║  Applying TRST, probing TDO/TDI/TCK/TMS...")
    local dev = hw.jtag.vendors[math.random(#hw.jtag.vendors)]
    janus.log("║  [DEVICE FOUND]")
    janus.log("║  IDCODE: " .. dev.idcode)
    janus.log("║  Target: " .. dev.name)
    janus.log("║  Notes:  " .. dev.desc)
    janus.log("║  hw.jtag_dump_flash() — extract firmware")
    janus.log("║  hw.jtag_debug()      — attach GDB, set breakpoints, read RAM")
    janus.log("║  hw.jtag_bypass_rdp() — attempt readout protection bypass")
    janus.log("╚══════════════════════════════════════════════════════════╝")
    return dev
end

function hw.jtag_bypass_rdp()
    janus.log("╔══ READOUT PROTECTION BYPASS (JTAG + FAULT INJECT) ══════╗")
    janus.log("║  Method: Combined JTAG debug + voltage glitch on VCAP")
    janus.log("║  Step 1: Attach SWD, set watchpoint at flash read routine")
    janus.log("║  Step 2: Trigger voltage glitch at precise clock cycle")
    janus.log("║  Step 3: Glitch causes RDP level check to return 0 (unprotected)")
    janus.log("║  Attempting...")
    local success = math.random(100) <= 35   -- realistic ~35% first-pass rate
    if success then
        janus.log("║  [SUCCESS] RDP bypassed. Memory read protection disabled.")
        janus.log("║  Flash contents now accessible via JTAG.")
    else
        janus.log("║  [PARTIAL] Glitch parameters need tuning.")
        janus.log("║  Adjust: hw.fault_glitch_params.voltage_offset = -0.15")
        janus.log("║  Retry with hw.jtag_bypass_rdp()")
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── I2C BUS ──────────────────────────────────────────────────────────────────
function hw.i2c_scan()
    janus.log("╔══ I2C BUS SCAN ══════════════════════════════════════════╗")
    janus.log("║  Scanning 0x00 – 0x7F...")
    local common_devices = {
        { addr=0x20, desc="PCF8574 GPIO expander" },
        { addr=0x27, desc="PCF8574 LCD backpack" },
        { addr=0x3C, desc="SSD1306 OLED display" },
        { addr=0x48, desc="ADS1115 ADC" },
        { addr=0x50, desc="24C256 EEPROM (config/credentials storage)" },
        { addr=0x68, desc="DS3231 RTC / MPU6050 IMU" },
        { addr=0x76, desc="BMP280 pressure sensor" },
    }
    for _, dev in ipairs(common_devices) do
        if math.random(100) <= 60 then
            janus.log(string.format("║  [0x%02X] FOUND — %s", dev.addr, dev.desc))
        end
    end
    janus.log("║  hw.i2c_read(addr, reg, len) to read device registers")
    janus.log("║  hw.i2c_dump_eeprom(0x50)   to extract EEPROM contents")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function hw.i2c_dump_eeprom(addr)
    addr = addr or 0x50
    janus.log(string.format("[I2C] Dumping EEPROM at 0x%02X...", addr))
    janus.log("[I2C] Found: WiFi SSID, PSK, device serial, admin password hash")
    janus.log("[I2C] Saved to /tmp/eeprom_0x" .. string.format("%02X", addr) .. ".bin")
end

-- ─── CAN BUS / AUTOMOTIVE ────────────────────────────────────────────────────
hw.can = {
    common_pids = {
        { pid=0x010C, name="ENGINE_RPM",    formula="(A*256+B)/4", unit="RPM" },
        { pid=0x010D, name="VEHICLE_SPEED", formula="A",           unit="km/h" },
        { pid=0x0111, name="THROTTLE",      formula="A*100/255",   unit="%" },
        { pid=0x012F, name="FUEL_LEVEL",    formula="A*100/255",   unit="%" },
        { pid=0x0105, name="COOLANT_TEMP",  formula="A-40",        unit="°C" },
        { pid=0x0142, name="ECU_VOLTAGE",   formula="(A*256+B)/1000",unit="V" },
    },
}

function hw.can_sniff(duration_s)
    duration_s = duration_s or 10
    janus.log(string.format("╔══ CAN BUS SNIFFER — %ds ══════════════════════════════", duration_s))
    janus.log("║  Connected to CAN bus (500 kbps). Listening...")
    for i = 1, 8 do
        local can_id  = string.format("0x%03X", math.random(0x7FF))
        local dlc     = math.random(8)
        local data    = ""
        for j = 1, dlc do data = data .. string.format("%02X ", math.random(255)) end
        janus.log(string.format("║  [%s] DLC:%d DATA: %s", can_id, dlc, data:sub(1,-2)))
    end
    janus.log("║  hw.can_decode_obd() to interpret OBD-II PIDs")
    janus.log("║  hw.can_replay(frame) to inject specific frames")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function hw.can_decode_obd()
    janus.log("╔══ OBD-II PID DECODE ═════════════════════════════════════╗")
    for _, pid in ipairs(hw.can.common_pids) do
        local raw_a = math.random(255)
        local raw_b = math.random(255)
        -- Simplified value display
        janus.log(string.format("║  [0x%04X] %-16s Raw:%02X%02X  Formula: %s %s",
            pid.pid, pid.name, raw_a, raw_b, pid.formula, pid.unit))
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function hw.can_key_fob_relay()
    janus.log("╔══ KEY FOB RELAY ATTACK ═════════════════════════════════╗")
    janus.log("║  Mode: Two-device relay (Titan + remote Pandora Omega)")
    janus.log("║  Device 1 (near key): amplifying 125kHz LF field to key fob")
    janus.log("║  Device 2 (near car): relaying 315/433 MHz response to car")
    janus.log("║  Challenge-response relay over Ghost-Net mesh (5ms latency)")
    janus.log("║  Effective range extension: 0.5m → ~30m")
    janus.log("║  Compatible: Most passive keyless entry (PKE) systems")
    janus.log("║  [RELAY ACTIVE] Waiting for car to challenge...")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── FAULT INJECTION ──────────────────────────────────────────────────────────
hw.fault = {
    params = {
        voltage_nominal = 3.3,    -- target normal voltage (V)
        voltage_offset  = -0.35,  -- glitch drop (V)
        glitch_width_ns = 50,     -- pulse width (nanoseconds)
        glitch_delay_ns = 10000,  -- delay after trigger (nanoseconds)
        repeat_count    = 100,    -- attempts per run
    },
    modes = { "VOLTAGE_GLITCH", "CLOCK_GLITCH", "EM_FAULT_INJECT", "COMBINED" },
}

function hw.fault_voltage_glitch(target, params)
    local p = params or hw.fault.params
    janus.log("╔══ VOLTAGE FAULT INJECTION ═══════════════════════════════╗")
    janus.log("║  Target: " .. (target or "attached microcontroller"))
    janus.log(string.format("║  Nominal: %.2fV  |  Glitch drop: %.2fV  |  Width: %dns",
        p.voltage_nominal, math.abs(p.voltage_offset), p.glitch_width_ns))
    janus.log(string.format("║  Delay: %dns  |  Attempts: %d", p.glitch_delay_ns, p.repeat_count))
    janus.log("║  Executing glitch sequence...")
    for i = 1, math.min(p.repeat_count, 10) do
        local hit = (i == 7)   -- simulated success on attempt 7
        janus.log(string.format("║  [%03d] Glitch fired — %s", i,
            hit and "FAULT DETECTED — unexpected branch!" or "no effect"))
        if hit then
            janus.log("║  [SUCCESS] Target entered unexpected state.")
            janus.log("║  UART shows debug output: 'Boot ROM unlocked'")
            break
        end
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function hw.fault_em_inject(coil_distance_mm)
    coil_distance_mm = coil_distance_mm or 2
    janus.log("╔══ ELECTROMAGNETIC FAULT INJECTION (EMFI) ════════════════╗")
    janus.log(string.format("║  Coil distance: %dmm from target chip", coil_distance_mm))
    janus.log("║  Pulse: 400V at 2A for 50ns via custom EMFI coil")
    janus.log("║  Target area: CPU core / crypto accelerator")
    janus.log("║  Firing pulse sequence...")
    janus.log("║  [FAULT] Instruction skip detected — skipped CMP/JNE pair")
    janus.log("║  [RESULT] Secure boot signature check bypassed")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function hw.power_analysis(algorithm, traces)
    algorithm = algorithm or "AES-128"
    traces    = traces    or 1000
    janus.log("╔══ POWER ANALYSIS (DPA/CPA) ══════════════════════════════╗")
    janus.log("║  Algorithm: " .. algorithm)
    janus.log(string.format("║  Collecting %d power traces...", traces))
    janus.log("║  [████████████████████] Capture complete")
    janus.log("║  Running Correlation Power Analysis (CPA)...")
    janus.log("║  Key hypothesis scoring across all 256 candidates per byte...")
    janus.log("║  [KEY BYTE 0]  0xDE — correlation 0.94")
    janus.log("║  [KEY BYTE 1]  0xAD — correlation 0.91")
    janus.log("║  ... (16 bytes recovered)")
    janus.log("║  RECOVERED KEY: DE AD BE EF CA FE BA BE 01 02 03 04 05 06 07 08")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── LOGIC ANALYZER ───────────────────────────────────────────────────────────
function hw.logic_capture(channels, rate_mhz, duration_ms)
    channels   = channels   or 8
    rate_mhz   = rate_mhz   or 100
    duration_ms= duration_ms or 100
    janus.log(string.format("╔══ LOGIC ANALYZER — %dch @ %d MHz ═══════════════════════",
        channels, rate_mhz))
    janus.log(string.format("║  Duration: %dms  |  Samples: %dk", duration_ms, rate_mhz*duration_ms))
    janus.log("║  Capturing...")
    local protos = { "UART 115200 8N1", "SPI CPOL0 CPHA0 4MHz", "I2C 100kHz", "CAN 500kbps" }
    for i = 1, math.min(channels, 4) do
        janus.log(string.format("║  CH%d: %s detected — decoding...", i-1, protos[i]))
    end
    janus.log("║  Decoded data saved. View on Titan display or export.")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── ACOUSTIC SIDE-CHANNEL ────────────────────────────────────────────────────
function hw.acoustic_keyboard()
    janus.log("╔══ KEYBOARD ACOUSTIC SIDE-CHANNEL ════════════════════════╗")
    janus.log("║  Recording keystrokes via 4-mic beamforming array...")
    janus.log("║  Training classifier on key sound profiles...")
    janus.log("║  Attack mode: character-level acoustic classification")
    janus.log("║  Accuracy achievable: 90–96% per keystroke at 1m range")
    janus.log("║  [RECOVERING] Typed sequence from audio:")
    local fake_recovered = "p@ssw0rd123"
    janus.log("║  CANDIDATE: " .. fake_recovered)
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function hw.acoustic_safe_crack()
    janus.log("╔══ MECHANICAL SAFE ACOUSTIC FEEDBACK ════════════════════╗")
    janus.log("║  Microphone array placed against safe door")
    janus.log("║  Detecting disc set clicks via contact microphone...")
    janus.log("║  Method: audio-guided manipulation (no stethoscope needed)")
    janus.log("║  Rotation speed: 0.25°/step  |  Sampling: 48kHz")
    janus.log("║  Disc 1: set at [42] — click detected")
    janus.log("║  Disc 2: set at [17] — click detected")
    janus.log("║  Disc 3: set at [33] — click detected")
    janus.log("║  Combination candidate: 42-17-33")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── UTILITY ──────────────────────────────────────────────────────────────────
function hw.fake_hash()
    local h = ""
    for i = 1, 64 do
        h = h .. string.format("%x", math.random(16)-1)
    end
    return h
end

function hw.status()
    janus.log("╔══ HARDWARE HACKING SUITE — ALL MODULES ═════════════════╗")
    janus.log("║  [✓] UART  — autobaud, shell access, brute force")
    janus.log("║  [✓] SPI   — flash ID/dump, firmware extraction")
    janus.log("║  [✓] I2C   — bus scan, EEPROM dump, register access")
    janus.log("║  [✓] JTAG/SWD — boundary scan, debug, RDP bypass")
    janus.log("║  [✓] CAN bus — sniff, OBD-II decode, frame injection")
    janus.log("║  [✓] Key Fob Relay — PKE relay attack over Ghost-Net")
    janus.log("║  [✓] Voltage Glitch — <10ns, FPGA-timed")
    janus.log("║  [✓] EM Fault Inject — custom coil, 400V pulse")
    janus.log("║  [✓] Power Analysis — DPA/CPA crypto key extraction")
    janus.log("║  [✓] Logic Analyzer — 16ch 500MHz, protocol decode")
    janus.log("║  [✓] Acoustic KB   — keystroke recovery from sound")
    janus.log("║  [✓] Acoustic Safe — mechanical safe dial feedback")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

function execute()
    janus.log("╔══════════════════════════════════════════════════════╗")
    janus.log("║  JANUS HARDWARE HACKING SUITE — ONLINE               ║")
    janus.log("║  UART|SPI|I2C|JTAG|SWD|CAN|Glitch|EMFI|Logic|Sound  ║")
    janus.log("╚══════════════════════════════════════════════════════╝")
    hw.status()
end

execute()
return hw
