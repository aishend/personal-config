#!/usr/bin/env bash
# =============================================================================
# scratchpad-toggle.sh — Smart scratchpad send/retrieve
# =============================================================================
# If the focused window is inside special:global, moves it back to whichever
# regular workspace is currently visible underneath and closes the scratchpad.
# Otherwise, sends the focused window into special:global.
#
# Note: hyprctl dispatch in Hyprland v0.55+ Lua mode evaluates arguments as
# Lua expressions — hl.dsp.* syntax is required instead of plain dispatcher
# names to avoid colon-in-identifier parse errors (e.g. special:global).
#
# Usage: scratchpad-toggle.sh   (no arguments)
# Deps:  hyprctl, jq
# =============================================================================

set -euo pipefail

active_window=$(hyprctl activewindow -j)

if [[ -z "$active_window" || "$active_window" == "{}" ]]; then
    exit 0
fi

workspace=$(echo "$active_window" | jq -r '.workspace.name')
address=$(echo "$active_window" | jq -r '.address')

if [[ "$workspace" == special:* ]]; then
    hyprctl dispatch 'hl.dsp.window.move({workspace = "e+0"})'
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("global")'
    hyprctl dispatch "hl.dsp.focus({window = \"address:${address}\"})"
else
    hyprctl dispatch 'hl.dsp.window.move({workspace = "special:global"})'
fi
