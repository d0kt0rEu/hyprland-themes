#!/usr/bin/env bash
set -e

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"

echo "=========================================================="
echo "  Installing Common Hyprland Scripts & Keybinds"
echo "  (No themes, CSS, colors, or wallpapers are touched)"
echo "=========================================================="

# 1. Waybar scripts & menus
echo "[1/4] Installing Waybar scripts & interactive menus..."
mkdir -p "${TARGET_HOME}/.config/waybar/scripts"
mkdir -p "${TARGET_HOME}/.config/waybar/menus"

cp -r "${COMMON_DIR}/scripts/waybar/"* "${TARGET_HOME}/.config/waybar/scripts/"
cp -r "${COMMON_DIR}/scripts/waybar_menus/"* "${TARGET_HOME}/.config/waybar/menus/"
chmod +x "${TARGET_HOME}/.config/waybar/scripts/"* "${TARGET_HOME}/.config/waybar/menus/"* 2>/dev/null || true

# 2. Rofi interactive tools (cheatsheet, calc, wifi, powermenu)
echo "[2/4] Installing Rofi interactive tools..."
mkdir -p "${TARGET_HOME}/.config/rofi/cheatsheet"
mkdir -p "${TARGET_HOME}/.config/rofi/powermenu/type-2"
mkdir -p "${TARGET_HOME}/.config/rofi/wifi"

cp "${COMMON_DIR}/scripts/rofi/"*.sh "${TARGET_HOME}/.config/rofi/" 2>/dev/null || true
cp -r "${COMMON_DIR}/scripts/rofi/cheatsheet/"* "${TARGET_HOME}/.config/rofi/cheatsheet/" 2>/dev/null || true
cp -r "${COMMON_DIR}/scripts/rofi/powermenu/type-2/"* "${TARGET_HOME}/.config/rofi/powermenu/type-2/" 2>/dev/null || true
cp -r "${COMMON_DIR}/scripts/rofi/wifi/"* "${TARGET_HOME}/.config/rofi/wifi/" 2>/dev/null || true

chmod +x "${TARGET_HOME}/.config/rofi/"*.sh "${TARGET_HOME}/.config/rofi/"*/*.sh "${TARGET_HOME}/.config/rofi/"*/*.py 2>/dev/null || true

# 3. Export standalone keybind files to home directory
echo "[3/4] Exporting keybind cheatsheets and configurations to ~/..."
cp "${COMMON_DIR}/keybinds/hyprland-keybinds.conf" "${TARGET_HOME}/"
cp "${COMMON_DIR}/keybinds/hyprland-keybinds.lua" "${TARGET_HOME}/"
cp "${COMMON_DIR}/keybinds/keybinds.json" "${TARGET_HOME}/"
cp "${COMMON_DIR}/keybinds/keybinds.md" "${TARGET_HOME}/"

# 4. Instructions
echo "[4/4] Installation complete!"
echo ""
echo "Exported files in ~:"
echo "  - ~/hyprland-keybinds.conf (standard Hyprland config format)"
echo "  - ~/hyprland-keybinds.lua  (Hyprland 0.57+ Lua format)"
echo "  - ~/keybinds.json          (JSON format for easy AI transfer)"
echo "  - ~/keybinds.md            (Markdown documentation table)"
echo ""
echo "To include these keybinds in your current Hyprland setup:"
echo "  -> In hyprland.conf: add:  source = ~/hyprland-keybinds.conf"
echo "  -> In hyprland.lua:  add:  dofile(os.getenv('HOME') .. '/hyprland-keybinds.lua')"
echo ""
echo "=========================================================="
