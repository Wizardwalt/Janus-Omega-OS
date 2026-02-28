-- module_280_sigint.lua
-- Category: sigint
-- Module #280 of 500

function execute(target, options)
    overseer_speak("Module 280 of 500 activated: module_280_sigint")
    print("Executing module_280_sigint on target: " .. (target or "unknown"))
    log_to_blackbox({module = "module_280_sigint", status = "success"})
    return {status = "success", module = "module_280_sigint"}
end
