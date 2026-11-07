#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root / sudo: sudo ./install.sh"
    exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Backing up current /boot/limine.conf to /boot/limine.conf.bak..."
cp /boot/limine.conf /boot/limine.conf.bak

echo "Installing solid obsidian Limine config to /boot/limine.conf..."
cp "$DIR/limine.conf" /boot/limine.conf

echo "Limine Obsidian Cyberpunk theme installed successfully (no wallpaper, pure obsidian #0f0c16)!"
