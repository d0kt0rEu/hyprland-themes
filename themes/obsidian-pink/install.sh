#!/usr/bin/env bash
set -e

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"

echo "=========================================================="
echo "  Applying Theme: Obsidian Pink"
echo "=========================================================="

# 1. Wallpapers
echo "[1/6] Installing wallpapers to ~/Pictures/wallpapers..."
mkdir -p "${TARGET_HOME}/Pictures/wallpapers"
cp -r "${THEME_DIR}/wallpapers/"* "${TARGET_HOME}/Pictures/wallpapers/"

# 2. Config files
echo "[2/6] Copying config files to ~/.config/..."
mkdir -p "${TARGET_HOME}/.config/hypr" \
         "${TARGET_HOME}/.config/waybar" \
         "${TARGET_HOME}/.config/rofi" \
         "${TARGET_HOME}/.config/kitty" \
         "${TARGET_HOME}/.config/fastfetch" \
         "${TARGET_HOME}/.config/fuzzel" \
         "${TARGET_HOME}/.config/gtk-3.0" \
         "${TARGET_HOME}/.config/qalculate/ui" \
         "${TARGET_HOME}/.config/environment.d" \
         "${TARGET_HOME}/.local/share/color-schemes"

cp -r "${THEME_DIR}/config/fastfetch/"* "${TARGET_HOME}/.config/fastfetch/" 2>/dev/null || true
[ -d "${THEME_DIR}/config/fuzzel" ] && cp -r "${THEME_DIR}/config/fuzzel/"* "${TARGET_HOME}/.config/fuzzel/" 2>/dev/null || true
cp -r "${THEME_DIR}/config/gtk-3.0/"* "${TARGET_HOME}/.config/gtk-3.0/" 2>/dev/null || true
cp -r "${THEME_DIR}/config/kitty/"* "${TARGET_HOME}/.config/kitty/" 2>/dev/null || true
cp -r "${THEME_DIR}/config/rofi/"* "${TARGET_HOME}/.config/rofi/" 2>/dev/null || true
cp -r "${THEME_DIR}/config/waybar/"* "${TARGET_HOME}/.config/waybar/" 2>/dev/null || true

# Qalculate config and UI overlay
if [ -f "${THEME_DIR}/config/qalculate/qalculate-gtk.cfg" ]; then
    cp "${THEME_DIR}/config/qalculate/qalculate-gtk.cfg" "${TARGET_HOME}/.config/qalculate/"
fi
if [ -f "${THEME_DIR}/config/qalculate/ui/main.ui" ]; then
    cp "${THEME_DIR}/config/qalculate/ui/main.ui" "${TARGET_HOME}/.config/qalculate/ui/"
fi

# 3. Dolphin & KDE Plasma theme integration
echo "[3/6] Setting up Dolphin & KDE color schemes..."
if [ -d "${THEME_DIR}/color-schemes" ]; then
    cp -r "${THEME_DIR}/color-schemes/"* "${TARGET_HOME}/.local/share/color-schemes/"
fi
if [ -f "${THEME_DIR}/config/kde/kdeglobals" ]; then
    cp "${THEME_DIR}/config/kde/kdeglobals" "${TARGET_HOME}/.config/kdeglobals"
fi
if [ -f "${THEME_DIR}/config/kde/dolphinrc" ]; then
    cp "${THEME_DIR}/config/kde/dolphinrc" "${TARGET_HOME}/.config/dolphinrc"
fi
cat << 'QTEOF' > "${TARGET_HOME}/.config/environment.d/10-qt.conf"
QT_QPA_PLATFORMTHEME=kde
QT_STYLE_OVERRIDE=Breeze
QTEOF

# 4. Setup Qalculate library shim & desktop wrapper
echo "[4/6] Installing Qalculate margin shim & wrapper..."
mkdir -p "${TARGET_HOME}/.local/lib" "${TARGET_HOME}/.local/bin" "${TARGET_HOME}/.local/share/applications"
if [ -f "${THEME_DIR}/config/qalculate/libqalc_fix.so" ]; then
    cp "${THEME_DIR}/config/qalculate/libqalc_fix.so" "${TARGET_HOME}/.local/lib/libqalc_fix.so"
elif [ -f "${THEME_DIR}/config/qalculate/qalc_fix.c" ] && command -v gcc >/dev/null 2>&1; then
    gcc -shared -fPIC -O2 -o "${TARGET_HOME}/.local/lib/libqalc_fix.so" "${THEME_DIR}/config/qalculate/qalc_fix.c" -ldl || true
fi
if [ -f "${THEME_DIR}/config/qalculate/qalculate-gtk" ]; then
    cp "${THEME_DIR}/config/qalculate/qalculate-gtk" "${TARGET_HOME}/.local/bin/qalculate-gtk"
    chmod +x "${TARGET_HOME}/.local/bin/qalculate-gtk"
fi
if [ -f "${THEME_DIR}/config/qalculate/qalculate-gtk.desktop" ]; then
    sed "s|/home/[^/]*/|${TARGET_HOME}/|g" "${THEME_DIR}/config/qalculate/qalculate-gtk.desktop" > "${TARGET_HOME}/.local/share/applications/qalculate-gtk.desktop"
    chmod +x "${TARGET_HOME}/.local/share/applications/qalculate-gtk.desktop"
fi

# 5. Hyprland configs with proper HOME path substitution
echo "[5/6] Setting up Hyprland configs..."
sed "s|/home/[^/]*/|${TARGET_HOME}/|g" "${THEME_DIR}/config/hypr/hyprland.lua" > "${TARGET_HOME}/.config/hypr/hyprland.lua"
sed "s|/home/[^/]*/|${TARGET_HOME}/|g" "${THEME_DIR}/config/hypr/hyprpaper.conf" > "${TARGET_HOME}/.config/hypr/hyprpaper.conf"
sed "s|/home/[^/]*/|${TARGET_HOME}/|g" "${THEME_DIR}/config/hypr/hyprlock.conf" > "${TARGET_HOME}/.config/hypr/hyprlock.conf"

# 6. Reload Hyprland and Waybar if active
echo "[6/6] Reloading desktop environment..."
if pgrep -x "Hyprland" >/dev/null; then
    hyprctl reload 2>/dev/null || true
fi
if pgrep -x "waybar" >/dev/null; then
    killall -SIGUSR2 waybar 2>/dev/null || true
fi

echo "Obsidian Pink theme applied successfully!"
