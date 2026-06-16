#!/usr/bin/env bash
# =============================================================================
# audio-menu.sh — Audio output selector
# =============================================================================
# Opens a Rofi menu listing all available PipeWire/PulseAudio output sinks.
# The active sink is marked with a bullet (●); others with a circle (○).
#
# On selection:
#   - Sets the chosen sink as the new default output.
#   - Moves all currently active audio streams to the new sink so playback
#     switches immediately without restarting applications.
#
# Usage: audio-menu.sh   (no arguments)
# Deps:  pactl, rofi
# =============================================================================

THEME="$HOME/.config/rofi/themes/default.rasi"

# Current default sink
default=$(pactl get-default-sink)

# Build list: "display_label TAB sink_name"
# Parses pactl's block output — Name and Description lines always appear in
# that order, so we collect them in pairs before emitting an entry.
entries=$(pactl list sinks | awk '
    /^\s*Name:/        { name = $2 }
    /^\s*Description:/ {
        desc = substr($0, index($0, $2))
        print name "|" desc
    }
' | while IFS='|' read -r name desc; do
    if [ "$name" = "$default" ]; then
        printf "●  %s\t%s\n" "$desc" "$name"
    else
        printf "○  %s\t%s\n" "$desc" "$name"
    fi
done)

[ -z "$entries" ] && exit

# Show menu (display column only)
selected=$(printf '%s' "$entries" | cut -f1 | \
    rofi -dmenu -p "󰓃  Audio Output" -theme "$THEME" 2>/dev/null)
[ -z "$selected" ] && exit

# Map selection back to the sink name
sink=$(printf '%s' "$entries" | awk -F'\t' -v sel="$selected" '$1==sel{print $2; exit}')
[ -z "$sink" ] && exit

# Switch default sink and move all active streams
pactl set-default-sink "$sink"
pactl list short sink-inputs | awk '{print $1}' | while read -r id; do
    pactl move-sink-input "$id" "$sink"
done
