#!/bin/bash
action="$1"

case "$action" in
    up)
        brightnessctl set 5%+ >/dev/null 2>&1
        ;;
    down)
        brightnessctl set 5%- >/dev/null 2>&1
        ;;
esac

# Dismiss any active pill so the newest one pops up cleanly
pkill -f "waybar.*(vol|bright|lang)-pill" 2>/dev/null

# Spawn the brightness pill
waybar -c ~/.config/waybar/bright-pill.jsonc -s ~/.config/waybar/bright-pill.css > /dev/null 2>&1 &
PID=$!

sleep 1.2

if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null
fi
