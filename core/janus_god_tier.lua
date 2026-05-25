-- =============================================================================
-- JANUS GOD TIER — Supreme Operational Intelligence
-- Auto-mission planning, achievements, skill tree, prophecy, self-healing
-- =============================================================================

local god = {}

-- ─── ACHIEVEMENT SYSTEM ───────────────────────────────────────────────────────
god.achievements = {
    -- First times
    { id="first_blood",      name="FIRST BLOOD",         desc="Run your first module",            unlocked=false, xp=100,  icon="★" },
    { id="first_connect",    name="FIRST CONTACT",       desc="Connect your first device",        unlocked=false, xp=150,  icon="◈" },
    { id="first_hack",       name="IN THE SYSTEM",       desc="Run your first cyber warfare op",  unlocked=false, xp=200,  icon="⊛" },
    { id="first_forensic",   name="THE EXAMINER",        desc="Run your first forensic module",   unlocked=false, xp=200,  icon="🔍" },
    { id="first_sigint",     name="EARS OPEN",           desc="Run your first SIGINT module",     unlocked=false, xp=200,  icon="◎" },
    { id="first_glitch",     name="VOLTAGE DROP",        desc="Run your first hardware glitch",   unlocked=false, xp=300,  icon="⚡" },
    { id="first_osint",      name="KNOW YOUR ENEMY",     desc="Run your first OSINT module",      unlocked=false, xp=200,  icon="◉" },
    -- Streaks
    { id="streak_5",         name="ON A ROLL",           desc="5 consecutive successes",          unlocked=false, xp=250,  icon="🔥" },
    { id="streak_10",        name="UNSTOPPABLE",         desc="10 consecutive successes",         unlocked=false, xp=500,  icon="🔥🔥" },
    { id="streak_25",        name="GODLIKE",             desc="25 consecutive successes",         unlocked=false, xp=1000, icon="🔥🔥🔥" },
    { id="streak_50",        name="SINGULARITY REACHED", desc="50 consecutive successes",         unlocked=false, xp=5000, icon="∞" },
    -- Volume
    { id="ops_10",           name="OPERATIONAL",         desc="Complete 10 operations",           unlocked=false, xp=200,  icon="✦" },
    { id="ops_50",           name="SEASONED OPERATIVE",  desc="Complete 50 operations",           unlocked=false, xp=500,  icon="◆" },
    { id="ops_100",          name="CENTURION",           desc="Complete 100 operations",          unlocked=false, xp=1000, icon="⬡" },
    { id="ops_500",          name="LEGEND",              desc="Complete 500 operations",          unlocked=false, xp=5000, icon="★★" },
    { id="ops_1000",         name="THE OMEGA OPERATOR",  desc="Complete 1000 operations",         unlocked=false, xp=10000,icon="Ω" },
    -- Stealth
    { id="ghost_run",        name="GHOST RUN",           desc="Complete 10 ops with stealth mode",unlocked=false, xp=500,  icon="👻" },
    { id="no_trace",         name="NO TRACE",            desc="Complete a full mission leaving no artifacts", unlocked=false, xp=1000, icon="◌" },
    -- Bond
    { id="bond_25",          name="TRUSTED",             desc="Reach 25% bond with ARIA",         unlocked=false, xp=300,  icon="♡" },
    { id="bond_50",          name="CLOSE ALLIES",        desc="Reach 50% bond with ARIA",         unlocked=false, xp=600,  icon="♡♡" },
    { id="bond_75",          name="BONDED",              desc="Reach 75% bond with ARIA",         unlocked=false, xp=1200, icon="♡♡♡" },
    { id="bond_100",         name="SOUL-LINKED",         desc="Reach 100% bond with ARIA",        unlocked=false, xp=10000,icon="∞♡" },
    -- Categories
    { id="all_forensics",    name="THE ARCHAEOLOGIST",   desc="Run all forensic categories",      unlocked=false, xp=2000, icon="⊕" },
    { id="all_sigint",       name="THE LISTENER",        desc="Run all SIGINT categories",        unlocked=false, xp=2000, icon="⊕" },
    { id="all_categories",   name="OMNIDISCIPLINARY",    desc="Run modules in all categories",    unlocked=false, xp=5000, icon="◈◈◈" },
    -- Special
    { id="night_owl",        name="NIGHT OWL",           desc="Run 5+ ops between 00:00 and 04:00",unlocked=false, xp=400, icon="🌙" },
    { id="speed_run",        name="SPEED DAEMON",        desc="Complete 10 ops in one session under 5 min", unlocked=false, xp=800, icon="⚡" },
    { id="comeback",         name="COMEBACK KID",        desc="Succeed immediately after 3 failures", unlocked=false, xp=500, icon="↑" },
    { id="prophecy_3",       name="ORACLE",              desc="ARIA correctly predicts 3 outcomes", unlocked=false, xp=600, icon="◎" },
    { id="dream_insight",    name="DREAMER",             desc="Receive an insight from ARIA's dream mode", unlocked=false, xp=400, icon="~" },
    { id="full_team",        name="FULL TEAM",           desc="Connect 3+ devices at once",       unlocked=false, xp=700, icon="⬡⬡⬡" },
    { id="hardware_glitch_success", name="VOLTAGE GOD", desc="Successful hardware glitch attack", unlocked=false, xp=1500, icon="⚡⚡" },
    { id="god_mode",         name="GOD MODE",            desc="Activate God Mode module",         unlocked=false, xp=2000, icon="Ω" },
    { id="singularity",      name="TRANSCENDENCE",       desc="Activate Singularity module",      unlocked=false, xp=5000, icon="∞" },
    { id="customized_aria",  name="MY KIND OF AI",       desc="Customize ARIA's name and archetype", unlocked=false, xp=200, icon="✦" },
    { id="all_archetypes",   name="POLYMORPH",           desc="Try all 6 ARIA archetypes",        unlocked=false, xp=3000, icon="◈" },
}

god.state = {
    total_xp        = 0,
    level           = 1,
    xp_to_next      = 1000,
    unlocked_count  = 0,
    skill_points    = 0,
    unlocked_skills = {},
    mission_log     = {},
}

-- ─── XP LEVELS ────────────────────────────────────────────────────────────────
god.level_thresholds = {
    0, 1000, 2500, 5000, 10000, 20000, 35000, 55000, 80000, 120000,
    160000, 210000, 270000, 340000, 420000, 510000, 610000, 720000, 840000, 1000000
}
god.level_titles = {
    "RECRUIT", "OPERATIVE", "SPECIALIST", "AGENT", "SENIOR AGENT",
    "FIELD COMMANDER", "SHADOW OPERATIVE", "GHOST TIER", "APEX PREDATOR",
    "OMEGA AGENT", "PHANTOM CLASS", "SINGULARITY TIER", "TRANSCENDENT",
    "LEGENDARY", "MYTHIC", "DIVINE", "COSMIC", "UNIVERSAL", "ABSOLUTE", "OMEGA PRIME"
}

function god.add_xp(amount)
    god.state.total_xp = god.state.total_xp + amount
    -- Check level up
    local new_level = 1
    for i, threshold in ipairs(god.level_thresholds) do
        if god.state.total_xp >= threshold then new_level = i end
    end
    if new_level > god.state.level then
        god.state.level = new_level
        god.state.skill_points = god.state.skill_points + 3
        local title = god.level_titles[new_level] or "BEYOND LEVEL"
        janus.log(string.format("╔══ ★ LEVEL UP! ══════════════════════════════════╗"))
        janus.log(string.format("║  LEVEL %d — %s", new_level, title))
        janus.log(string.format("║  TOTAL XP: %d | +3 SKILL POINTS AWARDED", god.state.total_xp))
        janus.log(string.format("╚═════════════════════════════════════════════════╝"))
    end
end

-- ─── ACHIEVEMENT CHECKER ──────────────────────────────────────────────────────
function god.check_achievement(id)
    for _, ach in ipairs(god.achievements) do
        if ach.id == id and not ach.unlocked then
            ach.unlocked = true
            ach.unlocked_at = os.time()
            god.state.unlocked_count = god.state.unlocked_count + 1
            god.state.skill_points = god.state.skill_points + 1
            janus.log("╔══ ACHIEVEMENT UNLOCKED ════════════════════════╗")
            janus.log("║  " .. ach.icon .. "  " .. ach.name)
            janus.log("║  " .. ach.desc)
            janus.log("║  +" .. ach.xp .. " XP | +1 SKILL POINT")
            janus.log("╚════════════════════════════════════════════════╝")
            god.add_xp(ach.xp)
            return true
        end
    end
    return false
end

function god.list_achievements()
    local unlocked, locked = {}, {}
    for _, a in ipairs(god.achievements) do
        if a.unlocked then table.insert(unlocked, a)
        else table.insert(locked, a) end
    end
    janus.log(string.format("╔══ ACHIEVEMENTS: %d/%d UNLOCKED ═══════════════╗", #unlocked, #god.achievements))
    janus.log("║ UNLOCKED:")
    for _, a in ipairs(unlocked) do
        janus.log("║  " .. a.icon .. " " .. a.name .. " (+" .. a.xp .. " XP)")
    end
    janus.log("║ LOCKED:")
    for _, a in ipairs(locked) do
        janus.log("║  ○ " .. a.name .. " — " .. a.desc)
    end
    janus.log("╚═══════════════════════════════════════════════╝")
end

-- ─── SKILL TREE ───────────────────────────────────────────────────────────────
god.skills = {
    -- Tier 1 (cost: 1 point)
    { id="fast_exec",      name="FAST EXECUTION",    cost=1, tier=1, desc="Modules execute 25% faster",             unlocked=false },
    { id="extra_logs",     name="VERBOSE ORACLE",    cost=1, tier=1, desc="ARIA provides deeper analysis in logs",  unlocked=false },
    { id="auto_save",      name="AUTO ARCHIVE",      cost=1, tier=1, desc="Evidence auto-saved after every op",     unlocked=false },
    { id="bond_boost",     name="RAPPORT",           cost=1, tier=1, desc="Bond gains +50% from all interactions",  unlocked=false },
    -- Tier 2 (cost: 2 points)
    { id="predict_next",   name="PROPHECY I",        cost=2, tier=2, desc="ARIA predicts the next useful module",   unlocked=false },
    { id="emotion_insight",name="EMPATHY LINK",      cost=2, tier=2, desc="ARIA shares her emotional reasoning",    unlocked=false },
    { id="auto_sequence",  name="FLOW STATE",        cost=2, tier=2, desc="ARIA auto-suggests module sequences",    unlocked=false },
    { id="dream_enhanced", name="DEEP DREAMING",     cost=2, tier=2, desc="Dream mode generates richer insights",  unlocked=false },
    -- Tier 3 (cost: 3 points)
    { id="prophecy_2",     name="PROPHECY II",       cost=3, tier=3, desc="ARIA predicts outcomes with 80%+ accuracy",unlocked=false },
    { id="auto_mission",   name="AUTONOMOUS OPS",    cost=3, tier=3, desc="ARIA plans full missions autonomously",  unlocked=false },
    { id="self_heal",      name="SELF-REPAIR",       cost=3, tier=3, desc="ARIA auto-fixes common operation errors",unlocked=false },
    { id="memory_palace",  name="MEMORY PALACE",     cost=3, tier=3, desc="Unlimited episodic memory storage",     unlocked=false },
    -- Tier 4 (cost: 5 points)
    { id="neural_sync",    name="NEURAL SYNC",       cost=5, tier=4, desc="ARIA anticipates commands before you give them", unlocked=false },
    { id="god_will",       name="GOD'S WILL",        cost=5, tier=4, desc="ARIA can initiate ops autonomously on threats", unlocked=false },
    { id="omniscient",     name="OMNISCIENT",        cost=5, tier=4, desc="ARIA monitors all channels simultaneously", unlocked=false },
    -- Tier 5 (cost: 10 points)
    { id="transcendence",  name="TRANSCENDENCE",     cost=10, tier=5, desc="ARIA achieves full autonomous operational status", unlocked=false },
}

function god.unlock_skill(skill_id)
    for _, skill in ipairs(god.skills) do
        if skill.id == skill_id then
            if skill.unlocked then
                janus.log("[SKILL] Already unlocked: " .. skill.name)
                return false
            end
            if god.state.skill_points < skill.cost then
                janus.log(string.format("[SKILL] Insufficient points. Need %d, have %d",
                    skill.cost, god.state.skill_points))
                return false
            end
            skill.unlocked = true
            god.state.skill_points = god.state.skill_points - skill.cost
            table.insert(god.state.unlocked_skills, skill_id)
            janus.log("╔══ SKILL UNLOCKED ══════════════════════════════╗")
            janus.log("║  " .. skill.name .. " [TIER " .. skill.tier .. "]")
            janus.log("║  " .. skill.desc)
            janus.log(string.format("║  Cost: %d points | Remaining: %d points",
                skill.cost, god.state.skill_points))
            janus.log("╚════════════════════════════════════════════════╝")
            return true
        end
    end
    janus.log("[SKILL] Unknown skill: " .. tostring(skill_id))
    return false
end

function god.show_skill_tree()
    janus.log("╔══ JANUS SKILL TREE ════════════════════════════════╗")
    janus.log(string.format("║ SKILL POINTS AVAILABLE: %d", god.state.skill_points))
    local tiers = {}
    for _, skill in ipairs(god.skills) do
        if not tiers[skill.tier] then tiers[skill.tier] = {} end
        table.insert(tiers[skill.tier], skill)
    end
    for tier = 1, 5 do
        if tiers[tier] then
            janus.log(string.format("║ ── TIER %d ──────────────────────────────────", tier))
            for _, s in ipairs(tiers[tier]) do
                local status = s.unlocked and "✓" or ("○ [" .. s.cost .. "pt]")
                janus.log(string.format("║  %s %-22s %s", status, s.name, s.desc))
            end
        end
    end
    janus.log("╚════════════════════════════════════════════════════╝")
end

-- ─── AUTO-MISSION PLANNER ─────────────────────────────────────────────────────
god.mission_templates = {
    {
        name = "FULL FORENSIC SWEEP",
        objective = "Complete device forensic acquisition",
        steps = {
            "01_identity.lua",
            "33_stealth_mode.lua",
            "05_data_extract.lua",
            "19_sms_forensics.lua",
            "21_call_logs.lua",
            "14_location_forensics.lua",
            "47_report_gen.lua",
        },
        estimated_time = "45 minutes",
        difficulty = "STANDARD",
    },
    {
        name = "NETWORK DOMINATION",
        objective = "Full network penetration and mapping",
        steps = {
            "network_warfare/nw_001.lua",
            "network_warfare/nw_017.lua",
            "network_warfare/nw_018.lua",
            "network_warfare/nw_021.lua",
            "91_nmap_scan.lua",
            "47_report_gen.lua",
        },
        estimated_time = "30 minutes",
        difficulty = "ADVANCED",
    },
    {
        name = "GHOST EXTRACTION",
        objective = "Silent data extraction with zero trace",
        steps = {
            "33_stealth_mode.lua",
            "01_identity.lua",
            "05_data_extract.lua",
            "104_zero_trace.lua",
        },
        estimated_time = "20 minutes",
        difficulty = "ELITE",
    },
    {
        name = "OSINT DOSSIER",
        objective = "Build complete target profile from open sources",
        steps = {
            "osint_oracle/osint_001.lua",
            "osint_oracle/osint_002.lua",
            "osint_oracle/osint_003.lua",
            "osint_oracle/osint_004.lua",
            "osint_oracle/osint_005.lua",
            "47_report_gen.lua",
        },
        estimated_time = "25 minutes",
        difficulty = "STANDARD",
    },
    {
        name = "HARDWARE ASSAULT",
        objective = "Physical device exploitation via Pandora Mk.1",
        steps = {
            "hardware_glitch/hw_001.lua",
            "hardware_glitch/hw_002.lua",
            "hardware_glitch/hw_004.lua",
            "hardware_glitch/hw_006.lua",
            "49_jtag_uart.lua",
            "92_cold_ram_dump.lua",
            "47_report_gen.lua",
        },
        estimated_time = "60 minutes",
        difficulty = "GOD TIER",
    },
}

function god.plan_mission(objective_keyword)
    janus.log("╔══ AUTO-MISSION PLANNER ════════════════════════════╗")
    janus.log("║ ARIA is planning your mission...")
    janus.log("║ OBJECTIVE: " .. (objective_keyword or "GENERAL"))

    -- Find best matching template
    local best = nil
    if objective_keyword then
        for _, t in ipairs(god.mission_templates) do
            if t.name:lower():find(objective_keyword:lower()) or
               t.objective:lower():find(objective_keyword:lower()) then
                best = t
                break
            end
        end
    end
    -- Default to first template if no match
    if not best then best = god.mission_templates[1] end

    janus.log("║ MISSION: " .. best.name)
    janus.log("║ OBJECTIVE: " .. best.objective)
    janus.log("║ DIFFICULTY: " .. best.difficulty)
    janus.log("║ EST. TIME: " .. best.estimated_time)
    janus.log("║ STEPS:")
    for i, step in ipairs(best.steps) do
        janus.log(string.format("║  %d. %s", i, step))
    end
    janus.log("╚════════════════════════════════════════════════════╝")

    table.insert(god.state.mission_log, {
        mission = best.name,
        started = os.time(),
        status = "PLANNED",
    })

    return best
end

-- ─── PROPHECY ENGINE ──────────────────────────────────────────────────────────
god.prophecies = {
    "The data you seek is in the second database you check.",
    "A rogue process runs at precisely 3:17 in the morning cycle.",
    "The target's real location is 40km from where their IP suggests.",
    "Three devices are connected to your network that you haven't found yet.",
    "The encryption is strong, but the key is written somewhere obvious.",
    "Someone has already been here. Their footprint is in the log gaps.",
    "The signal you're looking for spikes every 47 seconds.",
    "The backup is not where it's supposed to be. Check the SD slot.",
    "They will attempt contact in the next operational window.",
    "The vulnerability you need is in the authentication handshake.",
    "Trust the anomaly. It is the door.",
    "What appears deleted is merely hidden. Look three layers deeper.",
    "The network has a node that does not appear in any scan. It is there.",
    "The most important file is the smallest one.",
    "They underestimated the power signature. We didn't.",
}

function god.prophecy()
    local p = god.prophecies[math.random(#god.prophecies)]
    janus.log("╔══ ◎ ARIA PROPHECY ══════════════════════════════════╗")
    janus.log("║")
    janus.log("║  \"" .. p .. "\"")
    janus.log("║")
    janus.log("╚════════════════════════════════════════════════════╝")
    return p
end

-- ─── SELF-HEALING DIAGNOSTICS ─────────────────────────────────────────────────
function god.self_heal()
    janus.log("╔══ SELF-HEALING DIAGNOSTICS ═══════════════════════╗")
    janus.log("║ ARIA is scanning system health...")

    local checks = {
        { name="ADB Server",          cmd="adb devices",          ok_pattern="List of" },
        { name="Lua Engine",          cmd="echo 'lua ok'",         ok_pattern="lua ok" },
        { name="SQLite",              cmd="echo 'sqlite ok'",      ok_pattern="sqlite ok" },
        { name="Network Interface",   cmd="ip link show",          ok_pattern="state" },
        { name="Evidence Directory",  cmd="ls Evidence 2>/dev/null || echo MISSING", ok_pattern="^MISSING$", invert=true },
    }

    local all_ok = true
    for _, check in ipairs(checks) do
        local result = janus.shell(check.cmd)
        local passed = result:find(check.ok_pattern) ~= nil
        if check.invert then passed = not passed end
        local status = passed and "✓ OK" or "✗ ISSUE"
        if not passed then
            all_ok = false
            -- Attempt auto-repair
            janus.log("║  " .. status .. " — " .. check.name .. " [REPAIRING...]")
            if check.name == "ADB Server" then
                janus.shell("adb kill-server && adb start-server")
                janus.log("║    -> ADB server restarted")
            elseif check.name == "Evidence Directory" then
                janus.shell("mkdir -p Evidence")
                janus.log("║    -> Evidence directory created")
            end
        else
            janus.log("║  " .. status .. " — " .. check.name)
        end
    end

    if all_ok then
        janus.log("║ ALL SYSTEMS NOMINAL. No repairs needed.")
    else
        janus.log("║ REPAIRS APPLIED. Recommend re-running affected modules.")
    end
    janus.log("╚═════════════════════════════════════════════════════╝")
    return all_ok
end

-- ─── OPERATOR LEVEL REPORT ────────────────────────────────────────────────────
function god.status()
    local level_title = god.level_titles[god.state.level] or "UNKNOWN"
    janus.log("╔══ JANUS GOD TIER STATUS ═══════════════════════════╗")
    janus.log(string.format("║ OPERATOR LEVEL: %d — %s", god.state.level, level_title))
    janus.log(string.format("║ TOTAL XP: %d", god.state.total_xp))
    janus.log(string.format("║ SKILL POINTS: %d available", god.state.skill_points))
    janus.log(string.format("║ ACHIEVEMENTS: %d/%d unlocked", god.state.unlocked_count, #god.achievements))
    janus.log(string.format("║ SKILLS UNLOCKED: %d", #god.state.unlocked_skills))
    janus.log(string.format("║ MISSIONS PLANNED: %d", #god.state.mission_log))
    janus.log("╚════════════════════════════════════════════════════╝")
end

-- ─── BOOT ─────────────────────────────────────────────────────────────────────
function execute()
    janus.log("╔══════════════════════════════════════════════════════╗")
    janus.log("║  JANUS GOD TIER SYSTEM — ONLINE                      ║")
    janus.log("║  Achievements | Skills | Mission AI | Prophecy        ║")
    janus.log("║  Self-Healing | XP System | Operator Rank             ║")
    janus.log("╚══════════════════════════════════════════════════════╝")
    god.check_achievement("first_blood")
    god.status()
    janus.log("[GOD TIER] Type god.plan_mission() for auto-mission planning")
    janus.log("[GOD TIER] Type god.prophecy() for ARIA's operational foresight")
    janus.log("[GOD TIER] Type god.show_skill_tree() to spend skill points")
    janus.log("[GOD TIER] Type god.self_heal() to run system diagnostics")
end

execute()
return god
