#!/bin/bash
# Switch to next layout across all keyboards
hyprctl switchxkblayout all next > /dev/null 2>&1

# Show the pill
exec $HOME/.config/waybar/scripts/show-pill.sh
