#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "  Hyprland Quick Restore Utility"
echo "=========================================================="

if [ "$1" == "--full" ] || [ "$1" == "--all" ]; then
    bash "${REPO_DIR}/install.sh" --all
elif [ "$1" == "--theme" ]; then
    bash "${REPO_DIR}/install.sh" --theme "${2:-obsidian-pink}"
else
    # Default behavior: restores only functional scripts & keybinds without touching theme
    echo "Restoring functional scripts & keybindings..."
    echo "(Themes, colors, CSS, and wallpapers are preserved!)"
    echo ""
    bash "${REPO_DIR}/common/install-scripts.sh"
    echo ""
    echo "Tip: Run './restore.sh --full' if you want to restore the entire visual theme as well."
fi
