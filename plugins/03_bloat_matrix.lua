janus.log(">>> [OPS] BLOATWARE MATRIX (150+ APPS)")
local list = {
    "com.facebook.katana", "com.facebook.system", "com.facebook.appmanager",
    "com.samsung.android.bixby.agent", "com.samsung.android.scloud",
    "com.google.android.videos", "com.google.android.music",
    "com.microsoft.skydrive", "com.linkedin.android", "com.snapchat.android",
    "com.miui.analytics", "com.miui.msa.global"
}
for _, app in ipairs(list) do
    if string.find(janus.shell("pm list packages"), app) then
        janus.log("REMOVING: " .. app)
        janus.shell("pm uninstall -k --user 0 " .. app)
    end
end
janus.log("MATRIX COMPLETE.")
