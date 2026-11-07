#!/usr/bin/env bash

# Toggle: If rofi is already running, close it and exit
if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

# Current Theme
dir="$HOME/.config/rofi/powermenu/type-2"
theme='style-5'

# CMDs
uptime="$(uptime -p | sed -e 's/up //g')"
host="$(uname -n)"

# Options
shutdown=''
reboot=''
lock='󰌾'
suspend='󰒲'
logout='󰍃'
yes=''
no=''

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "Uptime: $uptime" \
		-mesg "Uptime: $uptime" \
		-hover-select \
		-me-select-entry '' \
		-me-accept-entry MousePrimary \
		-theme "${dir}/${theme}.rasi"
}

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px; x-offset: 0px; y-offset: 0px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-hover-select \
		-me-select-entry '' \
		-me-accept-entry MousePrimary \
		-theme "${dir}/${theme}.rasi"
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
execute_logout() {
	if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
		openbox --exit
	elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
		bspc quit
	elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
		i3-msg exit
	elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
		qdbus org.kde.ksmserver /KSMServer logout 0 0 0
	elif [[ "$DESKTOP_SESSION" == "xfce" ]]; then
		killall xfce4-session
	else
		hyprctl dispatch 'hl.dsp.exit()' 2>/dev/null || loginctl terminate-session "${XDG_SESSION_ID:-}" 2>/dev/null || pkill -u "$USER" -x Hyprland
	fi
}

execute_lock() {
	if command -v hyprlock >/dev/null 2>&1; then
		hyprlock
	elif command -v swaylock >/dev/null 2>&1; then
		swaylock
	elif command -v gtklock >/dev/null 2>&1; then
		gtklock
	else
		hyprctl notify 3 5000 "rgb(ff2a85)" "Screen lock requires hyprlock: sudo pacman -S hyprlock"
	fi
}

execute_suspend() {
	command -v mpc >/dev/null 2>&1 && mpc -q pause
	command -v amixer >/dev/null 2>&1 && amixer set Master mute
	systemctl suspend
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		selected="$(confirm_exit)"
		if [[ "$selected" == "$yes" ]]; then
			systemctl poweroff
		fi
        ;;
    $reboot)
		selected="$(confirm_exit)"
		if [[ "$selected" == "$yes" ]]; then
			systemctl reboot
		fi
        ;;
    $logout)
		selected="$(confirm_exit)"
		if [[ "$selected" == "$yes" ]]; then
			execute_logout
		fi
        ;;
    $lock)
		execute_lock
        ;;
    $suspend)
		execute_suspend
        ;;
esac
