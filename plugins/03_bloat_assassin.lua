janus.log(">>> [OPS] BLOAT REMOVAL")
local apps = {"com.facebook.katana", "com.samsung.android.bixby.agent", "com.google.android.videos"}
for _, app in ipairs(apps) do
    janus.log("Killing " .. app)
    janus.shell("pm uninstall -k --user 0 " .. app)
end
