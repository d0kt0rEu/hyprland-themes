#!/usr/bin/env bash
set -e

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"

echo "=========================================================="
echo "  Applying Theme: Obsidian Pink"
echo "=========================================================="

# 1. Wallpapers
echo "[1/4] Installing wallpapers to ~/Pictures/wallpapers..."
mkdir -p "${TARGET_HOME}/Pictures/wallpapers"
cp -r "${THEME_DIR}/wallpapers/"* "${TARGET_HOME}/Pictures/wallpapers/"

# 2. Config files
echo "[2/4] Copying config files to ~/.config/..."
mkdir -p "${TARGET_HOME}/.config/hypr" \
         "${TARGET_HOME}/.config/waybar" \
         "${TARGET_HOME}/.config/rofi/colors" \
         "${TARGET_HOME}/.config/kitty" \
         "${TARGET_HOME}/.config/fastfetch" \
         "${TARGET_HOME}/.config/fuzzel" \
         "${TARGET_HOME}/.config/gtk-3.0" \
         "${TARGET_HOME}/.config/qalculate"

cp -r "${THEME_DIR}/config/fastfetch/"* "${TARGET_HOME}/.config/fastfetch/" 2>/dev/null || true
cp -r "${THEME_DIR}/config/fuzzel/"* "${TARGET_HOME}/.config/fuzzel/" 2>/dev/null || true
cp -r "${THEME_DIR}/config/gtk-3.0/"* "${TARGET_HOME}/.config/gtk-3.0/" 2>/dev/null || true
cp -r "${THEME_DIR}/config/kitty/"* "${TARGET_HOME}/.config/kitty/" 2>/dev/null || true
cp -r "${THEME_DIR}/config/qalculate/"* "${TARGET_HOME}/.config/qalculate/" 2>/dev/null || true
cp -r "${THEME_DIR}/config/rofi/"* "${TARGET_HOME}/.config/rofi/" 2>/dev/null || true
cp -r "${THEME_DIR}/config/waybar/"* "${TARGET_HOME}/.config/waybar/" 2>/dev/null || true

# 3. Hyprland configs with proper HOME path substitution
echo "[3/4] Setting up Hyprland configs..."
cp "${THEME_DIR}/config/hypr/hyprland.lua" "${TARGET_HOME}/.config/hypr/hyprland.lua"
sed "s|/home/[^/]*/|${TARGET_HOME}/|g" "${THEME_DIR}/config/hypr/hyprpaper.conf" > "${TARGET_HOME}/.config/hypr/hyprpaper.conf"
sed "s|/home/[^/]*/|${TARGET_HOME}/|g" "${THEME_DIR}/config/hypr/hyprlock.conf" > "${TARGET_HOME}/.config/hypr/hyprlock.conf"

# 4. Reload Hyprland and Waybar if active
echo "[4/4] Reloading desktop environment..."
if pgrep -x "Hyprland" >/dev/null; then
    hyprctl reload 2>/dev/null || true
fi
if pgrep -x "waybar" >/dev/null; then
    killall -SIGUSR2 waybar 2>/dev/null || true
fi

echo "Obsidian Pink theme applied successfully!"
