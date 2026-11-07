#!/bin/bash
action="$1"

case "$action" in
    raise)
        # Automatically unmute when adjusting volume
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 >/dev/null 2>&1
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ >/dev/null 2>&1
        ;;
    lower)
        # Automatically unmute when adjusting volume
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 >/dev/null 2>&1
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- >/dev/null 2>&1
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null 2>&1
        ;;
    mic-mute)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle >/dev/null 2>&1
        ;;
esac

# Dismiss any active pill so the newest one pops up cleanly
pkill -f "waybar.*(vol|bright|lang)-pill" 2>/dev/null

# Spawn the volume pill
waybar -c ~/.config/waybar/vol-pill.jsonc -s ~/.config/waybar/vol-pill.css > /dev/null 2>&1 &
PID=$!

sleep 1.2

if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null
fi
