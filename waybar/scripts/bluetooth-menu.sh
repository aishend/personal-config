#!/usr/bin/env bash
# =============================================================================
# bluetooth-menu.sh — Bluetooth device manager
# =============================================================================
# Opens a Rofi menu listing all paired Bluetooth devices. Each entry shows a
# connection icon, the device name, and — when available — the battery level.
#
# Actions available in the menu:
#   - Select a connected device    → disconnects from it
#   - Select a paired device       → connects to it
#   - Scan for New Devices (10 s)  → runs bluetoothctl discovery for 10 seconds,
#                                    then reopens the menu with updated results
#   - Turn Off Bluetooth           → powers down the Bluetooth controller
#
# When the Bluetooth controller is powered off, the menu offers only an
# "Enable Bluetooth" option. On confirmation, the controller is powered on and
# the menu reopens automatically.
#
# Usage: bluetooth-menu.sh   (no arguments)
# Deps:  bluetoothctl, rofi, notify-send (optional, for scan feedback)
# =============================================================================

THEME="$HOME/.config/rofi/themes/default.rasi"

rofi_menu() { rofi -dmenu -p "$1" -theme "$THEME" 2>/dev/null; }

# ── No controller ─────────────────────────────────────────────────────────────
if ! bluetoothctl show 2>/dev/null | grep -q "Controller"; then
    printf "No Bluetooth controller found" | rofi_menu "Bluetooth"
    exit
fi

# ── Controller off ────────────────────────────────────────────────────────────
if ! bluetoothctl show | grep -q "Powered: yes"; then
    choice=$(printf "  Enable Bluetooth\n󰀀  Cancel" | rofi_menu "  Bluetooth Off")
    if [[ "$choice" == *"Enable"* ]]; then
        bluetoothctl power on
        sleep 1
        exec "$0"
    fi
    exit
fi

# ── Build device list ─────────────────────────────────────────────────────────
# Each line: "display_label TAB mac_address"
# Queries bluetoothctl info once per device to check connection and battery.
dev_list=$(bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
    [ -z "$mac" ] && continue
    info=$(bluetoothctl info "$mac" 2>/dev/null)

    connected=$(echo "$info" | grep -c "Connected: yes")
    battery=$(echo "$info" | grep -oP 'Battery Percentage.*\(\K\d+')

    if [ "$connected" -gt 0 ]; then
        if [ -n "$battery" ]; then
            printf "  %-32s [%s%% 🔋]\t%s\n" "$name" "$battery" "$mac"
        else
            printf "  %-32s [connected]\t%s\n" "$name" "$mac"
        fi
    else
        printf "  %-32s\t%s\n" "$name" "$mac"
    fi
done)

# ── Static actions ────────────────────────────────────────────────────────────
# Only insert the separator rule when there are device entries above it
if [ -n "$dev_list" ]; then
    static_list=$(printf '%s\t%s\n' \
        "─────────────────────────────────────" "__sep__" \
        "  Scan for Devices (10s)"        "__scan__" \
        "  Turn Off Bluetooth"               "__off__")
    all_entries=$(printf '%s\n%s' "$dev_list" "$static_list")
else
    static_list=$(printf '%s\t%s\n' \
        "  Scan for Devices (10s)" "__scan__" \
        "  Turn Off Bluetooth"        "__off__")
    all_entries="$static_list"
fi

# ── Show menu (display column only) ──────────────────────────────────────────
selected=$(printf '%s' "$all_entries" | cut -f1 | rofi_menu "  Bluetooth")
[ -z "$selected" ] && exit

# Map the selected display string back to its action/mac token
action=$(printf '%s' "$all_entries" | awk -F'\t' -v sel="$selected" '$1==sel{print $2; exit}')

# ── Handle selection ──────────────────────────────────────────────────────────
case "$action" in
    "__sep__")
        exit
        ;;
    "__scan__")
        # Notify user and run discovery for 10 seconds
        notify-send "Bluetooth" "Scanning for devices for 10 seconds..." -t 5000 2>/dev/null
        timeout 10 bluetoothctl scan on 2>/dev/null
        sleep 1
        exec "$0"
        ;;
    "__off__")
        bluetoothctl power off
        ;;
    *)
        mac="$action"
        [ -z "$mac" ] && exit

        # Toggle connection state
        if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
            bluetoothctl disconnect "$mac"
        else
            bluetoothctl connect "$mac"
        fi
        ;;
esac
