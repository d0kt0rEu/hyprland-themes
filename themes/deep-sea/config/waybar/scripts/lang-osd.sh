#!/bin/bash
# Switch to next layout across all keyboards
hyprctl switchxkblayout all next > /dev/null 2>&1

# Show the pill
exec /home/d0kt0r/.config/waybar/scripts/show-pill.sh
