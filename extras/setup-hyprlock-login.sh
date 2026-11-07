#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo ./setup-hyprlock-login.sh [deep-sea|obsidian-pink]"
    exit 1
fi

THEME_CHOICE="${1:-deep-sea}"
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo $USER)}"
USER_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "  Setting up Hyprlock Autologin for user: ${REAL_USER}"
echo "  Theme: ${THEME_CHOICE}"
echo "=========================================================="

mkdir -p /usr/share/wallpapers

WP_FILE=""
if [[ "$THEME_CHOICE" == "deep-sea" ]]; then
    WP_FILE="/usr/share/wallpapers/deepsea.png"
    if [ -f "${USER_HOME}/Pictures/wallpapers/polyscape-everforest.png" ]; then
        cp "${USER_HOME}/Pictures/wallpapers/polyscape-everforest.png" "$WP_FILE"
    elif [ -f "${SCRIPT_DIR}/../themes/deep-sea/wallpapers/polyscape-everforest.png" ]; then
        cp "${SCRIPT_DIR}/../themes/deep-sea/wallpapers/polyscape-everforest.png" "$WP_FILE"
    fi
else
    WP_FILE="/usr/share/wallpapers/mountain.jpg"
    if [ -f "${USER_HOME}/Pictures/wallpapers/a_mountain_with_trees_and_moon.jpg" ]; then
        cp "${USER_HOME}/Pictures/wallpapers/a_mountain_with_trees_and_moon.jpg" "$WP_FILE"
    elif [ -f "${SCRIPT_DIR}/../themes/obsidian-pink/wallpapers/a_mountain_with_trees_and_moon.jpg" ]; then
        cp "${SCRIPT_DIR}/../themes/obsidian-pink/wallpapers/a_mountain_with_trees_and_moon.jpg" "$WP_FILE"
    fi
fi

if [ -f "$WP_FILE" ]; then
    chmod 644 "$WP_FILE"
    echo "[1/3] Installed greeter wallpaper: $WP_FILE"
fi

# 2. Configure autologin drop-in for plasmalogin
echo "[2/3] Configuring autologin for ${REAL_USER} directly into Hyprland..."
mkdir -p /etc/plasmalogin.conf.d
cat << EOF > /etc/plasmalogin.conf.d/autologin.conf
[Autologin]
User=${REAL_USER}
Session=hyprland-uwsm.desktop
Relogin=false
EOF
chmod 644 /etc/plasmalogin.conf.d/autologin.conf

# 3. Update fallback wallpaper in plasmalogin.conf
echo "[3/3] Updating plasmalogin background..."
if [ -f /etc/plasmalogin.conf ]; then
    cp /etc/plasmalogin.conf /etc/plasmalogin.conf.bak 2>/dev/null || true
fi
cat << EOF > /etc/plasmalogin.conf
[Greeter][Wallpaper][org.kde.image][General]
Image=file://${WP_FILE}
EOF
chmod 644 /etc/plasmalogin.conf

echo ""
echo "=== Setup Complete! ==="
echo "On your next boot:"
echo "1. The system automatically launches Hyprland."
echo "2. Hyprlock immediately locks the screen on startup."
echo "3. The very first screen you see is your beautiful Hyprlock!"
