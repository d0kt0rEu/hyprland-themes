#!/bin/bash
# Kill any currently visible pill process
pkill -f "waybar.*lang-pill" 2>/dev/null

# Start the pill waybar overlay
waybar -c ~/.config/waybar/lang-pill.jsonc -s ~/.config/waybar/lang-pill.css > /dev/null 2>&1 &
PID=$!

# Let it display for 1.3 seconds
sleep 1.3

# Cleanly close the pill process
if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null
fi
