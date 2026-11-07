#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR="$DIR/ObsidianPinkTheme.jar"
ICLS="$DIR/Obsidian_Pink.icls"

echo "=== Installing Obsidian Pink Cyberpunk Theme for JetBrains ==="
echo ""

# Scan for JetBrains configuration directories
CONFIG_DIR="$HOME/.config/JetBrains"
PLUGINS_BASE="$HOME/.local/share/JetBrains"

FOUND=0

if [ -d "$CONFIG_DIR" ]; then
    for ide_dir in "$CONFIG_DIR"/*; do
        if [ -d "$ide_dir" ]; then
            ide_name="$(basename "$ide_dir")"
            # Skip non-IDE directories like Toolbox itself if present
            if [[ "$ide_name" == "Toolbox" ]]; then
                continue
            fi

            echo "-> Found IDE configuration: $ide_name"
            
            # 1. Install Color Scheme
            mkdir -p "$ide_dir/colors"
            cp "$ICLS" "$ide_dir/colors/Obsidian_Pink.icls"
            echo "   [✓] Installed editor scheme: $ide_dir/colors/Obsidian_Pink.icls"

            # 2. Install UI Theme Plugin
            target_plugin_dir="$PLUGINS_BASE/$ide_name"
            mkdir -p "$target_plugin_dir"
            cp "$JAR" "$target_plugin_dir/ObsidianPinkTheme.jar"
            echo "   [✓] Installed plugin JAR: $target_plugin_dir/ObsidianPinkTheme.jar"

            FOUND=1
        fi
    done
fi

if [ "$FOUND" -eq 0 ]; then
    echo "No existing JetBrains IDE configs detected yet."
    echo "Once you launch RustRover or CLion for the first time, simply run this script again:"
    echo "  ~/jetbrains-theme/install.sh"
    echo ""
    echo "Or manually install in any JetBrains IDE via:"
    echo "  Settings -> Plugins -> ⚙️ Gear icon -> 'Install Plugin from Disk...' -> Select:"
    echo "  $JAR"
else
    echo ""
    echo "=== Installation Finished! ==="
    echo "To activate in your IDE:"
    echo "1. Restart the IDE (if running)."
    echo "2. Go to: Settings -> Appearance & Behavior -> Appearance -> Theme:"
    echo "   Select 'Obsidian Pink Cyberpunk'."
    echo "3. Go to: Settings -> Editor -> Color Scheme:"
    echo "   Select 'Obsidian Pink Cyberpunk'."
fi
