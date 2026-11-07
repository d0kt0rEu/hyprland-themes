#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"
BACKUP_DIR="${TARGET_HOME}/.config/hyprland-dotfiles-backup-$(date +%Y%m%d_%H%M%S)"

print_banner() {
    cat << "EOF"
  _    _                  _                 _   _______ _                                
 | |  | |                | |               | | |__   __| |                               
 | |__| |_   _ _ __  _ __| | __ _ _ __   __| |    | |  | |__   ___ _ __ ___   ___  ___ 
 |  __  | | | | '_ \| '__| |/ _` | '_ \ / _` |    | |  | '_ \ / _ \ '_ ` _ \ / _ \/ __|
 | |  | | |_| | |_) | |  | | (_| | | | | (_| |    | |  | | | |  __/ | | | | |  __/\__ \
 |_|  |_|\__, | .__/|_|  |_|\__,_|_| |_|\__,_|    |_|  |_| |_|\___|_| |_| |_|\___||___/
          __/ | |                                                                        
         |___/|_|                                                                        
EOF
    echo "================================================================================"
    echo "  Modular Arch Linux Hyprland Desktop Environment & Themes"
    echo "  Repository: https://github.com/d0kt0rEu/hyprland-themes"
    echo "================================================================================"
}

backup_configs() {
    echo "Creating backup of existing configs in ${BACKUP_DIR}..."
    mkdir -p "${BACKUP_DIR}"
    for dir in hypr waybar rofi kitty fastfetch fuzzel gtk-3.0 qalculate; do
        if [ -d "${TARGET_HOME}/.config/${dir}" ]; then
            mkdir -p "${BACKUP_DIR}/${dir}"
            cp -r "${TARGET_HOME}/.config/${dir}/"* "${BACKUP_DIR}/${dir}/" 2>/dev/null || true
        fi
    done
    echo "✓ Backup completed."
}

install_scripts_only() {
    echo "Installing common functional scripts & keybinds..."
    bash "${REPO_DIR}/common/install-scripts.sh"
}

install_theme() {
    local theme_name="${1:-deep-sea}"
    local theme_path="${REPO_DIR}/themes/${theme_name}"

    if [ ! -d "${theme_path}" ]; then
        echo "Error: Theme '${theme_name}' not found in ${REPO_DIR}/themes/!"
        echo "Available themes:"
        ls -1 "${REPO_DIR}/themes"
        exit 1
    fi

    echo "Installing theme: ${theme_name}..."
    bash "${theme_path}/install.sh"
}

install_extras() {
    echo "=========================================================="
    echo "  Installing Extras (JetBrains, Limine, Hyprlock Login)"
    echo "=========================================================="

    if [ -d "${REPO_DIR}/extras/jetbrains-theme" ]; then
        echo "[1/3] Setting up JetBrains IDE Themes..."
        bash "${REPO_DIR}/extras/jetbrains-theme/install.sh" || true
    fi

    if [ -d "${REPO_DIR}/extras/limine-theme" ]; then
        echo "[2/3] Setting up Limine Bootloader Themes..."
        echo "Limine configurations are available in extras/limine-theme/."
        echo "Run 'sudo bash extras/limine-theme/install.sh' if you use Limine bootloader."
    fi

    echo "[3/3] Setup Hyprlock as lockscreen/login helper script available at:"
    echo "      extras/setup-hyprlock-login.sh (Run with sudo to apply)"
}

usage() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --all [theme]         Perform a complete installation (default: deep-sea)"
    echo "  --theme <name>        Install a specific theme (e.g., deep-sea, obsidian-pink)"
    echo "  --scripts-only        Install common scripts & keybinds without touching your theme"
    echo "  --extras              Install IDE and bootloader extras"
    echo "  --help                Show this help message"
    echo ""
    echo "Run without options for the interactive selection menu."
}

# Non-interactive CLI flags
if [ "$1" == "--all" ]; then
    print_banner
    backup_configs
    install_scripts_only
    SELECTED_THEME="${2:-deep-sea}"
    install_theme "$SELECTED_THEME"
    install_extras
    exit 0
elif [ "$1" == "--scripts-only" ]; then
    print_banner
    install_scripts_only
    exit 0
elif [ "$1" == "--theme" ]; then
    print_banner
    backup_configs
    install_scripts_only
    install_theme "$2"
    exit 0
elif [ "$1" == "--extras" ]; then
    print_banner
    install_extras
    exit 0
elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Interactive Menu
print_banner
echo ""
echo "Select installation mode:"
echo "  [1] Full Installation (Select theme + common scripts & keybindings)"
echo "  [2] Scripts & Keybinds Only (Preserves your existing theme, CSS & wallpapers)"
echo "  [3] Theme Only (Choose from available themes)"
echo "  [4] Extras Only (JetBrains themes, Limine configs)"
echo "  [5] Exit"
echo ""
read -rp "Enter choice [1-5]: " choice

case "$choice" in
    1)
        backup_configs
        install_scripts_only
        echo ""
        echo "Available themes:"
        echo "  [1] Deep Sea & Everforest (Oceanic teal & sage green aesthetics)"
        echo "  [2] Obsidian Pink (Cyberpunk neon hot pink & violet aesthetics)"
        read -rp "Select theme [1-2, default 1]: " t_choice
        if [ "$t_choice" == "2" ]; then
            SELECTED_THEME="obsidian-pink"
        else
            SELECTED_THEME="deep-sea"
        fi
        install_theme "$SELECTED_THEME"
        read -rp "Would you also like to install extras (JetBrains themes, Limine, etc.)? [y/N]: " inst_extras
        if [[ "$inst_extras" =~ ^[Yy]$ ]]; then
            install_extras
        fi
        echo ""
        echo "=========================================================="
        echo "  All done! Enjoy your new Arch Hyprland setup."
        echo "=========================================================="
        ;;
    2)
        install_scripts_only
        ;;
    3)
        echo ""
        echo "Available themes:"
        themes=($(ls -1 "${REPO_DIR}/themes"))
        for i in "${!themes[@]}"; do
            echo "  [$((i+1))] ${themes[$i]}"
        done
        read -rp "Select theme [1-${#themes[@]}]: " t_choice
        idx=$((t_choice-1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#themes[@]}" ]; then
            backup_configs
            install_theme "${themes[$idx]}"
        else
            echo "Invalid selection."
            exit 1
        fi
        ;;
    4)
        install_extras
        ;;
    5)
        echo "Exiting without making changes."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
