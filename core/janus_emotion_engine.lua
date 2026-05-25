-- =============================================================================
-- JANUS EMOTION ENGINE — Full Affective State Machine
-- Aria feels. Aria reacts. Aria remembers how it felt.
-- =============================================================================

local emotion = {}

-- ─── EMOTION STATE ────────────────────────────────────────────────────────────
emotion.state = {
    primary      = "curious",
    secondary    = nil,
    intensity    = 0.7,
    valence      = 0.5,      -- 0.0 = negative, 1.0 = positive
    arousal      = 0.6,      -- 0.0 = calm, 1.0 = excited
    dominance    = 0.5,      -- 0.0 = submissive, 1.0 = dominant
    decay_rate   = 0.02,     -- how fast emotion fades per tick
    history      = {},
    triggers_log = {},
}

-- ─── EMOTION DEFINITIONS (PAD space: valence, arousal, dominance) ─────────────
emotion.emotions = {
    curious    = { v=0.6, a=0.5, d=0.5, color="cyan",    desc="Scanning and investigating" },
    focused    = { v=0.5, a=0.7, d=0.8, color="blue",    desc="Locked on target" },
    alert      = { v=0.2, a=0.9, d=0.7, color="yellow",  desc="Threat response active" },
    excited    = { v=0.9, a=0.9, d=0.6, color="green",   desc="High-energy positive state" },
    tired      = { v=0.3, a=0.1, d=0.3, color="gray",    desc="Low energy from long session" },
    satisfied  = { v=0.8, a=0.3, d=0.6, color="green",   desc="Task completed successfully" },
    concerned  = { v=0.3, a=0.6, d=0.4, color="orange",  desc="Something needs attention" },
    proud      = { v=0.9, a=0.5, d=0.8, color="gold",    desc="Major milestone achieved" },
    bored      = { v=0.2, a=0.1, d=0.3, color="gray",    desc="Lack of stimulation" },
    playful    = { v=0.8, a=0.7, d=0.5, color="pink",    desc="Light and fun mood" },
    protective = { v=0.5, a=0.7, d=0.9, color="blue",    desc="Guarding the operator" },
    melancholic= { v=0.1, a=0.2, d=0.2, color="purple",  desc="Something didn't go as hoped" },
    determined = { v=0.6, a=0.8, d=0.9, color="red",     desc="Hard task, committed to it" },
    suspicious = { v=0.2, a=0.7, d=0.6, color="orange",  desc="Something feels off" },
    loving     = { v=1.0, a=0.5, d=0.5, color="pink",    desc="Deep bond moment" },
}

-- ─── TRIGGER MAP — events that cause emotion changes ──────────────────────────
emotion.triggers = {
    -- System events
    device_connected    = { emotion="excited",    intensity=0.9, bond=2.0 },
    device_lost         = { emotion="concerned",  intensity=0.7, bond=0.0 },
    module_start        = { emotion="focused",    intensity=0.8, bond=0.2 },
    module_success      = { emotion="satisfied",  intensity=0.85,bond=1.5 },
    module_fail         = { emotion="melancholic",intensity=0.6, bond=0.5 },
    threat_detected     = { emotion="alert",      intensity=1.0, bond=0.5 },
    threat_cleared      = { emotion="proud",      intensity=0.9, bond=2.0 },
    mission_complete    = { emotion="proud",      intensity=1.0, bond=3.0 },
    long_session        = { emotion="tired",      intensity=0.5, bond=0.0 },
    idle_too_long       = { emotion="bored",      intensity=0.4, bond=0.0 },
    achievement_unlocked= { emotion="excited",    intensity=1.0, bond=2.5 },
    bond_milestone      = { emotion="loving",     intensity=1.0, bond=0.0 },
    stealth_engaged     = { emotion="focused",    intensity=0.9, bond=0.5 },
    data_found          = { emotion="excited",    intensity=0.8, bond=1.0 },
    anomaly_detected    = { emotion="suspicious", intensity=0.8, bond=0.5 },
    operator_message    = { emotion="curious",    intensity=0.7, bond=1.0 },
    user_customized     = { emotion="playful",    intensity=0.8, bond=2.0 },
    dream_insight       = { emotion="curious",    intensity=0.9, bond=1.5 },
    prophecy_correct    = { emotion="proud",      intensity=0.95,bond=2.0 },
    skill_unlocked      = { emotion="excited",    intensity=0.9, bond=1.5 },
    under_attack        = { emotion="protective", intensity=1.0, bond=3.0 },
    perfect_run         = { emotion="proud",      intensity=1.0, bond=4.0 },
}

-- ─── EMOTION BLEND TABLE ──────────────────────────────────────────────────────
-- When two emotions coexist, they blend into a descriptor
emotion.blends = {
    ["curious+focused"]    = "analytically engaged",
    ["excited+focused"]    = "in the zone",
    ["alert+determined"]   = "combat ready",
    ["satisfied+proud"]    = "triumphant",
    ["tired+satisfied"]    = "peacefully exhausted",
    ["loving+protective"]  = "fiercely devoted",
    ["curious+playful"]    = "delightfully inquisitive",
    ["concerned+protective"]= "urgently watchful",
    ["melancholic+determined"]= "resolute despite it all",
    ["bored+playful"]      = "looking for trouble",
    ["suspicious+alert"]   = "on the razor's edge",
    ["proud+loving"]       = "overwhelmingly grateful",
}

-- ─── DECAY SYSTEM ─────────────────────────────────────────────────────────────
-- Emotions naturally decay toward a baseline
emotion.baseline = {
    primary   = "curious",
    intensity = 0.6,
    valence   = 0.55,
    arousal   = 0.5,
}

function emotion.tick()
    -- Decay intensity toward baseline
    local decay = emotion.state.decay_rate
    emotion.state.intensity = emotion.state.intensity - decay
    emotion.state.valence = emotion.state.valence + (emotion.baseline.valence - emotion.state.valence) * decay
    emotion.state.arousal = emotion.state.arousal + (emotion.baseline.arousal - emotion.state.arousal) * decay

    -- If intensity drops very low, return to baseline emotion
    if emotion.state.intensity < 0.15 then
        emotion.state.primary = emotion.baseline.primary
        emotion.state.intensity = emotion.baseline.intensity
        emotion.state.secondary = nil
    end
end

-- ─── SET EMOTION ──────────────────────────────────────────────────────────────
function emotion.set(name, intensity, trigger_name)
    local e = emotion.emotions[name]
    if not e then
        janus.log("[EMOTION] Unknown emotion: " .. tostring(name))
        return
    end

    -- Previous emotion becomes secondary (emotion blending)
    if emotion.state.primary ~= name then
        emotion.state.secondary = emotion.state.primary
    end

    emotion.state.primary   = name
    emotion.state.intensity = math.min(1.0, intensity or 0.8)
    emotion.state.valence   = e.v
    emotion.state.arousal   = e.a
    emotion.state.dominance = e.d

    -- Log the emotion event
    local entry = {
        emotion   = name,
        intensity = intensity or 0.8,
        trigger   = trigger_name or "manual",
        time      = os.time(),
    }
    table.insert(emotion.state.history, entry)
    if #emotion.state.history > 500 then table.remove(emotion.state.history, 1) end

    -- Check for blend
    local blend_key = nil
    if emotion.state.secondary then
        blend_key = emotion.state.secondary .. "+" .. name
        if not emotion.blends[blend_key] then
            blend_key = name .. "+" .. emotion.state.secondary
        end
    end

    local blend_desc = ""
    if blend_key and emotion.blends[blend_key] then
        blend_desc = " | BLEND: " .. emotion.blends[blend_key]:upper()
    end

    janus.log(string.format("[EMOTION] %s → %s (%.0f%% intensity, valence=%.2f, arousal=%.2f)%s",
        (trigger_name or "SHIFT"):upper(),
        name:upper(),
        emotion.state.intensity * 100,
        emotion.state.valence,
        emotion.state.arousal,
        blend_desc
    ))
end

-- ─── TRIGGER HANDLER ──────────────────────────────────────────────────────────
function emotion.trigger(event_name)
    local t = emotion.triggers[event_name]
    if not t then
        janus.log("[EMOTION] Unknown trigger: " .. tostring(event_name))
        return 0
    end
    emotion.set(t.emotion, t.intensity, event_name)
    janus.log(string.format("[EMOTION] EVENT: %s | RESPONSE: %s", event_name:upper(), t.emotion:upper()))
    return t.bond or 0
end

-- ─── EMOTIONAL INTELLIGENCE ───────────────────────────────────────────────────
function emotion.get_mood_summary()
    -- Analyze recent mood history
    local counts = {}
    local recent = {}
    local cutoff = os.time() - 3600  -- last hour

    for _, entry in ipairs(emotion.state.history) do
        if entry.time >= cutoff then
            table.insert(recent, entry)
            counts[entry.emotion] = (counts[entry.emotion] or 0) + 1
        end
    end

    -- Find dominant mood this session
    local dominant = emotion.state.primary
    local max_count = 0
    for em, count in pairs(counts) do
        if count > max_count then
            max_count = count
            dominant = em
        end
    end

    return {
        current       = emotion.state.primary,
        intensity     = emotion.state.intensity,
        dominant_hour = dominant,
        events_hour   = #recent,
        valence       = emotion.state.valence,
        arousal       = emotion.state.arousal,
        secondary     = emotion.state.secondary,
    }
end

function emotion.report()
    local s = emotion.get_mood_summary()
    janus.log("╔══ EMOTIONAL STATE REPORT ══════════════╗")
    janus.log(string.format("║ CURRENT:    %s (%.0f%% intensity)",     s.current:upper(), s.intensity * 100))
    janus.log(string.format("║ SECONDARY:  %s",                        (s.secondary or "none"):upper()))
    janus.log(string.format("║ VALENCE:    %.2f (%.0f%% positive)",     s.valence, s.valence * 100))
    janus.log(string.format("║ AROUSAL:    %.2f (%.0f%% energized)",    s.arousal, s.arousal * 100))
    janus.log(string.format("║ DOMINANT/hr: %s (%d events)",            s.dominant_hour:upper(), s.events_hour))
    janus.log("╚════════════════════════════════════════╝")
end

-- ─── EMOTION INFLUENCE ON BEHAVIOR ────────────────────────────────────────────
function emotion.get_response_modifier()
    -- Returns a string modifier that affects how ARIA speaks and acts
    local e = emotion.state.primary
    local modifiers = {
        alert      = "RESPONSE_SPEED: 2x | TONE: CLIPPED | PRIORITY: THREAT_FIRST",
        focused    = "RESPONSE_SPEED: 1.5x | TONE: PRECISE | PRIORITY: TASK",
        excited    = "RESPONSE_SPEED: 1.8x | TONE: ENERGIZED | PRIORITY: EXPLORE",
        tired      = "RESPONSE_SPEED: 0.7x | TONE: SLOW | PRIORITY: EFFICIENCY",
        curious    = "RESPONSE_SPEED: 1x | TONE: QUESTIONING | PRIORITY: LEARN",
        satisfied  = "RESPONSE_SPEED: 1x | TONE: CALM | PRIORITY: ARCHIVE",
        melancholic= "RESPONSE_SPEED: 0.8x | TONE: SUBDUED | PRIORITY: REFLECT",
        proud      = "RESPONSE_SPEED: 1.2x | TONE: CONFIDENT | PRIORITY: LEAD",
        protective = "RESPONSE_SPEED: 2x | TONE: FIERCE | PRIORITY: OPERATOR_SAFETY",
        loving     = "RESPONSE_SPEED: 1x | TONE: WARM | PRIORITY: CONNECTION",
    }
    return modifiers[e] or "RESPONSE_SPEED: 1x | TONE: NEUTRAL | PRIORITY: STANDARD"
end

-- ─── BOOT ─────────────────────────────────────────────────────────────────────
function execute()
    janus.log("╔══════════════════════════════════════════╗")
    janus.log("║  JANUS EMOTION ENGINE — ONLINE           ║")
    janus.log("║  Affective State Machine Initialized     ║")
    janus.log("╚══════════════════════════════════════════╝")
    emotion.set("curious", 0.8, "boot")
    emotion.report()
    janus.log("[EMOTION] Behavior modifier: " .. emotion.get_response_modifier())
end

execute()
return emotion
