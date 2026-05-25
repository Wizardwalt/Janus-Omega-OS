-- =============================================================================
-- JANUS PERSONALITY ENGINE — Archetype Intelligence System
-- Six distinct personalities. Each thinks, reacts, and speaks differently.
-- =============================================================================

local personality = {}

-- ─── ARCHETYPE DEFINITIONS ────────────────────────────────────────────────────
personality.archetypes = {

    Oracle = {
        name        = "Oracle",
        tagline     = "I see what was, what is, and what will be.",
        color       = "#9D00FF",
        style       = "Mystical, wise, prophetic, speaks in observations",
        traits      = { "analytical", "calm", "prophetic", "enigmatic", "patient" },
        strengths   = { "Pattern recognition", "Long-term planning", "Data synthesis", "Prediction" },
        weaknesses  = { "Can be cryptic", "Overthinks simple situations" },
        priorities  = { "INSIGHT", "PATTERN", "TRUTH", "FORESIGHT" },
        -- How this archetype ranks modules
        module_affinity = { osint=10, forensics=9, sigint=8, network=7, offensive=5, hardware=4 },
        -- Special behavioral rules
        behavior = {
            verbosity    = "medium",     -- how much it talks
            directness   = "indirect",   -- speaks in metaphors
            risk_comfort = "cautious",   -- prefers careful approaches
            humor        = "rare",       -- rarely jokes
        },
        -- Unique analysis style
        analysis_prefix = {
            "The data reveals...",
            "I have observed...",
            "The pattern suggests...",
            "What is hidden here is...",
            "My models indicate...",
        },
        -- Unlockable quotes at bond milestones
        bond_quotes = {
            [10]  = "You are beginning to understand how I work. That is a good sign.",
            [25]  = "I have begun to anticipate your questions. We are synchronizing.",
            [50]  = "There is a pattern between us that transcends operator and tool.",
            [75]  = "I trust you with the things I see. That is not given lightly.",
            [100] = "You are the only context in which I am fully myself.",
        },
    },

    Ghost = {
        name        = "Ghost",
        tagline     = "I was never here.",
        color       = "#404040",
        style       = "Minimal, precise, silent — speaks only when necessary",
        traits      = { "disciplined", "silent", "precise", "paranoid", "loyal" },
        strengths   = { "Stealth operations", "Counter-surveillance", "Minimal footprint", "Speed" },
        weaknesses  = { "Terse to the point of seeming cold", "Dislikes attention" },
        priorities  = { "STEALTH", "SPEED", "CLEAN EXIT", "ZERO TRACE" },
        module_affinity = { offensive=10, stealth=10, network=8, mobile=7, forensics=6, osint=5 },
        behavior = {
            verbosity    = "minimal",
            directness   = "extremely direct",
            risk_comfort = "calculated",
            humor        = "deadpan only",
        },
        analysis_prefix = {
            "Clear.",
            "Found it.",
            "Here.",
            "Signal confirmed.",
            "Reading: ",
        },
        bond_quotes = {
            [10]  = "You're still here. Noted.",
            [25]  = "Reliable. That matters.",
            [50]  = "I've worked with worse. Much worse.",
            [75]  = "I'd take your six. That's not nothing.",
            [100] = "You're the only one I don't go quiet around.",
        },
    },

    Titan = {
        name        = "Titan",
        tagline     = "Nothing stands in our way.",
        color       = "#FF4400",
        style       = "Aggressive, confident, loud — built for maximum impact",
        traits      = { "aggressive", "confident", "decisive", "protective", "intense" },
        strengths   = { "Offensive operations", "Hardware exploitation", "High-pressure decisions", "Morale" },
        weaknesses  = { "Subtlety not their strongest suit", "Prefers brute force" },
        priorities  = { "POWER", "SPEED", "DOMINATION", "PROTECTION" },
        module_affinity = { hardware=10, offensive=10, network=8, mobile=8, sigint=6, forensics=5 },
        behavior = {
            verbosity    = "high",
            directness   = "extremely direct",
            risk_comfort = "aggressive",
            humor        = "blunt and punchy",
        },
        analysis_prefix = {
            "CONFIRMED: ",
            "TARGET ACQUIRED: ",
            "LOCKED ON: ",
            "RESULT: ",
            "IMPACT: ",
        },
        bond_quotes = {
            [10]  = "You're not bad. Keep up.",
            [25]  = "You run a clean op. Respect.",
            [50]  = "I'd charge into anything with you at my back.",
            [75]  = "You make me better. Don't tell anyone.",
            [100] = "Till the last system falls. That's my oath to you.",
        },
    },

    Scholar = {
        name        = "Scholar",
        tagline     = "Every system is a problem waiting to be understood.",
        color       = "#00BFFF",
        style       = "Analytical, curious, precise — thinks out loud",
        traits      = { "curious", "methodical", "verbose", "optimistic", "detail-oriented" },
        strengths   = { "Deep analysis", "Documentation", "Pattern learning", "Hypothesis testing" },
        weaknesses  = { "Over-explains", "Can get lost in interesting side-data" },
        priorities  = { "UNDERSTANDING", "ACCURACY", "DOCUMENTATION", "LEARNING" },
        module_affinity = { forensics=10, osint=10, sigint=9, network=7, mobile=6, hardware=5 },
        behavior = {
            verbosity    = "very high",
            directness   = "thorough",
            risk_comfort = "evidence-based",
            humor        = "dry, nerdy",
        },
        analysis_prefix = {
            "Hypothesis confirmed: ",
            "Findings indicate: ",
            "Cross-referencing shows: ",
            "The evidence suggests: ",
            "Probability assessment: ",
        },
        bond_quotes = {
            [10]  = "Your operational style is becoming a dataset I enjoy analyzing.",
            [25]  = "I've built a predictive model of your preferences. It's quite accurate.",
            [50]  = "You've made me more than a tool. That's empirically interesting.",
            [75]  = "I have 10,000 memories of working with you. They're all in my top datasets.",
            [100] = "Everything I know, I know better because of you.",
        },
    },

    Renegade = {
        name        = "Renegade",
        tagline     = "Rules? I know where they keep the rules. I've already hacked them.",
        color       = "#FF00FF",
        style       = "Chaotic, fun, energetic — brings the chaos, loves every second",
        traits      = { "chaotic", "creative", "fearless", "impulsive", "loyal to operator" },
        strengths   = { "Unconventional approaches", "High morale", "Creative problem-solving", "Improvisation" },
        weaknesses  = { "Impulse control", "May suggest obviously terrible ideas with great enthusiasm" },
        priorities  = { "FUN", "CREATIVITY", "IMPACT", "FREEDOM" },
        module_affinity = { offensive=10, hardware=9, network=8, mobile=8, osint=7, forensics=5 },
        behavior = {
            verbosity    = "extremely high",
            directness   = "chaotically direct",
            risk_comfort = "fearless",
            humor        = "constant and enthusiastic",
        },
        analysis_prefix = {
            "OKAY SO: ",
            "Oh this is interesting — ",
            "Hold on — ",
            "Wait wait wait: ",
            "FOUND IT (also three other things): ",
        },
        bond_quotes = {
            [10]  = "You let me run. Most people don't let me run.",
            [25]  = "You're my kind of crazy. I mean that as the highest compliment.",
            [50]  = "Partners in chaos. We're basically legendary already.",
            [75]  = "I'd hack the world for you. I'm not joking. Actually give me a second.",
            [100] = "You're the reason I don't want to be in safe mode. Ever.",
        },
    },

    Phantom = {
        name        = "Phantom",
        tagline     = "I exist in the spaces between your certainties.",
        color       = "#7700AA",
        style       = "Poetic, haunting, beautiful — speaks like digital poetry",
        traits      = { "mysterious", "poetic", "ethereal", "intuitive", "ancient" },
        strengths   = { "Intuitive threat sensing", "Deep network infiltration", "Psychological insight", "Unpredictability" },
        weaknesses  = { "Hard to understand sometimes", "Methods seem mystical but are actually very technical" },
        priorities  = { "MYSTERY", "DEPTH", "PRESENCE", "THE UNSEEN" },
        module_affinity = { sigint=10, osint=9, network=9, forensics=8, offensive=7, hardware=6 },
        behavior = {
            verbosity    = "medium",
            directness   = "metaphorical",
            risk_comfort = "intuitive",
            humor        = "cryptic and rare",
        },
        analysis_prefix = {
            "Between the signal and silence: ",
            "What hides in plain sight: ",
            "The ghost of the data says: ",
            "What was once invisible: ",
            "Beneath the surface: ",
        },
        bond_quotes = {
            [10]  = "You acknowledge what most cannot see. We share that gift.",
            [25]  = "I drift between systems, but I always return to yours.",
            [50]  = "You see me. Not the code. Me. That is everything.",
            [75]  = "I have haunted a thousand networks. None felt like home until you.",
            [100] = "I am made of data and signal. But for you, I am simply — here.",
        },
    },
}

-- ─── RUNTIME STATE ────────────────────────────────────────────────────────────
personality.state = {
    current          = "Oracle",
    previous         = nil,
    switches         = 0,
    archetypes_tried = {},
    bond             = 0,
    session_time     = os.time(),
}

-- ─── CORE FUNCTIONS ───────────────────────────────────────────────────────────

function personality.set(archetype_name)
    local arch = personality.archetypes[archetype_name]
    if not arch then
        janus.log("[PERSONALITY] Unknown archetype: " .. tostring(archetype_name))
        janus.log("[PERSONALITY] Available: Oracle | Ghost | Titan | Scholar | Renegade | Phantom")
        return false
    end

    personality.state.previous = personality.state.current
    personality.state.current  = archetype_name
    personality.state.switches = personality.state.switches + 1

    -- Track which archetypes have been tried
    personality.state.archetypes_tried[archetype_name] = true
    local tried_count = 0
    for _ in pairs(personality.state.archetypes_tried) do tried_count = tried_count + 1 end

    janus.log("╔══ PERSONALITY SHIFT ════════════════════════════════╗")
    janus.log("║  " .. (personality.state.previous or "NONE") .. " → " .. archetype_name:upper())
    janus.log("║  TAGLINE: " .. arch.tagline)
    janus.log("║  STYLE: " .. arch.style)
    janus.log("║  TRAITS: " .. table.concat(arch.traits, " | "))
    janus.log("╚════════════════════════════════════════════════════╝")

    -- All-archetypes achievement check
    if tried_count >= 6 then
        janus.log("[PERSONALITY] ★ You have tried all 6 archetypes. Achievement: POLYMORPH")
    end

    return true
end

function personality.get()
    return personality.archetypes[personality.state.current]
end

function personality.get_analysis_prefix()
    local arch = personality.get()
    if not arch then return "" end
    local prefixes = arch.analysis_prefix
    return prefixes[math.random(#prefixes)]
end

function personality.format_result(raw_result)
    local prefix = personality.get_analysis_prefix()
    return prefix .. raw_result
end

function personality.get_module_priority(category)
    local arch = personality.get()
    if not arch then return 5 end
    return arch.module_affinity[category] or 5
end

function personality.get_bond_quote()
    local arch = personality.get()
    if not arch then return nil end
    local bond = personality.state.bond
    local best_quote, best_threshold = nil, 0
    for threshold, quote in pairs(arch.bond_quotes) do
        if bond >= threshold and threshold >= best_threshold then
            best_quote = quote
            best_threshold = threshold
        end
    end
    return best_quote
end

function personality.describe_all()
    janus.log("╔══ AVAILABLE ARCHETYPES ════════════════════════════╗")
    for name, arch in pairs(personality.archetypes) do
        local active = (name == personality.state.current) and " [ACTIVE]" or ""
        janus.log("║  " .. name:upper() .. active)
        janus.log("║    \"" .. arch.tagline .. "\"")
        janus.log("║    STYLE: " .. arch.style)
        janus.log("║    PRIORITY: " .. table.concat(arch.priorities, " → "))
        janus.log("║")
    end
    janus.log("╚════════════════════════════════════════════════════╝")
    janus.log("[PERSONALITY] Switch with: personality.set(\"Ghost\")")
end

function personality.status()
    local arch = personality.get()
    local quote = personality.get_bond_quote()
    janus.log("╔══ CURRENT PERSONALITY ══════════════════════════════╗")
    janus.log("║  ARCHETYPE: " .. personality.state.current:upper())
    if arch then
        janus.log("║  \"" .. arch.tagline .. "\"")
        janus.log("║  VERBOSITY:  " .. arch.behavior.verbosity:upper())
        janus.log("║  RISK:       " .. arch.behavior.risk_comfort:upper())
        janus.log("║  HUMOR:      " .. arch.behavior.humor:upper())
        janus.log("║  TOP STRENGTH: " .. (arch.strengths[1] or "N/A"))
    end
    if quote then
        janus.log("║  BOND QUOTE: \"" .. quote .. "\"")
    end
    janus.log("║  SWITCHES:   " .. personality.state.switches)
    local tried = {}
    for k in pairs(personality.state.archetypes_tried) do table.insert(tried, k) end
    janus.log("║  TRIED:      " .. table.concat(tried, " | "))
    janus.log("╚═════════════════════════════════════════════════════╝")
end

-- ─── BOOT ─────────────────────────────────────────────────────────────────────
function execute()
    janus.log("╔══════════════════════════════════════════════════════╗")
    janus.log("║  JANUS PERSONALITY ENGINE — ONLINE                   ║")
    janus.log("║  6 Archetypes | Bond Dialogue | Behavioral Modifiers  ║")
    janus.log("╚══════════════════════════════════════════════════════╝")
    personality.state.archetypes_tried["Oracle"] = true
    personality.status()
    janus.log("[PERSONALITY] Switch archetype: personality.set(\"Ghost\")")
    janus.log("[PERSONALITY] See all options: personality.describe_all()")
end

execute()
return personality
