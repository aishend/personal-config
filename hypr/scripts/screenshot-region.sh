#!/usr/bin/env bash
# =============================================================================
# screenshot-region.sh — Region screenshot to file and clipboard
# =============================================================================
# Lets the user select a screen region with slurp, captures it with grim,
# saves the PNG to ~/Pictures/Screenshots, and copies it to the clipboard.
# Dismisses the "global" scratchpad first if it is open and empty, so it
# does not obscure the selection overlay.
#
# Usage: screenshot-region.sh   (no arguments)
# Deps:  hyprctl, jq, grim, slurp, wl-copy
# =============================================================================

set -euo pipefail

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Dismiss the global scratchpad if it is visible but empty
scratchpad_open=$(hyprctl monitors -j \
    | jq -r '.[] | select(.focused == true) | .specialWorkspace.name')
scratchpad_count=$(hyprctl workspaces -j \
    | jq -r '.[] | select(.name == "special:global") | .windows')

if [ "$scratchpad_open" = "special:global" ] \
   && { [ -z "$scratchpad_count" ] || [ "$scratchpad_count" -eq 0 ]; }; then
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("global")'
    sleep 0.15
fi

# Launch slurp for region selection; exit silently if the user cancels
killall -9 slurp 2>/dev/null || true
SELECTION=$(slurp 2>/dev/null) || exit 0

FILENAME="$SCREENSHOT_DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"

grim -g "$SELECTION" "$FILENAME" \
    && wl-copy < "$FILENAME" \
    && hyprctl notify 5 2000 "rgb(00ff99)" "  Screenshot saved!"
