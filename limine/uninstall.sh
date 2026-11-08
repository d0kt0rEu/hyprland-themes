#!/usr/bin/env bash
set -euo pipefail

BOOT_DIR="/boot/EFI/BOOT"
CONFIG_FILE="$BOOT_DIR/limine.conf"
THEME_DEST="$BOOT_DIR/themes/deepsea"

if [ "$EUID" -ne 0 ]; then
    echo "Error: Root privileges required. Please run with sudo: sudo $0"
    exit 1
fi

LATEST_BACKUP=$(ls -t "$BOOT_DIR"/limine.conf.bak.* 2>/dev/null | head -n 1 || true)

if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
    echo "Restoring backup from: $LATEST_BACKUP"
    cp -f "$LATEST_BACKUP" "$CONFIG_FILE"
else
    echo "No backup file found in $BOOT_DIR. Creating default config..."
    cat > "$CONFIG_FILE" << 'EOF'
timeout: 7

/Arch Linux
	protocol: linux
	path: boot():/vmlinuz-linux
	cmdline: root=UUID=ac65add0-8183-48fb-82a4-d490707e4914 rw acpi_enforce_resources=lax
	module_path: boot():/initramfs-linux.img
  
/Windows
	protocol: efi 
	path: guid(f9aa0639-25b7-4969-ab51-abadc6e47fa3):/EFI/Microsoft/Boot/bootmgfw.efi
EOF
fi

if [ -d "$THEME_DEST" ]; then
    rm -rf "$THEME_DEST"
    echo "Removed theme files from $THEME_DEST"
fi

echo "Limine uninstallation complete."
