#!/bin/bash
# Kill existing daemon instances
pkill -f "python3.*lang-daemon.py" 2>/dev/null

# Start the socket listener in background
exec /usr/bin/python3 /home/d0kt0r/.config/waybar/scripts/lang-daemon.py
