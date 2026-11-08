#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOT_DIR="/boot/EFI/BOOT"
THEME_DEST="$BOOT_DIR/themes/deepsea"
CONFIG_FILE="$BOOT_DIR/limine.conf"
SOURCE_CONFIG="$SCRIPT_DIR/limine.conf"
WALLPAPERS_DIR="$SCRIPT_DIR/wallpapers"

CYAN="\033[38;2;127;187;179m"
PINE="\033[38;2;131;192;146m"
CREAM="\033[38;2;211;198;170m"
DIM="\033[38;2;79;91;88m"
RESET="\033[0m"
BOLD="\033[1m"

if [ "$EUID" -ne 0 ]; then
    echo -e "\033[31m${BOLD}Error: Root privileges required.${RESET}"
    echo -e "Please run with sudo: ${CYAN}sudo $0${RESET}"
    exit 1
fi

if [ ! -d "$BOOT_DIR" ]; then
    echo -e "\033[31m${BOLD}Error: $BOOT_DIR does not exist.${RESET}"
    exit 1
fi

WP_CHOICE="${1:-polyscape}"
case "$WP_CHOICE" in
    polyscape|waves|circuit|black-turq)
        ;;
    *)
        echo -e "${DIM}Unknown wallpaper option '$WP_CHOICE'. Defaulting to 'polyscape'.${RESET}"
        WP_CHOICE="polyscape"
        ;;
esac

echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}║           LIMINE DEEP SEA THEME INSTALLER                 ║${RESET}"
echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════════╝${RESET}"

# 1. Backup existing configuration
if [ -f "$CONFIG_FILE" ]; then
    BACKUP_FILE="$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo -e "${PINE}✓${RESET} Backed up existing config to: ${CREAM}$BACKUP_FILE${RESET}"
fi

# 2. Copy wallpapers
echo -e "${PINE}●${RESET} Installing wallpapers to: ${CREAM}$THEME_DEST${RESET}..."
mkdir -p "$THEME_DEST"
cp -r "$WALLPAPERS_DIR"/* "$THEME_DEST/"
chmod -R 644 "$THEME_DEST"/*

# 3. Prepare config with chosen wallpaper
echo -e "${PINE}●${RESET} Applying config with active wallpaper: ${CYAN}${BOLD}$WP_CHOICE.png${RESET}..."
sed "s|polyscape.png|$WP_CHOICE.png|g" "$SOURCE_CONFIG" > "$CONFIG_FILE"
chmod 644 "$CONFIG_FILE"

echo -e "\n${PINE}${BOLD}✓ Limine Deep Sea Theme installed successfully!${RESET}"
echo -e "  ${DIM}Resolution:${RESET} ${CREAM}1920x1080${RESET}"
echo -e "  ${DIM}Background:${RESET} ${CREAM}boot():/EFI/BOOT/themes/deepsea/$WP_CHOICE.png${RESET}"
echo -e "  ${DIM}Accent:${RESET}     ${CYAN}#7fbbb3 (Deep Sea Cyan)${RESET}"
echo -e "  ${DIM}Help/Count:${RESET} ${PINE}#83c092 (Pine Green)${RESET}\n"
echo -e "${DIM}Next time you boot or reboot, you will see your new theme.${RESET}"
