#!/usr/bin/env bash
# =============================================================================
# screenshot-monitor.sh — Full-monitor screenshot to file
# =============================================================================
# Captures the currently focused monitor with grim and saves the PNG to
# ~/Pictures/Screenshots. Does not copy to clipboard (use screenshot-region.sh
# for clipboard + region selection).
#
# Usage: screenshot-monitor.sh   (no arguments)
# Deps:  hyprctl, jq, grim
# =============================================================================

set -euo pipefail

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

FOCUSED_MONITOR=$(hyprctl monitors -j \
    | jq -r '.[] | select(.focused == true) | .name')
FILENAME="$SCREENSHOT_DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"

grim -o "$FOCUSED_MONITOR" "$FILENAME" \
    && hyprctl notify 5 2000 "rgb(00ff99)" "  Screenshot saved!"
