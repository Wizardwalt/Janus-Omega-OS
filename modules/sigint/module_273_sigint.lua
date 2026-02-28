-- module_273_sigint.lua
-- Category: sigint
-- Module #273 of 500

function execute(target, options)
    overseer_speak("Module 273 of 500 activated: module_273_sigint")
    print("Executing module_273_sigint on target: " .. (target or "unknown"))
    log_to_blackbox({module = "module_273_sigint", status = "success"})
    return {status = "success", module = "module_273_sigint"}
end
