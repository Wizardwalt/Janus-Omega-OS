# JanusOS — auto-start X11 on TTY1
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
    exec startx -- -nocursor 2>/dev/null
fi
