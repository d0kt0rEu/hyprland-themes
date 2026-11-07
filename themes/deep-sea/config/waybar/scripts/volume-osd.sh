#!/usr/bin/env bash
action="$1"

case "$action" in
    raise)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 >/dev/null 2>&1
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ >/dev/null 2>&1
        ;;
    lower)
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

TOUCH_FILE="/tmp/volume_osd.touch"
date +%s > "$TOUCH_FILE"

# If vol-pill is already running, send signal to refresh volume display
if pgrep -f "waybar.*vol-pill.jsonc" >/dev/null 2>&1; then
    pkill -RTMIN+1 -f "waybar.*vol-pill.jsonc" 2>/dev/null
else
    # Spawn vol-pill
    waybar -c "$HOME/.config/waybar/vol-pill.jsonc" -s "$HOME/.config/waybar/vol-pill.css" >/dev/null 2>&1 &
fi

# Ensure watcher daemon is running
if ! pgrep -f "volume-osd-watcher" >/dev/null 2>&1; then
    (
        exec -a "volume-osd-watcher" bash -c '
        while true; do
            sleep 0.25
            if [ ! -f "/tmp/volume_osd.touch" ]; then
                break
            fi
            last=$(cat /tmp/volume_osd.touch 2>/dev/null || echo 0)
            now=$(date +%s)
            diff=$((now - last))
            if [ $diff -ge 2 ]; then
                pkill -f "waybar.*vol-pill.jsonc" 2>/dev/null
                rm -f /tmp/volume_osd.touch
                break
            fi
        done
        '
    ) >/dev/null 2>&1 &
fi
