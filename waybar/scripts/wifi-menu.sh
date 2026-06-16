#!/usr/bin/env bash
# =============================================================================
# wifi-menu.sh — Wi-Fi network manager
# =============================================================================
# Opens a Rofi menu listing available Wi-Fi networks. Each entry shows a
# signal-strength icon, the SSID, signal percentage, and a check mark (✓) for
# the currently connected network.
#
# Actions available in the menu:
#   - Select a connected network   → disconnects from it
#   - Select an unconnected network → connects (prompts for a password in a
#                                     Kitty terminal if the first attempt fails)
#   - Rescan Networks               → triggers an nmcli hardware scan, waits 3 s,
#                                     then reopens the menu with fresh results
#   - Turn Off Wi-Fi                → disables the Wi-Fi radio via nmcli
#   - Manage Connections            → opens nm-connection-editor
#
# When the Wi-Fi radio is already disabled, the menu offers only an
# "Enable Wi-Fi" option. On confirmation, the radio is enabled and the menu
# reopens automatically.
#
# Usage: wifi-menu.sh   (no arguments)
# Deps:  nmcli, rofi, kitty
# =============================================================================

THEME="$HOME/.config/rofi/themes/default.rasi"

rofi_menu() { rofi -dmenu -p "$1" -theme "$THEME" 2>/dev/null; }

# ── Radio disabled ────────────────────────────────────────────────────────────
if [ "$(nmcli radio wifi)" = "disabled" ]; then
    choice=$(printf "󰤨  Enable Wi-Fi\n󰤮  Cancel" | rofi_menu "󰤭  Wi-Fi Off")
    if [[ "$choice" == *"Enable"* ]]; then
        nmcli radio wifi on
        sleep 1
        exec "$0"
    fi
    exit
fi

# ── Build network list ────────────────────────────────────────────────────────
# Each line: "display_label TAB ssid"
# Uses awk to safely reassemble SSIDs that contain ':', since nmcli -t uses ':'
# as its field separator and the SIGNAL and SECURITY fields never contain it.
net_list=$(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan no 2>/dev/null \
| awk -F: '
{
    in_use   = $1
    security = $NF
    signal   = $(NF-1)
    ssid     = $2
    for (i = 3; i <= NF-2; i++) ssid = ssid ":" $i
    gsub(/^\s+|\s+$/, "", ssid)
    if (ssid == "" || ssid == "--") next
    if (seen[ssid]++) next      # deduplicate

    s = signal + 0
    if      (s >= 75) icon = "󰤨"
    else if (s >= 50) icon = "󰤥"
    else if (s >= 25) icon = "󰤢"
    else              icon = "󰤟"

    if (in_use == "*")
        printf "󰤨  %-34s %d%%  ✓\t%s\n", ssid, s, ssid
    else
        printf "%s  %-34s %d%%\t%s\n", icon, ssid, s, ssid
}')

# ── Static actions ────────────────────────────────────────────────────────────
# Only insert the separator when there are network entries above it
if [ -n "$net_list" ]; then
    static_list=$(printf '%s\t%s\n' \
        "─────────────────────────────────────" "__sep__" \
        "󰑐  Rescan Networks"                   "__rescan__" \
        "󰤮  Turn Off Wi-Fi"                    "__off__" \
        "  Manage Connections"                "__mgr__")
    all_entries=$(printf '%s\n%s' "$net_list" "$static_list")
else
    static_list=$(printf '%s\t%s\n' \
        "󰑐  Rescan Networks"  "__rescan__" \
        "󰤮  Turn Off Wi-Fi"   "__off__" \
        "  Manage Connections" "__mgr__")
    all_entries="$static_list"
fi

# ── Show menu (display column only) ──────────────────────────────────────────
selected=$(printf '%s' "$all_entries" | cut -f1 | rofi_menu "󰤨  Wi-Fi")
[ -z "$selected" ] && exit

# Map the selected display string back to its action/ssid token
action=$(printf '%s' "$all_entries" | awk -F'\t' -v sel="$selected" '$1==sel{print $2; exit}')

# ── Handle selection ──────────────────────────────────────────────────────────
case "$action" in
    "__sep__")
        exit
        ;;
    "__rescan__")
        nmcli dev wifi rescan 2>/dev/null
        sleep 3
        exec "$0"
        ;;
    "__off__")
        nmcli radio wifi off
        ;;
    "__mgr__")
        setsid kitty --title "Network Connections" nmtui &
        ;;
    *)
        ssid="$action"
        [ -z "$ssid" ] && exit

        # If already connected to this SSID, disconnect; otherwise connect
        active=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2}')
        if [ "$ssid" = "$active" ]; then
            iface=$(nmcli -t -f DEVICE,TYPE dev 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}')
            nmcli dev disconnect "$iface" 2>/dev/null
        else
            nmcli dev wifi connect "$ssid" 2>/dev/null \
                || setsid kitty --title "Wi-Fi: $ssid" nmcli --ask dev wifi connect "$ssid" &
        fi
        ;;
esac
