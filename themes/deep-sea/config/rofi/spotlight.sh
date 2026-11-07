#!/usr/bin/env bash

# Toggle behavior
if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

# Background click-to-close monitor
(
    sleep 0.12
    ROFI_PID=$(pgrep -x rofi | head -n 1)
    if [ -n "$ROFI_PID" ]; then
        ~/.config/rofi/wifi/click-to-close.sh "$ROFI_PID" &
    fi
) &

rofi -plugin-path ~/.local/lib/rofi -show combi
pkill -f "click-to-close.sh" 2>/dev/null || true
