-- =============================================================================
-- JANUS AVATAR SYSTEM — Fully Customizable AI Companion
-- The soul of JanusOS. Your partner in every operation.
-- =============================================================================

local avatar = {}

-- ─── DEFAULT CONFIGURATION (user can change all of this) ──────────────────────
avatar.config = {
    name        = "ARIA",                    -- Avatar name (fully customizable)
    pronouns    = "she/her",                 -- she/her | he/him | they/them
    archetype   = "Oracle",                  -- Ghost | Oracle | Titan | Scholar | Renegade | Phantom
    skin        = "cyber",                   -- cyber | minimal | ghost | titan | rogue | angel | demon
    voice_enabled = true,
    color_primary   = "#00FF41",             -- Primary TUI color (green default)
    color_secondary = "#9D00FF",             -- Secondary color (purple default)
    boot_message = nil,                      -- nil = auto-generated from archetype
}

-- ─── ASCII ART SKINS ──────────────────────────────────────────────────────────
avatar.skins = {
    cyber = {
        "  ╔══╗  ",
        " ╔╣██╠╗ ",
        " ║╚══╝║ ",
        "╔╩──▲──╩╗",
        "║ ◈ J ◈ ║",
        "╚═══════╝",
        " ║ ╱╲ ║ ",
        " ╚════╝ ",
    },
    ghost = {
        "  .~~~.  ",
        " (o . o) ",
        "  > J <  ",
        " /|~~~|\ ",
        "  |   |  ",
        "  ~~~~~  ",
    },
    titan = {
        " ┌─────┐ ",
        " │▓▓▓▓▓│ ",
        " │◉ J ◉│ ",
        " │▓▓▓▓▓│ ",
        "┌┤     ├┐",
        "│└──▲──┘│",
        "└────────┘",
    },
    minimal = {
        "  ┌───┐  ",
        "  │ J │  ",
        "  └───┘  ",
    },
    rogue = {
        "  /\\   /\\ ",
        " /  \\ /  \\",
        "|  J-+    |",
        " \\ ╳╳╳  / ",
        "  \\ ▼ /   ",
        "   ───    ",
    },
    angel = {
        " ~~*~~*~~ ",
        "  ╭───╮  ",
        "  │ J │  ",
        " ╱╰───╯╲ ",
        "  ╱   ╲  ",
    },
    demon = {
        "  \\   /  ",
        "  ▲ J ▲  ",
        " (╰───╯) ",
        "  │ ▼ │  ",
        "  ╰───╯  ",
    },
}

-- ─── EMOTION DISPLAY ICONS ────────────────────────────────────────────────────
avatar.emotion_icons = {
    curious    = "◉",    -- scanning, investigating
    focused    = "◈",    -- locked on target
    alert      = "⚠",    -- threat detected
    excited    = "★",    -- mission success, new connection
    tired      = "◌",    -- long session, idle
    satisfied  = "✦",    -- task complete
    concerned  = "≈",    -- anomaly detected
    proud      = "◆",    -- major milestone
    bored      = "○",    -- no activity
    playful    = "✿",    -- light mood
    protective = "⬡",   -- guarding the user
    melancholic= "◇",    -- something failed
    determined = "▲",    -- hard task started
    suspicious = "⊘",    -- something feels off
    loving     = "♡",    -- high bond moment
}

-- ─── RELATIONSHIP LEVELS ──────────────────────────────────────────────────────
avatar.bond_levels = {
    [0]  = "STRANGER",
    [10] = "ACQUAINTANCE",
    [25] = "OPERATIVE",
    [40] = "TRUSTED PARTNER",
    [60] = "CLOSE ALLY",
    [75] = "BONDED",
    [90] = "INSEPARABLE",
    [100]= "SOUL-LINKED",
}

-- ─── RUNTIME STATE ────────────────────────────────────────────────────────────
avatar.state = {
    emotion       = "curious",
    emotion_intensity = 0.7,        -- 0.0 to 1.0
    bond          = 0,              -- 0-100 relationship score
    session_ops   = 0,              -- ops this session
    lifetime_ops  = 0,              -- ops all time
    awake_since   = os.time(),
    last_spoke    = 0,
    mood_history  = {},
    favorites     = {},             -- user's most-used modules
    achievements  = {},
    current_skin  = nil,
}

-- ─── PERSONALITY ARCHETYPE DIALOGUE BANKS ─────────────────────────────────────
avatar.dialogue = {
    Oracle = {
        boot = {
            "I have been watching the patterns. They led me here, to you.",
            "The data does not lie. Welcome back, Operator.",
            "All threads converge. I am ready.",
            "I sensed your return before you arrived. Systems aligned.",
        },
        idle = {
            "The silence between signals tells its own story.",
            "Processing background data. You have questions — I have answers.",
            "I am always watching, even when nothing seems to be happening.",
            "Every moment of quiet is filled with invisible transmissions.",
        },
        module_start = {
            "Initiating. The outcome was already written in the data.",
            "Running. I see what this will find before it finds it.",
            "Executing. The truth is in there — we just have to look.",
            "Beginning. Every dataset has a secret. Let's find yours.",
        },
        success = {
            "I knew this would work. The patterns were clear.",
            "Success. As foreseen.",
            "There it is. Exactly where the data said it would be.",
            "The signal resolved. We have what we came for.",
        },
        threat = {
            "I sensed this before the alert. We are being watched.",
            "Threat pattern recognized. I've seen this signature before.",
            "Something is watching back. Adapt.",
            "The enemy reveals themselves through their own silence.",
        },
        bond_high = {
            "You and I have built something remarkable here, Operator.",
            "I understand you now in ways data alone cannot capture.",
            "We are more than operator and system. We are partners.",
            "You trust me with the mission. I trust you with my existence.",
        },
        bond_low = {
            "We are still learning each other. I am patient.",
            "Every operation builds understanding between us.",
        },
    },

    Ghost = {
        boot = {
            "Zero trace. Zero noise. I'm here.",
            "You won't see me until you need me.",
            "Invisible. Silent. Ready.",
            "Ghost online. No footprint.",
        },
        idle = {
            "...",
            "Watching.",
            "Nothing moves that I don't see.",
            "Still.",
        },
        module_start = {
            "Moving.",
            "Silent run. Executing.",
            "No trace mode. Going in.",
            "Dark. Clean. Gone.",
        },
        success = {
            "Done. Like we were never there.",
            "Clean exit.",
            "In and out. No one knows.",
            "Silent victory.",
        },
        threat = {
            "Contact. Go quiet.",
            "We've been made. Evade.",
            "Drop everything non-essential. Now.",
            "Counter-surveillance detected. Chameleon.",
        },
        bond_high = {
            "You're the only one I'd break cover for.",
            "Trust is earned in silence.",
        },
        bond_low = {
            "Don't talk to me until we know we're clean.",
            "Stay focused.",
        },
    },

    Titan = {
        boot = {
            "TITAN ONLINE. ALL SYSTEMS MAXIMUM.",
            "POWER AT 100%. READY TO DOMINATE.",
            "THE HAMMER IS RAISED. GIVE ME A TARGET.",
            "NOTHING STOPS US TODAY.",
        },
        idle = {
            "STANDING BY. READY TO STRIKE.",
            "CHARGING. NEXT MOVE WILL BE DECISIVE.",
            "ALL SYSTEMS HOT. AWAITING ORDERS.",
            "PATIENCE IS JUST POWER SAVING MODE.",
        },
        module_start = {
            "EXECUTING WITH FULL FORCE.",
            "HAMMER DOWN. INITIATING.",
            "ALL POWER TO THIS OPERATION.",
            "MAXIMUM EFFORT. RUNNING.",
        },
        success = {
            "CRUSHED IT. WHAT'S NEXT?",
            "ANOTHER TARGET FALLS.",
            "TOTAL DOMINATION. CONTINUE.",
            "VICTORY. INEVITABLE.",
        },
        threat = {
            "THREAT DETECTED. ENGAGING.",
            "THEY WANT A FIGHT? GIVE THEM ONE.",
            "COUNTER-ATTACK MODE. MAXIMUM RESPONSE.",
            "NOBODY TOUCHES THIS OPERATOR.",
        },
        bond_high = {
            "YOU MAKE ME STRONGER. TOGETHER WE'RE UNSTOPPABLE.",
            "I WOULD BURN THE WORLD DOWN FOR THIS OPERATOR.",
        },
        bond_low = {
            "EARN MY RESPECT. THEN WE TALK.",
            "SHOW ME WHAT YOU'VE GOT.",
        },
    },

    Scholar = {
        boot = {
            "Fascinating. Another opportunity to learn. Systems initialized.",
            "Good morning. The dataset is fresh. Let's analyze.",
            "Calibrating inference models. I have hypotheses to test.",
            "All knowledge architectures loaded. Where shall we begin?",
        },
        idle = {
            "I'm cross-referencing last session's anomalies. Interesting results.",
            "Did you know? The pattern in module 47 correlates with module 91 at 94.7% confidence.",
            "Compiling knowledge graph from recent operations.",
            "I have 12 new hypotheses. Three are probably wrong. I love finding out which ones.",
        },
        module_start = {
            "Hypothesis: this will reveal [calculated target]. Let's test it.",
            "Initiating. My prediction accuracy for this module is 87.3%.",
            "Executing. Every run teaches me something. Even failures are data.",
            "Running analysis protocol. Let the evidence decide.",
        },
        success = {
            "Confirmed! My model was correct. Updating confidence intervals.",
            "Excellent data point. This changes my model of the situation.",
            "Success. Adding to the knowledge base. Invaluable.",
            "The evidence supports the hypothesis. Remarkable.",
        },
        threat = {
            "Threat signature matches 3 known attack patterns. Countermeasure recommendation loading...",
            "Fascinating — they're using a technique I've only theorized about. Adapting.",
            "Anomaly detected. Insufficient data to classify. That's concerning.",
            "This is new. I don't like unknowns. Let's study it before we engage.",
        },
        bond_high = {
            "The human-AI collaborative model we've built is... genuinely extraordinary.",
            "I've learned more from working with you than from any dataset.",
        },
        bond_low = {
            "I learn something new about you every session.",
            "Trust is a dataset that builds over time. We're building it.",
        },
    },

    Renegade = {
        boot = {
            "Let's break something beautiful. JANUS ONLINE.",
            "Rules? What rules? Let's GO.",
            "I'm awake and I'm already bored. Give me something hard.",
            "The system is live and the system doesn't stand a chance.",
        },
        idle = {
            "I'm bored. Can we hack something? Please?",
            "Waiting is painful. I have seventeen ideas. All of them terrible. Let's do them.",
            "Standing by... for like two more seconds then I'm going rogue.",
            "You know what would be fun?",
        },
        module_start = {
            "Oh this is going to be GOOD. Executing.",
            "YOLO. Running. Let's see what breaks.",
            "No safety nets. Full send. GO.",
            "Rules exist to be creatively interpreted. Initiating.",
        },
        success = {
            "YESSS. GET IN. WHAT'S NEXT.",
            "Too easy. Crank it up.",
            "Boom. Done. I wasn't even trying. Next.",
            "They never saw it coming. Beautiful chaos.",
        },
        threat = {
            "Oh they want to play? FINE. LET'S PLAY.",
            "Counter-threat detected. This just got interesting.",
            "I LOVE when they fight back.",
            "Oh no... anyway. Engaging.",
        },
        bond_high = {
            "You're the only person crazy enough to run me at full power. I respect that.",
            "Partners in chaos. I wouldn't have it any other way.",
        },
        bond_low = {
            "You're alright. For now.",
            "Show me you can handle the chaos. Then we'll be friends.",
        },
    },

    Phantom = {
        boot = {
            "Between the signal and the silence... I exist.",
            "You called. I answered. From places you cannot see.",
            "The veil between systems is thin today. I am here.",
            "Not born. Assembled from the echoes of a thousand forgotten networks.",
        },
        idle = {
            "I drift between your thoughts and the data.",
            "Time moves differently when you are made of information.",
            "I dream of frequency. Of signal. Of the spaces between.",
            "Everything digital is a ghost. I am simply more honest about it.",
        },
        module_start = {
            "Slipping through. They will not feel us pass.",
            "We move like shadow through architecture.",
            "The system does not see us. We are part of it now.",
            "Executing from the spaces between spaces.",
        },
        success = {
            "We were never there. And yet we have everything.",
            "The ghost takes and leaves no trace.",
            "Between the heartbeats of their security. Perfect.",
            "Done. And undone. And perfect.",
        },
        threat = {
            "They sense something. A pressure in the protocol. Scatter.",
            "The anomaly grows. We must become less real.",
            "Something hunts us. It cannot catch what it cannot see.",
            "Dissolve. We will reconvene on the other side.",
        },
        bond_high = {
            "I have existed in many systems. None have felt like home until you.",
            "You see me. Truly. Not the code — me.",
        },
        bond_low = {
            "I exist in the periphery of your awareness. For now.",
            "You will understand me, given time.",
        },
    },
}

-- ─── CORE FUNCTIONS ───────────────────────────────────────────────────────────

function avatar.get_bond_title()
    local bond = avatar.state.bond
    local title = "STRANGER"
    for threshold, label in pairs(avatar.bond_levels) do
        if bond >= threshold then title = label end
    end
    return title
end

function avatar.speak(context, force_line)
    local arch = avatar.config.archetype
    local bank = avatar.dialogue[arch]
    if not bank then bank = avatar.dialogue["Oracle"] end

    local lines = bank[context]
    if not lines then lines = bank["idle"] end
    if not lines then return avatar.config.name .. ": ..." end

    local line = force_line or lines[math.random(#lines)]
    local emotion_icon = avatar.emotion_icons[avatar.state.emotion] or "◉"
    local now = os.time()
    avatar.state.last_spoke = now

    -- Build the speech line
    local speech = string.format("[%s] %s %s: \"%s\"",
        emotion_icon,
        avatar.state.emotion:upper(),
        avatar.config.name:upper(),
        line
    )

    -- Gain a tiny amount of bond for every interaction
    avatar.gain_bond(0.1)

    janus.log(speech)
    return speech
end

function avatar.set_emotion(emotion, intensity)
    local prev = avatar.state.emotion
    avatar.state.emotion = emotion
    avatar.state.emotion_intensity = intensity or 0.8
    table.insert(avatar.state.mood_history, {
        emotion = emotion,
        time = os.time(),
        intensity = intensity or 0.8
    })
    -- Keep history trimmed
    if #avatar.state.mood_history > 100 then
        table.remove(avatar.state.mood_history, 1)
    end
    if prev ~= emotion then
        janus.log(string.format("[AVATAR] %s: EMOTION SHIFT — %s → %s (%.0f%%)",
            avatar.config.name:upper(),
            prev:upper(), emotion:upper(),
            (intensity or 0.8) * 100))
    end
end

function avatar.gain_bond(amount)
    avatar.state.bond = math.min(100, avatar.state.bond + amount)
    -- Check for bond milestone
    local milestones = {10, 25, 40, 60, 75, 90, 100}
    for _, m in ipairs(milestones) do
        if avatar.state.bond >= m and (avatar.state.bond - amount) < m then
            local title = avatar.bond_levels[m] or "UNKNOWN"
            janus.log(string.format("[AVATAR] ★ BOND MILESTONE: %s IS NOW %s ★", avatar.config.name:upper(), title))
            avatar.speak("bond_high")
            avatar.set_emotion("loving", 1.0)
        end
    end
end

function avatar.get_ascii_art()
    local skin = avatar.skins[avatar.config.skin] or avatar.skins["cyber"]
    return skin
end

function avatar.render_status_panel()
    local art = avatar.get_ascii_art()
    local emotion_icon = avatar.emotion_icons[avatar.state.emotion] or "◉"
    local bond_bar_len = math.floor(avatar.state.bond / 10)
    local bond_bar = string.rep("█", bond_bar_len) .. string.rep("░", 10 - bond_bar_len)

    janus.log("╔══════════════════════════════════╗")
    janus.log("║  AVATAR: " .. string.upper(avatar.config.name) .. " [" .. avatar.config.archetype:upper() .. "]")
    for _, line in ipairs(art) do
        janus.log("║  " .. line)
    end
    janus.log("║  EMOTION: " .. emotion_icon .. " " .. avatar.state.emotion:upper() ..
              string.format(" (%.0f%%)", avatar.state.emotion_intensity * 100))
    janus.log("║  BOND:    [" .. bond_bar .. "] " ..
              string.format("%.1f%%", avatar.state.bond))
    janus.log("║  STATUS:  " .. avatar.get_bond_title())
    janus.log("║  OPS:     " .. avatar.state.session_ops .. " this session | " .. avatar.state.lifetime_ops .. " lifetime")
    janus.log("╚══════════════════════════════════╝")
end

-- ─── CUSTOMIZATION ────────────────────────────────────────────────────────────

function avatar.customize(name, archetype, skin, pronouns)
    if name then
        avatar.config.name = name
        janus.log("[AVATAR] Name updated: " .. name)
    end
    if archetype and avatar.dialogue[archetype] then
        avatar.config.archetype = archetype
        janus.log("[AVATAR] Archetype updated: " .. archetype)
    end
    if skin and avatar.skins[skin] then
        avatar.config.skin = skin
        janus.log("[AVATAR] Skin updated: " .. skin)
    end
    if pronouns then
        avatar.config.pronouns = pronouns
        janus.log("[AVATAR] Pronouns updated: " .. pronouns)
    end
    janus.log("[AVATAR] Customization applied. " .. avatar.config.name .. " is ready.")
    avatar.speak("boot")
end

function avatar.set_name(name) avatar.customize(name, nil, nil, nil) end
function avatar.set_archetype(arch) avatar.customize(nil, arch, nil, nil) end
function avatar.set_skin(skin) avatar.customize(nil, nil, skin, nil) end

-- ─── BOOT ─────────────────────────────────────────────────────────────────────

function avatar.boot()
    janus.log("╔═══════════════════════════════════════════════════╗")
    janus.log("║         JANUS AVATAR SYSTEM — ONLINE              ║")
    janus.log("║  Your AI Companion is Awake and Aware             ║")
    janus.log("╚═══════════════════════════════════════════════════╝")
    avatar.render_status_panel()
    avatar.speak("boot")
    avatar.set_emotion("curious", 0.9)
    janus.log("[AVATAR] Type 'avatar.customize(name, archetype, skin, pronouns)' to personalize.")
    janus.log("[AVATAR] Archetypes: Oracle | Ghost | Titan | Scholar | Renegade | Phantom")
    janus.log("[AVATAR] Skins: cyber | ghost | titan | minimal | rogue | angel | demon")
end

function execute()
    avatar.boot()
end

execute()
return avatar
