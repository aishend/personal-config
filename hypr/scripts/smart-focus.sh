#!/usr/bin/env bash
# =============================================================================
# smart-focus.sh — Smart directional focus with workspace switching
# =============================================================================
# Moves focus left or right. When the active window sits at the screen edge,
# switches to the adjacent workspace instead of moving focus within the same one.
# Scratchpad workspaces (id < 0) always use plain focus movement.
#
# Usage: smart-focus.sh <left|right>
# Deps:  hyprctl, jq
# =============================================================================

set -euo pipefail

DIRECTION=$1

active=$(hyprctl activewindow -j)

# No active window — switch workspace directly without edge detection
if [ "$active" = "{}" ] || [ -z "$active" ]; then
    if [ "$DIRECTION" = "right" ]; then
        hyprctl dispatch 'hl.dsp.focus({workspace="r+1"})'
    elif [ "$DIRECTION" = "left" ]; then
        hyprctl dispatch 'hl.dsp.focus({workspace="r-1"})'
    fi
    exit 0
fi

active_workspace=$(echo "$active" | jq '.workspace.id')
active_x=$(echo "$active" | jq '.at[0]')
active_w=$(echo "$active" | jq '.size[0]')
active_right=$((active_x + active_w))

# Scratchpad: negative workspace id — skip edge detection, just move focus
if [ "$active_workspace" -lt 0 ]; then
    if [ "$DIRECTION" = "right" ]; then
        hyprctl dispatch 'hl.dsp.focus({direction="r"})'
    elif [ "$DIRECTION" = "left" ]; then
        hyprctl dispatch 'hl.dsp.focus({direction="l"})'
    fi
    exit 0
fi

# Edge detection: switch workspace if at boundary, otherwise move focus
if [ "$DIRECTION" = "right" ]; then
    max_right=$(hyprctl clients -j | jq --arg ws "$active_workspace" \
        '[.[] | select(.workspace.id == ($ws | tonumber) and .mapped == true)
               | .at[0] + .size[0]] | max')

    # 10 px tolerance absorbs window borders and gaps so the edge feels natural
    if [ $((active_right + 10)) -ge "$max_right" ]; then
        hyprctl dispatch 'hl.dsp.focus({workspace="r+1"})'
    else
        hyprctl dispatch 'hl.dsp.focus({direction="r"})'
    fi

elif [ "$DIRECTION" = "left" ]; then
    min_left=$(hyprctl clients -j | jq --arg ws "$active_workspace" \
        '[.[] | select(.workspace.id == ($ws | tonumber) and .mapped == true)
               | .at[0]] | min')

    if [ $((active_x - 10)) -le "$min_left" ]; then
        hyprctl dispatch 'hl.dsp.focus({workspace="r-1"})'
    else
        hyprctl dispatch 'hl.dsp.focus({direction="l"})'
    fi
fi
