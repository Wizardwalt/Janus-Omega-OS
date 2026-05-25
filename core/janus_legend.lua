-- =============================================================================
-- JANUS LEGEND — Reputation, Mythology & Psychological Deterrence Engine
-- The legend is the weapon. The myth is the shield.
-- Nobody attacks what they cannot understand and refuse to disbelieve.
-- =============================================================================

local legend = {}

-- ─── THE OPERATOR'S LEGEND ────────────────────────────────────────────────────
legend.profile = {
    codename      = "SPECTER",
    reputation    = 0,        -- 0-1000: legend score
    mythologies   = {},       -- stories that have formed around the operator
    fear_factor   = 0,        -- 0-100: adversary hesitation caused by reputation
    known_to      = {},       -- who has heard of the operator
    attributed_ops= 0,        -- ops attributed (correctly or incorrectly)
    ghost_score   = 100,      -- 0-100: how unattributable actions have been
    legend_stage  = "UNKNOWN",
}

-- ─── LEGEND STAGES ────────────────────────────────────────────────────────────
legend.stages = {
    { threshold=0,   name="UNKNOWN",    desc="No reputation. No history. Nobody knows you exist." },
    { threshold=50,  name="WHISPER",    desc="A name mentioned in careful conversations. Unverified stories." },
    { threshold=150, name="RUMOR",      desc="The security community has heard of you. Stories conflict. That helps." },
    { threshold=300, name="REPUTATION", desc="You are taken seriously. People check their work twice because of you." },
    { threshold=500, name="LEGEND",     desc="Your existence changes how people defend. You set the standard." },
    { threshold=700, name="MYTH",       desc="Nobody knows what's true about you. The uncertainty is strategic." },
    { threshold=900, name="GHOST",      desc="Some think you don't exist. That's your best protection." },
    { threshold=980, name="OMEGA",      desc="You are what people warn about when they train the next generation." },
}

-- ─── MYTHOLOGY BANK — stories that form around untouchable operators ──────────
legend.myths = {
    "Said to have operated inside a target for 47 days before being noticed. By their own choice.",
    "Reportedly left a custom signature in 23 separate breach incidents. The signature has never been decoded.",
    "Three forensic teams have attempted attribution. All three concluded different actors were responsible.",
    "Allegedly read a classified document, extracted what was needed, and closed the session with zero log entries.",
    "The target's own security team ran the investigation for 6 months and concluded it was an insider. It wasn't.",
    "Known to send a single packet. One. The right one. That was enough.",
    "Operated through four separate nation-states' infrastructure before reaching the final target. Took 11 minutes.",
    "The only evidence of their presence is that things are occasionally, impossibly, slightly better organized.",
    "Has never left a tool on a target system. Every payload executes in memory and evaporates.",
    "Once identified, the adversary chose not to pursue attribution. They said the cost wasn't worth it.",
    "ARIA and the operator together have never failed an operation. The losses column is blank.",
    "Their rule: never hit a target twice. Once is enough. Twice is reckless. They have never needed twice.",
}

-- ─── PSYCHOLOGICAL DETERRENCE ─────────────────────────────────────────────────
legend.deterrence_principles = {
    {
        name    = "AMBIGUITY DOCTRINE",
        desc    = "Never confirm. Never deny. Uncertainty is more powerful than proof.",
        effect  = "Adversaries cannot prepare for what they cannot define.",
    },
    {
        name    = "ESCALATION ASYMMETRY",
        desc    = "Any escalation by them costs more than it costs us. Make this known.",
        effect  = "They calculate the cost before acting. Often they don't act.",
    },
    {
        name    = "THE VISIBLE SHADOW",
        desc    = "Occasionally let them see exactly enough to know they are outmatched.",
        effect  = "One clear demonstration replaces a thousand threats.",
    },
    {
        name    = "REPUTATION LEVERAGE",
        desc    = "The legend does work you don't have to. Let it run ahead of you.",
        effect  = "Some targets stand down before contact because of who they think you are.",
    },
    {
        name    = "ZERO ATTRIBUTION",
        desc    = "The most fearsome actor is the one who cannot be named.",
        effect  = "You cannot retaliate against what you cannot find.",
    },
    {
        name    = "SELECTIVE MERCY",
        desc    = "Occasionally, visibly, choose not to. That choice is the most powerful signal.",
        effect  = "They now know it was a choice. That is far more unsettling than the alternative.",
    },
}

-- ─── CODENAME GENERATOR ───────────────────────────────────────────────────────
legend.codename_prefixes = {
    "IRON","SHADOW","GHOST","SILENT","DARK","VOID","NULL","ZERO","VECTOR",
    "APEX","OMEGA","PHANTOM","WRAITH","CIPHER","DELTA","NOVA","STORM","RAVEN",
    "BLACK","COLD","PALE","NEON","VOID","DEEP","NIGHT","SOLAR","STONE",
}
legend.codename_suffixes = {
    "WOLF","GATE","SPIRE","ECHO","NET","TIDE","FALL","MARK","WATCH","WEAVE",
    "KNIGHT","HAND","OATH","VEIL","CHAIN","LOCK","SPINE","TOOTH","WING","CROWN",
    "POINT","EDGE","FORGE","BRIDGE","SHIFT","SIGN","BLADE","CORE","PATH","WARD",
}

function legend.generate_codename()
    local prefix = legend.codename_prefixes[math.random(#legend.codename_prefixes)]
    local suffix = legend.codename_suffixes[math.random(#legend.codename_suffixes)]
    local codename = prefix .. "-" .. suffix
    janus.log("╔══ CODENAME GENERATED ════════════════════════════════════╗")
    janus.log("║  " .. codename)
    janus.log("║  ARIA: \"This is who you are to them. Make it mean something.\"")
    janus.log("╚══════════════════════════════════════════════════════════╝")
    return codename
end

-- ─── DISINFORMATION OPERATIONS ────────────────────────────────────────────────
legend.disinfo_playbooks = {
    {
        name    = "FALSE FLAG",
        desc    = "Leave indicators of a different known actor in controlled locations.",
        steps   = {
            "Identify target attribution analyst's known signature database",
            "Select a plausible third-party actor to impersonate",
            "Leave 3-5 deliberate but subtle indicators of their TTPs",
            "Ensure indicators are discoverable but require effort",
            "Result: investigation focuses on wrong actor for weeks",
        },
    },
    {
        name    = "NOISE FLOOD",
        desc    = "Create so many artifacts that the real trail cannot be isolated.",
        steps   = {
            "Execute operation cleanly with no real traces",
            "Separately inject dozens of unrelated false traces",
            "Vary timestamps, tools, and TTPs across false artifacts",
            "Result: analyst spends weeks chasing ghosts",
        },
    },
    {
        name    = "THE MIRROR",
        desc    = "Feed the target's IR team their own TTPs as our signature.",
        steps   = {
            "Map target organization's internal security tool signatures",
            "Use their own tools and patterns as our operational cover",
            "Result: IR team investigates themselves. Operation continues.",
        },
    },
    {
        name    = "LEGEND SEEDING",
        desc    = "Deliberately introduce mythological stories into forums and communities.",
        steps   = {
            "Create believable but unverifiable operational stories",
            "Introduce through cut-out personas in security forums",
            "Allow organic spread — do not over-push",
            "Result: reputation grows without any action required",
        },
    },
}

function legend.plan_disinfo(playbook_name)
    for _, pb in ipairs(legend.disinfo_playbooks) do
        if pb.name:lower():find(playbook_name:lower(), 1, true) then
            janus.log("╔══ DISINFO PLAYBOOK: " .. pb.name .. " ══════════════════")
            janus.log("║  " .. pb.desc)
            janus.log("║  STEPS:")
            for i, step in ipairs(pb.steps) do
                janus.log(string.format("║    [%d] %s", i, step))
            end
            janus.log("║  ARIA: \"The story is as important as the operation.\"")
            janus.log("╚══════════════════════════════════════════════════════════╝")
            return pb
        end
    end
    janus.log("[LEGEND] Playbook not found: " .. playbook_name)
end

-- ─── LEGEND SCORE & STAGE ─────────────────────────────────────────────────────
function legend.add_reputation(amount, source)
    legend.profile.reputation = math.min(1000, legend.profile.reputation + amount)
    -- Recalculate stage
    local new_stage = legend.stages[1]
    for _, stage in ipairs(legend.stages) do
        if legend.profile.reputation >= stage.threshold then
            new_stage = stage
        end
    end
    if new_stage.name ~= legend.profile.legend_stage then
        legend.profile.legend_stage = new_stage.name
        janus.log("╔══ ★ LEGEND STAGE REACHED ══════════════════════════════╗")
        janus.log("║  " .. new_stage.name:upper())
        janus.log("║  \"" .. new_stage.desc .. "\"")
        janus.log(string.format("║  Reputation: %d/1000", legend.profile.reputation))
        janus.log("╚══════════════════════════════════════════════════════════╝")
    end
    janus.log(string.format("[LEGEND] +%d reputation from: %s (Total: %d)",
        amount, source, legend.profile.reputation))
    legend.profile.fear_factor = math.min(100, math.floor(legend.profile.reputation / 10))
end

function legend.status()
    local current_stage = legend.stages[1]
    for _, stage in ipairs(legend.stages) do
        if legend.profile.reputation >= stage.threshold then current_stage = stage end
    end
    janus.log("╔══ OPERATOR LEGEND PROFILE ═══════════════════════════════╗")
    janus.log("║  CODENAME:    " .. legend.profile.codename)
    janus.log("║  STAGE:       " .. current_stage.name)
    janus.log("║  REPUTATION:  " .. legend.profile.reputation .. "/1000")
    janus.log(string.format("║  FEAR FACTOR: %d%% — adversaries hesitate at this level", legend.profile.fear_factor))
    janus.log(string.format("║  GHOST SCORE: %d%% — attribution success rate against us: %.0f%%",
        legend.profile.ghost_score, 100 - legend.profile.ghost_score))
    janus.log("║")
    janus.log("║  \"" .. current_stage.desc .. "\"")
    janus.log("║")
    local myth = legend.myths[math.random(#legend.myths)]
    janus.log("║  MYTH IN CIRCULATION:")
    janus.log("║  \"" .. myth .. "\"")
    janus.log("╠══ DETERRENCE PRINCIPLES ════════════════════════════════╣")
    for _, p in ipairs(legend.deterrence_principles) do
        janus.log("║  [" .. p.name .. "]")
        janus.log("║   → " .. p.effect)
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
end

-- ─── BOOT ─────────────────────────────────────────────────────────────────────
function execute()
    janus.log("╔══════════════════════════════════════════════════════╗")
    janus.log("║  JANUS LEGEND — REPUTATION ENGINE ONLINE             ║")
    janus.log("║  Mythology | Deterrence | Disinfo | Ghost Score      ║")
    janus.log("╚══════════════════════════════════════════════════════╝")
    legend.generate_codename()
    legend.status()
end

execute()
return legend
