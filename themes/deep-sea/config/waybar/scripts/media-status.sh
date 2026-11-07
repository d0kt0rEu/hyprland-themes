#!/usr/bin/env bash
title=$(playerctl metadata title 2>/dev/null || true)
artist=$(playerctl metadata artist 2>/dev/null || true)

if [ -n "$title" ]; then
    # Escape quotes for JSON
    clean_title=$(echo "$title" | sed 's/"/\\"/g')
    clean_artist=$(echo "$artist" | sed 's/"/\\"/g')
    
    if [ ${#clean_title} -gt 24 ]; then
        display_title="${clean_title:0:22}…"
    else
        display_title="$clean_title"
    fi
    
    if [ -n "$clean_artist" ]; then
        tooltip="${clean_artist} - ${clean_title}"
    else
        tooltip="${clean_title}"
    fi
    printf '{"text":"  %s", "tooltip":"%s"}\n' "$display_title" "$tooltip"
else
    printf '{"text":" No media", "tooltip":"No media playing"}\n'
fi
