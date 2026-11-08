#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR_SOURCE="$SCRIPT_DIR/deepsea-theme.jar"
ICLS_SOURCE="$SCRIPT_DIR/Deep Sea.icls"

CYAN="\033[38;2;127;187;179m"
PINE="\033[38;2;131;192;146m"
CREAM="\033[38;2;211;198;170m"
DIM="\033[38;2;79;91;88m"
RESET="\033[0m"
BOLD="\033[1m"

echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}║           JETBRAINS DEEP SEA THEME INSTALLER              ║${RESET}"
echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════════╝${RESET}"

# 1. Install into Toolbox apps
TOOLBOX_APPS="$HOME/.local/share/JetBrains/Toolbox/apps"
if [ -d "$TOOLBOX_APPS" ]; then
    for app in "$TOOLBOX_APPS"/*; do
        if [ -d "$app" ] && [ -d "$app/plugins" ]; then
            app_name=$(basename "$app")
            dest="$app/plugins/deepsea-theme/lib"
            mkdir -p "$dest"
            cp -f "$JAR_SOURCE" "$dest/"
            echo -e "${PINE}✓${RESET} Installed theme plugin into Toolbox app: ${CREAM}$app_name${RESET}"
        fi
    done
fi

# 2. Install Color Scheme and configs into ~/.config/JetBrains/*
JB_CONFIG="$HOME/.config/JetBrains"
if [ -d "$JB_CONFIG" ]; then
    for ide_dir in "$JB_CONFIG"/*; do
        if [ -d "$ide_dir" ]; then
            ide_name=$(basename "$ide_dir")
            colors_dir="$ide_dir/colors"
            options_dir="$ide_dir/options"
            mkdir -p "$colors_dir" "$options_dir"
            
            # Copy ICLS color scheme
            cp -f "$ICLS_SOURCE" "$colors_dir/Deep Sea.icls"
            
            # Configure active color scheme
            cat > "$options_dir/colors.scheme.xml" << 'EOF'
<application>
  <component name="EditorColorsManagerImpl">
    <global_color_scheme name="Deep Sea" />
  </component>
</application>
EOF

            # Configure active UI theme
            cat > "$options_dir/laf.xml" << 'EOF'
<application>
  <component name="LafManager">
    <laf class_name="com.intellij.ide.ui.laf.darcula.DarculaLaf" themeId="com.theme.deepsea.theme" />
  </component>
</application>
EOF
            echo -e "${PINE}✓${RESET} Configured Deep Sea scheme & theme for: ${CREAM}$ide_name${RESET}"
        fi
    done
fi

echo -e "\n${PINE}${BOLD}All JetBrains IDE installations updated!${RESET}\n"
