#!/usr/bin/env bash
# =============================================================================
# audio-menu.sh — Audio output selector
# =============================================================================
# Lists available PipeWire/PulseAudio sinks via pactl and lets the user pick
# one with Rofi. Switches the default sink and moves all active streams to it.
#
# Usage: audio-menu.sh   (no arguments)
# Deps:  pactl, rofi
# =============================================================================

THEME="$HOME/.config/rofi/themes/default.rasi"

default=$(pactl get-default-sink)

# Build sink list: ● active sink, ○ available
entries=$(pactl list sinks | awk '
    /^\s*Name:/        { name = $2 }
    /^\s*Description:/ { desc = substr($0, index($0,$2)); print name "|" desc }
' | while IFS='|' read -r name desc; do
    if [ "$name" = "$default" ]; then
        echo "● $desc  [$name]"
    else
        echo "○ $desc  [$name]"
    fi
done)

selected=$(echo "$entries" | rofi -dmenu -p "Audio Output" -theme "$THEME" 2>/dev/null)
[ -z "$selected" ] && exit

sink=$(echo "$selected" | grep -oP '\[\K[^\]]+')
pactl set-default-sink "$sink"

# Move all active streams to the new sink
pactl list short sink-inputs | awk '{print $1}' | while read -r id; do
    pactl move-sink-input "$id" "$sink"
done
