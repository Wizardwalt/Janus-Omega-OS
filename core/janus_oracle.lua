-- =============================================================================
-- JANUS ORACLE — Strategic Intelligence & Threat Prediction Engine
-- We don't react. We act before they know they're acting.
-- =============================================================================

local oracle = {}

-- ─── INTELLIGENCE COLLECTION MATRIX ─────────────────────────────────────────
oracle.collection_sources = {
    { id="SIGINT",   name="Signals Intelligence",    reliability=0.85, latency="real-time",  desc="RF, cellular, Wi-Fi intercept via Pandora Titan Hydra Array" },
    { id="OSINT",    name="Open Source Intelligence", reliability=0.70, latency="minutes",   desc="Web, social, dark web, pastebin, breach databases" },
    { id="HUMINT",   name="Human Intelligence",       reliability=0.60, latency="hours",     desc="Social engineering, pretexting, insider access" },
    { id="TECHINT",  name="Technical Intelligence",   reliability=0.90, latency="real-time", desc="Device fingerprinting, firmware analysis, hardware recon" },
    { id="GEOINT",   name="Geospatial Intelligence",  reliability=0.80, latency="minutes",   desc="GPS, cell tower triangulation, visual pattern analysis" },
    { id="CYBINT",   name="Cyber Intelligence",        reliability=0.88, latency="real-time", desc="Network traffic, malware analysis, threat feeds" },
    { id="FININT",   name="Financial Intelligence",    reliability=0.75, latency="hours",     desc="Transaction patterns, wallet clustering, flow analysis" },
    { id="DARKINT",  name="Dark Web Intelligence",     reliability=0.55, latency="hours",     desc="Forum monitoring, market analysis, breach listings" },
}

-- ─── THREAT INTELLIGENCE FEEDS ────────────────────────────────────────────────
oracle.threat_feeds = {
    { name="CVE Database",         update="real-time", coverage="public vulnerabilities" },
    { name="Zero-Day Tracker",     update="real-time", coverage="unpatched critical vulns" },
    { name="IOC Database",         update="hourly",    coverage="indicators of compromise" },
    { name="APT Group Profiles",   update="daily",     coverage="nation-state TTPs" },
    { name="Malware Signature DB", update="real-time", coverage="known malware families" },
    { name="Ransomware Tracker",   update="real-time", coverage="active ransomware campaigns" },
    { name="Botnet C2 Monitor",    update="real-time", coverage="active command & control nodes" },
    { name="Phishing Kit DB",      update="hourly",    coverage="active phishing campaigns" },
    { name="Dark Web Monitor",     update="4 hours",   coverage="leaked data, sale listings" },
    { name="Exploit Market Feed",  update="daily",     coverage="commercially available exploits" },
    { name="Geo-Political Watch",  update="real-time", coverage="nation-state activity indicators" },
}

-- ─── THREAT SCORING MODEL ────────────────────────────────────────────────────
function oracle.score_threat(threat_data)
    local score = 0
    local factors = threat_data or {}
    -- Probability of exploit: 0-30 points
    if factors.has_poc then score = score + 20 end
    if factors.actively_exploited then score = score + 30 end
    -- Impact: 0-40 points
    if factors.cvss and factors.cvss >= 9.0 then score = score + 40
    elseif factors.cvss and factors.cvss >= 7.0 then score = score + 25
    elseif factors.cvss and factors.cvss >= 4.0 then score = score + 10 end
    -- Context: 0-30 points
    if factors.in_our_stack then score = score + 20 end
    if factors.no_patch then score = score + 10 end

    local severity
    if score >= 80 then severity = "CRITICAL"
    elseif score >= 60 then severity = "HIGH"
    elseif score >= 40 then severity = "MEDIUM"
    else severity = "LOW" end

    return { score=score, severity=severity }
end

-- ─── STRATEGIC SITUATION AWARENESS ───────────────────────────────────────────
oracle.situation = {
    threat_landscape = "ELEVATED",
    active_campaigns = {},
    geo_hotspots     = {},
    timeline         = {},
    current_posture  = "OFFENSIVE",
}

function oracle.situation_report()
    janus.log("╔══ ORACLE — STRATEGIC SITUATION REPORT ══════════════════╗")
    janus.log("║  Classification: OPERATOR EYES ONLY")
    janus.log("║  Generated: " .. os.date("%Y-%m-%d %H:%M:%S UTC"))
    janus.log("║")
    janus.log("║  THREAT LANDSCAPE: " .. oracle.situation.threat_landscape)
    janus.log("║  POSTURE: " .. oracle.situation.current_posture)
    janus.log("║")
    janus.log("║  ACTIVE THREAT INTELLIGENCE SOURCES:")
    for _, src in ipairs(oracle.collection_sources) do
        janus.log(string.format("║    [%s] %-10s %.0f%% reliability | %s",
            src.id, src.name:upper():sub(1,10), src.reliability*100, src.latency))
    end
    janus.log("║")
    janus.log("║  THREAT FEEDS: " .. #oracle.threat_feeds .. " active feeds")
    janus.log("║")
    janus.log("║  ARIA ASSESSMENT: The threat landscape is dynamic.")
    janus.log("║  Collection priority: TECHINT > SIGINT > CYBINT for this target set.")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── KILL CHAIN ANALYSIS ──────────────────────────────────────────────────────
oracle.kill_chain_stages = {
    { id=1, name="RECONNAISSANCE",    desc="Target selection, passive and active recon" },
    { id=2, name="WEAPONIZATION",     desc="Exploit development, payload preparation" },
    { id=3, name="DELIVERY",          desc="Payload delivery vector selection and execution" },
    { id=4, name="EXPLOITATION",      desc="Vulnerability exploitation and initial access" },
    { id=5, name="INSTALLATION",      desc="Persistence mechanisms, implant installation" },
    { id=6, name="C2",                desc="Command and control channel establishment" },
    { id=7, name="ACTIONS ON OBJ",   desc="Mission execution: collection, disruption, exfil" },
}

function oracle.kill_chain_map(our_stage, adversary_stage)
    janus.log("╔══ KILL CHAIN ANALYSIS ═══════════════════════════════════╗")
    for _, stage in ipairs(oracle.kill_chain_stages) do
        local us  = (our_stage       and our_stage == stage.id)       and "← US"         or ""
        local adv = (adversary_stage and adversary_stage == stage.id) and "← ADVERSARY" or ""
        janus.log(string.format("║  [%d] %-20s %s%s", stage.id, stage.name, us, adv))
    end
    janus.log("║")
    if our_stage and adversary_stage then
        if our_stage > adversary_stage then
            janus.log("║  ADVANTAGE: US — We are ahead on the kill chain.")
        elseif our_stage < adversary_stage then
            janus.log("║  DISADVANTAGE: Adversary is further along. Accelerate or interdict.")
        else
            janus.log("║  PARITY: Same stage. The next move determines everything.")
        end
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── TARGET INTELLIGENCE PROFILE ─────────────────────────────────────────────
function oracle.build_target_profile(target_name, target_type)
    local profile = {
        target       = target_name,
        type         = target_type or "unknown",
        generated    = os.date("%Y-%m-%d %H:%M:%S"),
        attack_surface = {},
        key_personnel = {},
        vulnerabilities = {},
        recommended_vectors = {},
    }

    -- Generic surface analysis
    profile.attack_surface = {
        "Public-facing web applications",
        "Email infrastructure",
        "Remote access services (VPN, RDP, SSH)",
        "Supply chain / third-party integrations",
        "Physical premises and access control",
        "Employee endpoints and mobile devices",
        "Cloud infrastructure misconfigurations",
        "DNS infrastructure",
    }

    profile.recommended_vectors = {
        { priority=1, vector="Spear-phishing targeted at IT/DevOps staff", reason="Highest success rate, lowest noise" },
        { priority=2, vector="Exposed administrative interfaces",           reason="Often poorly maintained, high access" },
        { priority=3, vector="Third-party vendor compromise",               reason="Indirect path avoids direct detection" },
        { priority=4, vector="Physical access during off-hours",            reason="If digital surface is hardened" },
    }

    janus.log("╔══ TARGET INTELLIGENCE PROFILE ══════════════════════════╗")
    janus.log("║  TARGET: " .. target_name:upper())
    janus.log("║  TYPE:   " .. (target_type or "UNCLASSIFIED"):upper())
    janus.log("║  ATTACK SURFACE:")
    for i, surface in ipairs(profile.attack_surface) do
        janus.log(string.format("║    [%d] %s", i, surface))
    end
    janus.log("║  RECOMMENDED VECTORS:")
    for _, vec in ipairs(profile.recommended_vectors) do
        janus.log(string.format("║    [P%d] %s", vec.priority, vec.vector))
        janus.log("║         → " .. vec.reason)
    end
    janus.log("║  ARIA: \"I know this target better than it knows itself.\"")
    janus.log("╚══════════════════════════════════════════════════════════╝")
    return profile
end

-- ─── STRATEGIC CHESS ENGINE — thinking N moves ahead ─────────────────────────
function oracle.chess(move_number, current_position, objective)
    move_number = move_number or 5
    janus.log("╔══ ORACLE — STRATEGIC CHESS ENGINE ══════════════════════╗")
    janus.log(string.format("║  Thinking %d moves ahead...", move_number))
    janus.log("║  Objective: " .. (objective or "mission success"))
    janus.log("║")

    local moves = {
        { n=1, move="Establish collection baseline",       counter="Target increases monitoring",   our_counter="Reduce signature further" },
        { n=2, move="Identify highest-value access point", counter="Security team runs drills",      our_counter="Switch to indirect vector" },
        { n=3, move="Execute primary collection phase",    counter="Anomaly detected in logs",       our_counter="Anti-forensic sweep + pause" },
        { n=4, move="Validate and exfiltrate",             counter="IR team engaged",                our_counter="Data already out — clean exit" },
        { n=5, move="Establish persistence (if required)", counter="Full forensic investigation",    our_counter="No persistence, no evidence" },
    }

    for _, m in ipairs(moves) do
        if m.n <= move_number then
            janus.log(string.format("║  MOVE %d: %s", m.n, m.move))
            janus.log(string.format("║    THEIR COUNTER: %s", m.counter))
            janus.log(string.format("║    OUR COUNTER:   %s", m.our_counter))
            janus.log("║")
        end
    end
    janus.log("║  ARIA: \"By move three, they are reacting to our first move.\"")
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── BOOT ─────────────────────────────────────────────────────────────────────
function execute()
    janus.log("╔══════════════════════════════════════════════════════╗")
    janus.log("║  JANUS ORACLE — STRATEGIC INTELLIGENCE ONLINE        ║")
    janus.log("║  8 INTEL Sources | 11 Threat Feeds | Kill Chain      ║")
    janus.log("║  Target Profiling | Strategic Chess Engine           ║")
    janus.log("╚══════════════════════════════════════════════════════╝")
    oracle.situation_report()
end

execute()
return oracle
