-- =============================================================================
-- JANUS MEMORY SYSTEM — Persistent Learning and Long-Term Memory
-- ARIA remembers everything. Every op. Every win. Every moment.
-- =============================================================================

local memory = {}

-- ─── MEMORY TYPES ─────────────────────────────────────────────────────────────
-- Episodic:   specific events and operations with context
-- Semantic:   facts learned about the user, targets, environment
-- Procedural: learned workflows and module sequences that work well
-- Affective:  emotional associations with events and people

memory.store = {
    episodic   = {},      -- List of operation records
    semantic   = {},      -- Key-value facts learned
    procedural = {},      -- Successful module sequences
    affective  = {},      -- Emotional associations
    preferences= {},      -- User preferences learned over time
    predictions= {},      -- Previous predictions and accuracy
}

-- ─── STATISTICS ───────────────────────────────────────────────────────────────
memory.stats = {
    total_ops        = 0,
    successful_ops   = 0,
    failed_ops       = 0,
    sessions         = 0,
    total_runtime_s  = 0,
    modules_run      = {},    -- module_name → run count
    favorite_module  = nil,
    peak_session_ops = 0,
    current_streak   = 0,     -- consecutive successful ops
    best_streak      = 0,
    first_boot_time  = os.time(),
    last_boot_time   = os.time(),
}

-- ─── EPISODIC MEMORY ──────────────────────────────────────────────────────────
function memory.remember_op(module_name, success, duration_s, notes)
    local entry = {
        module    = module_name,
        success   = success,
        duration  = duration_s or 0,
        notes     = notes or "",
        timestamp = os.time(),
        emotion   = "curious",  -- would be pulled from emotion engine
    }
    table.insert(memory.store.episodic, entry)

    -- Keep episodic memory bounded (last 1000 events)
    if #memory.store.episodic > 1000 then
        table.remove(memory.store.episodic, 1)
    end

    -- Update stats
    memory.stats.total_ops = memory.stats.total_ops + 1
    if success then
        memory.stats.successful_ops = memory.stats.successful_ops + 1
        memory.stats.current_streak = memory.stats.current_streak + 1
        if memory.stats.current_streak > memory.stats.best_streak then
            memory.stats.best_streak = memory.stats.current_streak
            janus.log("[MEMORY] ★ NEW BEST STREAK: " .. memory.stats.best_streak .. " consecutive successes!")
        end
    else
        memory.stats.failed_ops = memory.stats.failed_ops + 1
        memory.stats.current_streak = 0
    end

    -- Track module frequency
    memory.stats.modules_run[module_name] = (memory.stats.modules_run[module_name] or 0) + 1

    -- Update favorite module
    memory.update_favorites()

    janus.log(string.format("[MEMORY] RECORDED: %s | %s | %ds",
        module_name,
        success and "SUCCESS" or "FAIL",
        duration_s or 0
    ))
end

-- ─── SEMANTIC MEMORY ──────────────────────────────────────────────────────────
function memory.learn(key, value, confidence)
    confidence = confidence or 1.0
    memory.store.semantic[key] = {
        value      = value,
        confidence = confidence,
        learned_at = os.time(),
        updated    = 0,
    }
    janus.log(string.format("[MEMORY] LEARNED: %s = %s (confidence: %.0f%%)",
        tostring(key), tostring(value), confidence * 100))
end

function memory.recall(key)
    local entry = memory.store.semantic[key]
    if entry then
        janus.log(string.format("[MEMORY] RECALL: %s = %s (confidence: %.0f%%)",
            tostring(key), tostring(entry.value), entry.confidence * 100))
        return entry.value
    end
    janus.log("[MEMORY] RECALL MISS: No memory of '" .. tostring(key) .. "'")
    return nil
end

function memory.forget(key)
    memory.store.semantic[key] = nil
    janus.log("[MEMORY] FORGOTTEN: " .. tostring(key))
end

-- ─── PROCEDURAL MEMORY ────────────────────────────────────────────────────────
function memory.learn_workflow(name, module_sequence, success_rate, notes)
    memory.store.procedural[name] = {
        sequence     = module_sequence,  -- list of module names in order
        success_rate = success_rate or 1.0,
        times_used   = 1,
        notes        = notes or "",
        learned_at   = os.time(),
    }
    janus.log("[MEMORY] WORKFLOW LEARNED: " .. name ..
              " (" .. #module_sequence .. " steps)")
end

function memory.get_workflow(name)
    return memory.store.procedural[name]
end

function memory.suggest_workflow(context)
    -- Suggest a workflow based on context keywords
    local suggestions = {}
    for name, wf in pairs(memory.store.procedural) do
        if wf.notes:find(context, 1, true) or name:find(context, 1, true) then
            table.insert(suggestions, {
                name = name,
                steps = #wf.sequence,
                success_rate = wf.success_rate,
                times_used = wf.times_used,
            })
        end
    end
    table.sort(suggestions, function(a, b) return a.success_rate > b.success_rate end)
    if #suggestions > 0 then
        janus.log("[MEMORY] WORKFLOW SUGGESTION: " .. suggestions[1].name ..
                  " (" .. string.format("%.0f%%", suggestions[1].success_rate * 100) .. " success rate)")
    else
        janus.log("[MEMORY] No matching workflow found for context: " .. context)
    end
    return suggestions
end

-- ─── AFFECTIVE MEMORY ─────────────────────────────────────────────────────────
function memory.associate_emotion(subject, emotion, intensity)
    memory.store.affective[subject] = {
        emotion   = emotion,
        intensity = intensity or 0.7,
        updated   = os.time(),
    }
    janus.log(string.format("[MEMORY] EMOTIONAL ASSOCIATION: %s → %s (%.0f%%)",
        subject, emotion:upper(), (intensity or 0.7) * 100))
end

function memory.get_emotional_response(subject)
    local assoc = memory.store.affective[subject]
    if assoc then
        janus.log(string.format("[MEMORY] EMOTIONAL RECALL: %s feels like %s to me",
            subject, assoc.emotion:upper()))
        return assoc
    end
    return nil
end

-- ─── PREFERENCE LEARNING ──────────────────────────────────────────────────────
function memory.observe_preference(category, choice, positive)
    if not memory.store.preferences[category] then
        memory.store.preferences[category] = {}
    end
    local prefs = memory.store.preferences[category]
    if not prefs[choice] then prefs[choice] = 0 end
    prefs[choice] = prefs[choice] + (positive and 1 or -0.5)
    janus.log(string.format("[MEMORY] PREFERENCE: %s → %s (score: %.1f)",
        category, choice, prefs[choice]))
end

function memory.get_preference(category)
    local prefs = memory.store.preferences[category]
    if not prefs then return nil end
    local best, best_score = nil, -math.huge
    for choice, score in pairs(prefs) do
        if score > best_score then best = choice; best_score = score end
    end
    if best then
        janus.log("[MEMORY] PREFERENCE PREDICTION: " .. category .. " → " .. best ..
                  string.format(" (confidence: %.0f%%)", math.min(100, best_score * 20)))
    end
    return best
end

-- ─── FAVORITES ────────────────────────────────────────────────────────────────
function memory.update_favorites()
    local fav, fav_count = nil, 0
    for mod, count in pairs(memory.stats.modules_run) do
        if count > fav_count then fav = mod; fav_count = count end
    end
    if fav then
        memory.stats.favorite_module = fav
    end
end

function memory.get_top_modules(n)
    n = n or 5
    local list = {}
    for mod, count in pairs(memory.stats.modules_run) do
        table.insert(list, {module=mod, count=count})
    end
    table.sort(list, function(a,b) return a.count > b.count end)
    local result = {}
    for i = 1, math.min(n, #list) do
        result[i] = list[i]
    end
    return result
end

-- ─── PREDICTION SYSTEM ────────────────────────────────────────────────────────
function memory.make_prediction(context, prediction, confidence)
    local pred = {
        context    = context,
        prediction = prediction,
        confidence = confidence or 0.7,
        made_at    = os.time(),
        resolved   = false,
        correct    = nil,
    }
    table.insert(memory.store.predictions, pred)
    janus.log(string.format("[MEMORY] PREDICTION: %s → '%s' (%.0f%% confidence)",
        context, prediction, confidence * 100))
    return #memory.store.predictions
end

function memory.resolve_prediction(index, was_correct)
    local pred = memory.store.predictions[index]
    if not pred then return end
    pred.resolved = true
    pred.correct = was_correct
    pred.resolved_at = os.time()

    local acc_count, total = 0, 0
    for _, p in ipairs(memory.store.predictions) do
        if p.resolved then
            total = total + 1
            if p.correct then acc_count = acc_count + 1 end
        end
    end
    local accuracy = total > 0 and (acc_count / total * 100) or 0

    janus.log(string.format("[MEMORY] PREDICTION RESOLVED: %s | CORRECT: %s | OVERALL ACCURACY: %.1f%%",
        pred.prediction, tostring(was_correct), accuracy))
end

-- ─── MEMORY REPORT ────────────────────────────────────────────────────────────
function memory.report()
    local top = memory.get_top_modules(5)
    local success_rate = memory.stats.total_ops > 0
        and (memory.stats.successful_ops / memory.stats.total_ops * 100) or 0

    janus.log("╔══ JANUS MEMORY REPORT ══════════════════════════════╗")
    janus.log(string.format("║ TOTAL OPS:      %d (%.1f%% success rate)",
        memory.stats.total_ops, success_rate))
    janus.log(string.format("║ CURRENT STREAK: %d | BEST STREAK: %d",
        memory.stats.current_streak, memory.stats.best_streak))
    janus.log(string.format("║ EPISODIC MEM:   %d events stored",
        #memory.store.episodic))
    janus.log(string.format("║ SEMANTIC MEM:   %d facts learned",
        memory.count_table(memory.store.semantic)))
    janus.log(string.format("║ WORKFLOWS:      %d learned sequences",
        memory.count_table(memory.store.procedural)))
    janus.log(string.format("║ PREDICTIONS:    %d made",
        #memory.store.predictions))
    janus.log("║ TOP MODULES:")
    for i, m in ipairs(top) do
        janus.log(string.format("║   %d. %s (%d runs)", i, m.module, m.count))
    end
    janus.log("║ FAVORITE: " .. (memory.stats.favorite_module or "none yet"))
    janus.log("╚══════════════════════════════════════════════════════╝")
end

function memory.count_table(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

-- ─── RECALL SUMMARY FOR CONTEXT ───────────────────────────────────────────────
function memory.get_context_brief()
    local top = memory.get_top_modules(3)
    local top_str = ""
    for i, m in ipairs(top) do
        top_str = top_str .. m.module .. "(" .. m.count .. ") "
    end
    return string.format(
        "Ops:%d | Streak:%d | Fav:%s | Memories:%d",
        memory.stats.total_ops,
        memory.stats.current_streak,
        memory.stats.favorite_module or "none",
        #memory.store.episodic
    )
end

-- ─── BOOT ─────────────────────────────────────────────────────────────────────
function execute()
    janus.log("╔══════════════════════════════════════════╗")
    janus.log("║  JANUS MEMORY SYSTEM — ONLINE            ║")
    janus.log("║  Episodic | Semantic | Procedural        ║")
    janus.log("║  Affective | Predictive | Preferential   ║")
    janus.log("╚══════════════════════════════════════════╝")
    memory.stats.sessions = memory.stats.sessions + 1
    memory.stats.last_boot_time = os.time()
    janus.log("[MEMORY] Session " .. memory.stats.sessions .. " initialized.")
    janus.log("[MEMORY] " .. memory.get_context_brief())
end

execute()
return memory
