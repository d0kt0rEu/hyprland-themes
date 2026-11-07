#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-}"
ARG="${2:-}"

case "$CMD" in
    simple|clean|minimal)
        cp -f "$HOME/.config/fastfetch/simple.jsonc" "$HOME/.config/fastfetch/config.jsonc"
        echo "✓ Fastfetch profile set to: SIMPLE (Clean 2-card layout with themed ASCII art)"
        ;;
    fancy|box|cards)
        cp -f "$HOME/.config/fastfetch/fancy.jsonc" "$HOME/.config/fastfetch/config.jsonc"
        echo "✓ Fastfetch profile set to: FANCY (Curated 3-section system box with themed ASCII art)"
        ;;
    logo)
        LOGO="${ARG:-block}"
        LOGO_FILE="$HOME/.config/fastfetch/ascii/${LOGO}.txt"
        if [ ! -f "$LOGO_FILE" ]; then
            echo "Error: Unknown logo '$LOGO'."
            echo "Available logos: block, classic, braille, blackhole, split"
            exit 1
        fi
        sed -i "s|\"source\": \".*ascii/.*\.txt\"|\"source\": \"$LOGO_FILE\"|g" "$HOME/.config/fastfetch/config.jsonc"
        sed -i "s|\"source\": \".*ascii/.*\.txt\"|\"source\": \"$LOGO_FILE\"|g" "$HOME/.config/fastfetch/simple.jsonc"
        sed -i "s|\"source\": \".*ascii/.*\.txt\"|\"source\": \"$LOGO_FILE\"|g" "$HOME/.config/fastfetch/fancy.jsonc"
        echo "✓ Active Fastfetch ASCII logo set to: $LOGO ($LOGO_FILE)"
        ;;
    *)
        echo "Usage: ff-switch [simple | fancy | logo <name>]"
        echo "Available profiles : simple, fancy"
        echo "Available ASCII art: block, classic, braille, blackhole, split"
        exit 1
        ;;
esac
