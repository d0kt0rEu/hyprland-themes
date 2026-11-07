#!/usr/bin/env bash

# Toggle off if already running
if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

THEME="$HOME/.config/rofi/cheatsheet/cheatsheet.rasi"

ENTRIES=(
    "Super + Q|Open Terminal (Kitty)|[Apps]|kitty"
    "Super + E|Open File Manager (Dolphin)|[Apps]|dolphin"
    "Super + R|Application Launcher (Rofi)|[Apps]|$HOME/.config/rofi/launcher.sh"
    "Super + =|Quick Calculator Bar (Rofi)|[Apps]|rofi -show qalc"
    "Super + K|Keybindings Cheatsheet|[Apps]|"
    "Super + Space|Switch Keyboard Layout (OSD)|[System]|$HOME/.config/waybar/scripts/lang-osd.sh"
    "Super + B|Toggle Topbar (Hide/Unhide Waybar)|[System]|killall -SIGUSR1 waybar"
    "Super + M|System Power Menu|[System]|$HOME/.config/rofi/powermenu/type-2/powermenu.sh"
    "Click Battery|Power Plans & Battery Options|[System]|$HOME/.config/rofi/power/power.sh"
    "Super + C|Close Focused Window|[Window]|hyprctl dispatch killactive"
    "Super + T|Toggle Floating (Single Window)|[Window]|hyprctl dispatch togglefloating"
    "Super + V|Toggle Floating (All on Workspace)|[Window]|"
    "Super + F|Toggle Fullscreen (Maximized)|[Window]|hyprctl dispatch fullscreen 1"
    "Super + P|Toggle Pseudo Tiling|[Window]|hyprctl dispatch pseudo"
    "Super + J|Toggle Split (Dwindle)|[Window]|hyprctl dispatch togglesplit"
    "Super + Arrows|Move Window Focus|[Window]|"
    "Super + Shift + Arrows|Resize Window (Hold to repeat)|[Window]|"
    "Super + Left Mouse Drag|Move Floating Window|[Window]|"
    "Super + Right Mouse Drag|Resize Floating Window|[Window]|"
    "Ctrl + Alt + Up|Increase Opacity (+Solid, Hold)|[Transparency]|"
    "Ctrl + Alt + Down|Decrease Opacity (+Glass, Hold)|[Transparency]|"
    "Ctrl + Alt + Return|Reset Active Window Opacity (100%)|[Transparency]|"
    "Ctrl + Alt + \\|Reset All Windows Opacity (100%)|[Transparency]|"
    "Super + 1 .. 9|Switch to Workspace 1 - 9|[Workspace]|"
    "Super + Shift + 1 .. 9|Move Active Window to Workspace 1 - 9|[Workspace]|"
    "Super + S|Toggle Scratchpad (Magic WS)|[Workspace]|hyprctl dispatch togglespecialworkspace magic"
    "Super + Shift + S|Move Window to Scratchpad|[Workspace]|hyprctl dispatch movetoworkspace special:magic"
    "Super + Mouse Scroll|Cycle Next / Previous Workspace|[Workspace]|"
    "Print|Screenshot Area to Clipboard|[Screenshot]|grim -g \"\$(slurp)\" - | wl-copy"
    "Shift + Print|Screenshot Area to Editor (Swappy)|[Screenshot]|grim -g \"\$(slurp)\" - | swappy -f -"
    "Volume Up / Down|Raise / Lower Audio (Hold to repeat)|[Audio]|"
    "Volume Mute / Mic Mute|Mute Audio Sink / Microphone|[Audio]|"
    "Brightness Up / Down|Screen Brightness (Hold to repeat)|[Hardware]|"
    "Media Play / Pause / Next|Media Player Controls (playerctl)|[Media]|"
)

# Build markup lines
MENU_LINES=()
for item in "${ENTRIES[@]}"; do
    IFS="|" read -r key desc cat cmd <<< "$item"
    pad_key=$(printf "%-26s" "$key")
    pad_desc=$(printf "%-42s" "$desc")
    clean_key="${pad_key//&/&amp;}"
    clean_desc="${pad_desc//&/&amp;}"
    line="<span weight='bold' color='#ff79c6'>${clean_key}</span> <span color='#6272a4'>│</span> <span color='#f1eef8'>${clean_desc}</span> <span color='#bd93f9'>${cat}</span>"
    MENU_LINES+=("$line")
done

CHOICE=$(printf '%s\n' "${MENU_LINES[@]}" | rofi -dmenu -i -p "󰌌 Shortcuts" -theme "$THEME" -markup-rows)

if [ -z "$CHOICE" ]; then
    exit 0
fi

# Execute corresponding command if available
for item in "${ENTRIES[@]}"; do
    IFS="|" read -r key desc cat cmd <<< "$item"
    if [[ "$CHOICE" == *"$key"* && -n "$cmd" ]]; then
        eval "$cmd" &
        break
    fi
done
