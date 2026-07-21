#!/bin/bash
# JanusOS X11 init — starts Openbox + JanusOS browser kiosk

# Disable screensaver and power management
xset s off
xset -dpms
xset s noblank

# Start window manager (background, minimal)
openbox &

# Start ADB server
adb start-server &

# Start the JanusOS web server (if not already started by systemd)
if ! systemctl is-active --quiet janus-web.service 2>/dev/null; then
    cd /opt/janus && ./janus-web &
fi

# Wait for server to be ready
sleep 3

# Launch Chromium in kiosk mode
exec /usr/bin/chromium \
    --kiosk \
    --no-sandbox \
    --disable-gpu-sandbox \
    --no-first-run \
    --noerrdialogs \
    --disable-infobars \
    --disable-session-crashed-bubble \
    --disable-features=TranslateUI \
    --overscroll-history-navigation=0 \
    http://localhost:5000
