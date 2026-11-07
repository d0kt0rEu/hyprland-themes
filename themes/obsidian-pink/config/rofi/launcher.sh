#!/usr/bin/env bash

# Toggle behavior: if rofi is already open, close it
if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

rofi -show drun
