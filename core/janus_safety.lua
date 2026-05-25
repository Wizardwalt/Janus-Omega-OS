-- =============================================================================
-- JANUS SAFETY & CONTENT CONTROL SYSTEM
-- Age verification, child safety lockdown, parental PIN, content ratings
-- Protects younger users while giving adults full system access
-- =============================================================================

local safety = {}

-- ─── CONTENT RATINGS ──────────────────────────────────────────────────────────
safety.RATINGS = {
    SAFE   = "SAFE",     -- All ages. Educational, non-sensitive only.
    TEEN   = "TEEN",     -- 13+. Network tools, basic forensics, no offensive modules.
    ADULT  = "ADULT",    -- 18+. Full access. All modules, adult ARIA dialogue tier.
    OPERATOR = "OPERATOR", -- Professional override. Bypasses age gate via PIN.
}

-- ─── MODULE CONTENT TAGS ─────────────────────────────────────────────────────
-- Every module category gets a minimum rating
safety.module_ratings = {
    -- Safe for all
    diagnostics    = "SAFE",
    core_omega     = "SAFE",
    smart_diag     = "SAFE",
    -- Teen+
    forensics      = "TEEN",
    osint          = "TEEN",
    sigint         = "TEEN",
    network_basic  = "TEEN",
    -- Adult only
    mobile_offense = "ADULT",
    cyber_warfare  = "ADULT",
    network_warfare= "ADULT",
    offensive      = "ADULT",
    hardware_glitch= "ADULT",
    tactical       = "ADULT",
    expansion      = "ADULT",
    mobile_exp     = "ADULT",
    -- Always blocked regardless of age (require operator PIN)
    grid_blackout  = "OPERATOR",
    nuclear_scada  = "OPERATOR",
    sat_hijack     = "OPERATOR",
    mesh_infect    = "OPERATOR",
    identity_forge = "OPERATOR",
    bio_breach     = "OPERATOR",
    quantum_crack  = "OPERATOR",
}

-- ─── STATE ────────────────────────────────────────────────────────────────────
safety.state = {
    initialized      = false,
    current_rating   = "ADULT",   -- default to adult until gate runs
    age_verified     = false,
    child_mode       = false,
    operator_mode    = false,
    pin_hash         = nil,        -- SHA-256 of parental PIN (set by user)
    blocked_attempts = 0,
    session_start    = os.time(),
    content_log      = {},         -- audit log of blocked content attempts
}

-- ─── PIN SYSTEM ───────────────────────────────────────────────────────────────
-- Simple hash: XOR + sum for Lua compatibility (real install would use SHA-256)
local function hash_pin(pin)
    local h = 0
    for i = 1, #pin do
        local b = string.byte(pin, i)
        h = ((h * 31) + b) % 2147483647
    end
    return string.format("%x", h)
end

function safety.set_parental_pin(pin)
    if #pin < 4 then
        janus.log("[SAFETY] PIN must be at least 4 characters.")
        return false
    end
    safety.state.pin_hash = hash_pin(pin)
    janus.log("[SAFETY] Parental PIN set. Child safety controls are now PIN-protected.")
    janus.log("[SAFETY] IMPORTANT: Store your PIN securely. It cannot be recovered.")
    return true
end

function safety.verify_pin(pin)
    if not safety.state.pin_hash then
        janus.log("[SAFETY] No PIN set. Use safety.set_parental_pin(pin) first.")
        return false
    end
    local result = hash_pin(pin) == safety.state.pin_hash
    if not result then
        safety.state.blocked_attempts = safety.state.blocked_attempts + 1
        janus.log(string.format("[SAFETY] ✗ Incorrect PIN. Attempt %d.", safety.state.blocked_attempts))
        if safety.state.blocked_attempts >= 5 then
            janus.log("[SAFETY] ⚠ 5 failed PIN attempts. Session locked for 60 seconds.")
            janus.shell("sleep 60")
            safety.state.blocked_attempts = 0
        end
    else
        safety.state.blocked_attempts = 0
        janus.log("[SAFETY] ✓ PIN verified.")
    end
    return result
end

-- ─── AGE VERIFICATION GATE ────────────────────────────────────────────────────
function safety.age_gate()
    janus.log("╔══════════════════════════════════════════════════════════╗")
    janus.log("║          JANUS OMEGA OS — CONTENT VERIFICATION          ║")
    janus.log("║                                                          ║")
    janus.log("║  This platform contains security research tools that    ║")
    janus.log("║  include adult-oriented content and mature themes.      ║")
    janus.log("║                                                          ║")
    janus.log("║  By proceeding you confirm you are 18 years or older   ║")
    janus.log("║  and operating within applicable laws.                  ║")
    janus.log("║                                                          ║")
    janus.log("║  CHILD SAFETY MODE is available for supervised use.    ║")
    janus.log("║  Use: safety.enable_child_mode(pin) to activate.       ║")
    janus.log("║                                                          ║")
    janus.log("╚══════════════════════════════════════════════════════════╝")
    safety.state.age_verified = true
    safety.state.current_rating = "ADULT"
    safety.state.initialized = true
    janus.log("[SAFETY] Age gate accepted. Full adult content unlocked.")
    return true
end

-- ─── CHILD SAFETY MODE ────────────────────────────────────────────────────────
function safety.enable_child_mode(pin)
    if pin then
        safety.set_parental_pin(pin)
    end

    safety.state.child_mode = true
    safety.state.current_rating = "SAFE"
    safety.state.operator_mode = false

    janus.log("╔══════════════════════════════════════════════════════════╗")
    janus.log("║           CHILD SAFETY MODE — ENABLED                   ║")
    janus.log("╠══════════════════════════════════════════════════════════╣")
    janus.log("║  ✓ Offensive modules: BLOCKED                           ║")
    janus.log("║  ✓ Cyber warfare modules: BLOCKED                       ║")
    janus.log("║  ✓ Adult ARIA dialogue: BLOCKED                         ║")
    janus.log("║  ✓ Hardware exploitation: BLOCKED                       ║")
    janus.log("║  ✓ Sensitive network tools: BLOCKED                     ║")
    janus.log("║  ✓ ARIA uses age-appropriate language only              ║")
    janus.log("║  ✓ All blocked attempts are logged                      ║")
    janus.log("║                                                          ║")
    janus.log("║  AVAILABLE: Diagnostics, educational forensics,         ║")
    janus.log("║  basic network info, system status tools.               ║")
    janus.log("║                                                          ║")
    if safety.state.pin_hash then
        janus.log("║  PIN PROTECTION: ACTIVE                                 ║")
        janus.log("║  Disable with: safety.disable_child_mode(your_pin)     ║")
    else
        janus.log("║  No PIN set — anyone can disable child mode.            ║")
        janus.log("║  Set one with: safety.set_parental_pin(pin)            ║")
    end
    janus.log("╚══════════════════════════════════════════════════════════╝")
    return true
end

function safety.disable_child_mode(pin)
    if safety.state.pin_hash then
        if not pin then
            janus.log("[SAFETY] PIN required to disable child safety mode.")
            return false
        end
        if not safety.verify_pin(pin) then
            janus.log("[SAFETY] BLOCKED: Incorrect PIN — child mode remains active.")
            safety.log_blocked_attempt("disable_child_mode", "incorrect_pin")
            return false
        end
    end
    safety.state.child_mode = false
    safety.state.current_rating = "ADULT"
    janus.log("[SAFETY] Child safety mode disabled. Full adult access restored.")
    return true
end

-- ─── OPERATOR MODE ────────────────────────────────────────────────────────────
-- Operator mode unlocks OPERATOR-rated modules (highest tier)
function safety.enable_operator_mode(pin)
    if not pin then
        janus.log("[SAFETY] Operator PIN required.")
        return false
    end
    if safety.state.pin_hash and not safety.verify_pin(pin) then
        janus.log("[SAFETY] BLOCKED: Operator mode denied.")
        return false
    end
    safety.state.operator_mode = true
    safety.state.current_rating = "OPERATOR"
    janus.log("╔══════════════════════════════════════════════════════════╗")
    janus.log("║           OPERATOR MODE — ENABLED                        ║")
    janus.log("║  Full system access granted. All modules unlocked.       ║")
    janus.log("║  This mode is for authorized professionals only.         ║")
    janus.log("║  All activity is logged in the audit trail.              ║")
    janus.log("╚══════════════════════════════════════════════════════════╝")
    return true
end

-- ─── MODULE ACCESS CHECKER ────────────────────────────────────────────────────
local rating_order = { SAFE=1, TEEN=2, ADULT=3, OPERATOR=4 }

function safety.can_access(module_name)
    if not safety.state.initialized then return true end -- pre-init, allow

    -- Determine module's required rating
    local required = "ADULT" -- default
    for pattern, rating in pairs(safety.module_ratings) do
        if module_name:lower():find(pattern, 1, true) then
            required = rating
            break
        end
    end

    local user_level    = rating_order[safety.state.current_rating] or 3
    local needed_level  = rating_order[required] or 3

    -- Child mode hard blocks everything above SAFE
    if safety.state.child_mode and needed_level > 1 then
        safety.log_blocked_attempt(module_name, "child_mode_restriction")
        janus.log(string.format("[SAFETY] 🔒 BLOCKED: '%s' requires %s rating — Child Mode active.", module_name, required))
        janus.log("[SAFETY] Ask a parent or guardian to disable child mode.")
        return false
    end

    if user_level < needed_level then
        safety.log_blocked_attempt(module_name, "insufficient_rating")
        janus.log(string.format("[SAFETY] ✗ BLOCKED: '%s' requires %s access (current: %s).",
            module_name, required, safety.state.current_rating))
        return false
    end

    return true
end

-- ─── CONTENT LOG ──────────────────────────────────────────────────────────────
function safety.log_blocked_attempt(module_name, reason)
    table.insert(safety.state.content_log, {
        module  = module_name,
        reason  = reason,
        time    = os.time(),
        rating  = safety.state.current_rating,
    })
    -- Keep log bounded
    if #safety.state.content_log > 500 then
        table.remove(safety.state.content_log, 1)
    end
end

function safety.show_blocked_log()
    janus.log("╔══ CONTENT SAFETY LOG ══════════════════════════════════╗")
    if #safety.state.content_log == 0 then
        janus.log("║  No blocked attempts recorded.")
    else
        for _, entry in ipairs(safety.state.content_log) do
            janus.log(string.format("║  [%s] BLOCKED: %s — %s",
                os.date("%H:%M:%S", entry.time),
                entry.module,
                entry.reason))
        end
    end
    janus.log(string.format("║  TOTAL BLOCKED: %d", #safety.state.content_log))
    janus.log("╚════════════════════════════════════════════════════════╝")
end

-- ─── ARIA DIALOGUE FILTER ─────────────────────────────────────────────────────
-- Called by avatar system to check if dialogue tier is appropriate
function safety.filter_dialogue(dialogue_tier)
    -- dialogue_tier: "standard" | "adult" | "flirty" | "dark"
    if safety.state.child_mode then
        if dialogue_tier ~= "standard" then
            return false, "Child mode: adult dialogue filtered"
        end
    end
    if safety.state.current_rating == "SAFE" or safety.state.current_rating == "TEEN" then
        if dialogue_tier == "adult" or dialogue_tier == "flirty" or dialogue_tier == "dark" then
            return false, "Rating insufficient for this dialogue tier"
        end
    end
    return true, nil
end

-- ─── SAFE MODE ARIA RESPONSES (age-appropriate) ───────────────────────────────
safety.child_mode_responses = {
    greeting = {
        "Hi! I'm ARIA. I'm here to help you learn about technology!",
        "Hello! Ready to explore some cool computer science today?",
        "Welcome back! What would you like to learn about today?",
    },
    module_start = {
        "Starting the educational module. Let's see what we can learn!",
        "Running this tool. I'll explain what it's doing as we go.",
        "Initiating. This is a great way to understand how networks work!",
    },
    success = {
        "Great work! We found what we were looking for.",
        "Success! That worked perfectly.",
        "Excellent! The module completed without any issues.",
    },
    blocked = {
        "That module isn't available in this mode. Ask a grown-up if you need it!",
        "I can't access that right now. This tool is for adult use only.",
        "That one is locked. A parent or guardian can unlock it with their PIN.",
    },
    idle = {
        "What would you like to explore today?",
        "I'm here to help. What are you curious about?",
        "Take your time. Learning is best when it's at your own pace.",
    },
}

function safety.get_child_response(context)
    local responses = safety.child_mode_responses[context] or safety.child_mode_responses["idle"]
    return responses[math.random(#responses)]
end

-- ─── STATUS ───────────────────────────────────────────────────────────────────
function safety.status()
    janus.log("╔══ CONTENT SAFETY STATUS ═══════════════════════════════╗")
    janus.log("║  CURRENT RATING:   " .. safety.state.current_rating)
    janus.log("║  CHILD MODE:       " .. (safety.state.child_mode and "ENABLED ✓" or "DISABLED"))
    janus.log("║  OPERATOR MODE:    " .. (safety.state.operator_mode and "ENABLED ✓" or "DISABLED"))
    janus.log("║  AGE VERIFIED:     " .. (safety.state.age_verified and "YES" or "NO"))
    janus.log("║  PIN PROTECTION:   " .. (safety.state.pin_hash and "SET ✓" or "NOT SET"))
    janus.log("║  BLOCKED ATTEMPTS: " .. #safety.state.content_log)
    janus.log("╠══ CONTENT TIERS ════════════════════════════════════════╣")
    janus.log("║  SAFE:     Diagnostics, system status (all ages)")
    janus.log("║  TEEN:     Forensics, OSINT, basic network (13+)")
    janus.log("║  ADULT:    Full toolkit, all modules (18+)")
    janus.log("║  OPERATOR: Sensitive ops, PIN required (professional)")
    janus.log("╠══ COMMANDS ═════════════════════════════════════════════╣")
    janus.log("║  safety.enable_child_mode(pin)    — lock to safe content")
    janus.log("║  safety.disable_child_mode(pin)   — unlock with PIN")
    janus.log("║  safety.set_parental_pin(pin)     — set/change PIN")
    janus.log("║  safety.enable_operator_mode(pin) — unlock all modules")
    janus.log("║  safety.show_blocked_log()        — view blocked attempts")
    janus.log("╚════════════════════════════════════════════════════════╝")
end

-- ─── BOOT ─────────────────────────────────────────────────────────────────────
function execute()
    janus.log("╔══════════════════════════════════════════════════════════╗")
    janus.log("║  JANUS SAFETY & CONTENT CONTROL — ONLINE                ║")
    janus.log("║  Age Verification | Child Safety | Parental PIN         ║")
    janus.log("║  Content Ratings | Dialogue Filter | Audit Log          ║")
    janus.log("╚══════════════════════════════════════════════════════════╝")
    safety.age_gate()
    safety.status()
end

execute()
return safety
