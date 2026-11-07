#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="${1:-all}"

echo "=== Installing JetBrains IDE Themes (Obsidian Pink & Deep Sea) ==="
echo ""

CONFIG_DIR="$HOME/.config/JetBrains"
PLUGINS_BASE="$HOME/.local/share/JetBrains"

FOUND=0

install_to_ide() {
    local ide_dir="$1"
    local ide_name="$(basename "$ide_dir")"
    
    if [[ "$ide_name" == "Toolbox" ]]; then
        return
    fi

    echo "-> Configuring IDE: $ide_name"
    mkdir -p "$ide_dir/colors"
    local target_plugin_dir="$PLUGINS_BASE/$ide_name"
    mkdir -p "$target_plugin_dir"

    # Obsidian Pink
    if [[ "$THEME_NAME" == "all" || "$THEME_NAME" == "obsidian-pink" ]]; then
        if [ -f "$DIR/Obsidian_Pink.icls" ]; then
            cp "$DIR/Obsidian_Pink.icls" "$ide_dir/colors/Obsidian_Pink.icls"
            echo "   [✓] Installed Obsidian Pink scheme: $ide_dir/colors/Obsidian_Pink.icls"
        fi
        if [ -f "$DIR/ObsidianPinkTheme.jar" ]; then
            cp "$DIR/ObsidianPinkTheme.jar" "$target_plugin_dir/ObsidianPinkTheme.jar"
            echo "   [✓] Installed Obsidian Pink plugin: $target_plugin_dir/ObsidianPinkTheme.jar"
        fi
    fi

    # Deep Sea
    if [[ "$THEME_NAME" == "all" || "$THEME_NAME" == "deep-sea" ]]; then
        if [ -f "$DIR/Deep Sea.icls" ]; then
            cp "$DIR/Deep Sea.icls" "$ide_dir/colors/Deep Sea.icls"
            echo "   [✓] Installed Deep Sea scheme: $ide_dir/colors/Deep Sea.icls"
        fi
        if [ -f "$DIR/deepsea-theme.jar" ]; then
            cp "$DIR/deepsea-theme.jar" "$target_plugin_dir/deepsea-theme.jar"
            echo "   [✓] Installed Deep Sea plugin: $target_plugin_dir/deepsea-theme.jar"
        fi
    fi

    FOUND=1
}

if [ -d "$CONFIG_DIR" ]; then
    for ide_dir in "$CONFIG_DIR"/*; do
        if [ -d "$ide_dir" ]; then
            install_to_ide "$ide_dir"
        fi
    done
fi

if [ "$FOUND" -eq 0 ]; then
    echo "No existing JetBrains IDE configs detected yet."
    echo "To manually install in any JetBrains IDE via:"
    echo "  Settings -> Plugins -> ⚙️ Gear icon -> 'Install Plugin from Disk...' -> Select:"
    echo "  $DIR/deepsea-theme.jar or $DIR/ObsidianPinkTheme.jar"
else
    echo ""
    echo "=== Installation Finished! ==="
    echo "To activate in your IDE:"
    echo "1. Restart the IDE (if running)."
    echo "2. Go to: Settings -> Appearance & Behavior -> Appearance -> Theme:"
    echo "   Select 'Deep Sea' or 'Obsidian Pink Cyberpunk'."
    echo "3. Go to: Settings -> Editor -> Color Scheme:"
    echo "   Select matching color scheme."
fi
