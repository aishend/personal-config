#!/usr/bin/env bash
# =============================================================================
# bluetooth-menu.sh — Bluetooth device manager
# =============================================================================
# Lists paired Bluetooth devices and lets the user connect, disconnect, or
# turn off Bluetooth via Rofi. If Bluetooth is off, turns it on instead.
#
# Usage: bluetooth-menu.sh   (no arguments)
# Deps:  bluetoothctl, rofi
# =============================================================================

THEME="$HOME/.config/rofi/themes/default.rasi"

powered=$(bluetoothctl show | grep -c "Powered: yes")

if [ "$powered" -eq 0 ]; then
    bluetoothctl power on
    exit
fi

# Build device list: ● connected, ○ paired
entries=$(bluetoothctl devices | while read -r _ mac name; do
    if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        echo "● $name  [$mac]"
    else
        echo "○ $name  [$mac]"
    fi
done)

menu=$(printf "%s\n─────────────────────\n Turn Off Bluetooth\n Open Manager" "$entries")
selected=$(echo "$menu" | rofi -dmenu -p "Bluetooth" -theme "$THEME" 2>/dev/null)

[ -z "$selected" ] && exit

case "$selected" in
    *"Turn Off Bluetooth"*)
        bluetoothctl power off ;;
    *"Open Manager"*)
        setsid blueman-manager & ;;
    "●"*)
        mac=$(echo "$selected" | grep -oP '([0-9A-F]{2}:){5}[0-9A-F]{2}')
        bluetoothctl disconnect "$mac" ;;
    "○"*)
        mac=$(echo "$selected" | grep -oP '([0-9A-F]{2}:){5}[0-9A-F]{2}')
        bluetoothctl connect "$mac" ;;
esac
