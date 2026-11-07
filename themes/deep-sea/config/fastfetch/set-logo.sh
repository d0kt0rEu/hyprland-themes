#!/usr/bin/env bash
set -euo pipefail

CHOICE="${1:-}"

python3 -c "
import json, os, sys

config_path = os.path.expanduser('~/.config/fastfetch/config.jsonc')
with open(config_path) as f:
    d = json.load(f)

choice = '$CHOICE'.lower()
png_dir = os.path.expanduser('~/.config/fastfetch/pngs')
old_png_dir = os.path.expanduser('~/.config/fastfetch/png')
logo_dir = os.path.expanduser('~/.config/fastfetch/logos')

if choice in ['hyde', 'reddit', 'default']:
    d['logo']['type'] = 'kitty'
    d['logo']['source'] = f'{png_dir}/hyde_arch.png'
    msg = 'Set Fastfetch logo to: HyDE Arch Logo (from r/arch post)'
elif choice in ['hyprdots']:
    d['logo']['type'] = 'kitty'
    d['logo']['source'] = f'{png_dir}/hyprdots_arch.png'
    msg = 'Set Fastfetch logo to: HyDE Hyprdots Neon Badge'
elif choice in ['badge', 'arch-badge']:
    d['logo']['type'] = 'kitty'
    d['logo']['source'] = f'{old_png_dir}/Arch-3.png'
    msg = 'Set Fastfetch logo to: Glowing Neon Arch Badge'
elif choice in ['minimal', 'arch-minimal']:
    d['logo']['type'] = 'kitty'
    d['logo']['source'] = f'{old_png_dir}/arch-5.png'
    msg = 'Set Fastfetch logo to: Minimal Arch Emblem'
elif choice in ['nyarch', 'cat']:
    d['logo']['type'] = 'kitty'
    d['logo']['source'] = f'{old_png_dir}/nyarch.png'
    msg = 'Set Fastfetch logo to: Nyarch Cat'
elif choice in ['hyprland']:
    d['logo']['type'] = 'file'
    d['logo']['source'] = f'{logo_dir}/hyprland.txt'
    msg = 'Set Fastfetch logo to: Hyprland Braille Art'
elif choice in ['arch-ascii', 'ascii']:
    d['logo']['type'] = 'file'
    d['logo']['source'] = f'{logo_dir}/cyber_arch.txt'
    msg = 'Set Fastfetch logo to: Japanese Cyber Arch (ASCII)'
elif choice in ['torii']:
    d['logo']['type'] = 'file'
    d['logo']['source'] = f'{logo_dir}/torii.txt'
    msg = 'Set Fastfetch logo to: Japanese Cyber Torii Gate'
else:
    print('Usage: set-logo.sh [hyde | hyprdots | badge | minimal | nyarch | hyprland | arch-ascii | torii]')
    sys.exit(1)

with open(config_path, 'w') as f:
    json.dump(d, f, indent=2)

print(msg)
"
