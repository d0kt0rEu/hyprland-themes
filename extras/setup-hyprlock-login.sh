#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo ./setup-hyprlock-login.sh"
    exit 1
fi

REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo $USER)}"
USER_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

echo "=== Setting up Hyprlock as Login Screen for user: ${REAL_USER} ==="

# 1. Copy desktop wallpaper to public system directory
echo "[1/3] Copying desktop wallpaper to /usr/share/wallpapers/mountain.jpg..."
mkdir -p /usr/share/wallpapers
if [ -f "${USER_HOME}/Pictures/wallpapers/a_mountain_with_trees_and_moon.jpg" ]; then
    cp "${USER_HOME}/Pictures/wallpapers/a_mountain_with_trees_and_moon.jpg" /usr/share/wallpapers/mountain.jpg
elif [ -f "$(dirname "$0")/../themes/obsidian-pink/wallpapers/a_mountain_with_trees_and_moon.jpg" ]; then
    cp "$(dirname "$0")/../themes/obsidian-pink/wallpapers/a_mountain_with_trees_and_moon.jpg" /usr/share/wallpapers/mountain.jpg
fi
chmod 644 /usr/share/wallpapers/mountain.jpg 2>/dev/null || true

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
    cp /etc/plasmalogin.conf /etc/plasmalogin.conf.bak
fi
cat << 'EOF' > /etc/plasmalogin.conf
[Greeter][Wallpaper][org.kde.image][General]
Image=file:///usr/share/wallpapers/mountain.jpg
EOF
chmod 644 /etc/plasmalogin.conf

echo ""
echo "=== Setup Complete! ==="
echo "On your next boot:"
echo "1. The system automatically launches Hyprland."
echo "2. Hyprlock immediately locks the screen on startup."
echo "3. The very first screen you see is your beautiful Hyprlock!"
