#!/usr/bin/env bash
# =============================================================================
# smart-move.sh — Smart directional window movement with workspace switching
# =============================================================================
# Moves the active window left or right. When the window sits at the screen
# edge, it is sent to the adjacent workspace instead of being swapped in place.
# The move and repositioning are batched in a single dispatch so the transition
# stays smooth. Scratchpad workspaces (id < 0) always use plain swapwindow.
#
# Usage: smart-move.sh <left|right>
# Deps:  hyprctl, jq
# =============================================================================

set -euo pipefail

DIRECTION=$1

active=$(hyprctl activewindow -j)

if [ "$active" = "{}" ] || [ -z "$active" ]; then
    exit 1
fi

active_workspace=$(echo "$active" | jq '.workspace.id')
active_x=$(echo "$active" | jq '.at[0]')
active_w=$(echo "$active" | jq '.size[0]')
active_right=$((active_x + active_w))

# Scratchpad: negative workspace id — skip edge detection, just swap positions
if [ "$active_workspace" -lt 0 ]; then
    if [ "$DIRECTION" = "right" ]; then
        hyprctl dispatch 'hl.dsp.window.swap({direction="r"})'
    elif [ "$DIRECTION" = "left" ]; then
        hyprctl dispatch 'hl.dsp.window.swap({direction="l"})'
    fi
    exit 0
fi

# Calculate the left/right boundaries of all mapped windows on this workspace
all_windows=$(hyprctl clients -j | jq --arg ws "$active_workspace" \
    '.[] | select(.workspace.id == ($ws | tonumber) and .mapped == true)')

max_right=0
min_left=99999

while read -r x w; do
    if [ -n "$x" ] && [ -n "$w" ]; then
        right=$((x + w))
        [ "$right" -gt "$max_right" ] && max_right=$right
        [ "$x"     -lt "$min_left"  ] && min_left=$x
    fi
done < <(echo "$all_windows" | jq -r '"\(.at[0]) \(.size[0])"')

# Edge detection: send to adjacent workspace if at boundary, otherwise swap.
# The move and nudges are batched into one dispatch so they animate as a single action.
# Three nudges cover the most common layouts (master+stack, binary splits, etc.)
if [ "$DIRECTION" = "right" ]; then
    if [ "$active_right" -ge "$max_right" ]; then
        target_ws=$((active_workspace + 1))
        hyprctl --batch "dispatch hl.dsp.window.move({workspace=$target_ws}) ; dispatch hl.dsp.window.move({direction=\"l\"}) ; dispatch hl.dsp.window.move({direction=\"l\"}) ; dispatch hl.dsp.window.move({direction=\"l\"})"
    else
        hyprctl dispatch 'hl.dsp.window.swap({direction="r"})'
    fi
elif [ "$DIRECTION" = "left" ]; then
    if [ "$active_x" -le "$min_left" ]; then
        target_ws=$((active_workspace - 1))
        hyprctl --batch "dispatch hl.dsp.window.move({workspace=$target_ws}) ; dispatch hl.dsp.window.move({direction=\"r\"}) ; dispatch hl.dsp.window.move({direction=\"r\"}) ; dispatch hl.dsp.window.move({direction=\"r\"})"
    else
        hyprctl dispatch 'hl.dsp.window.swap({direction="l"})'
    fi
fi
