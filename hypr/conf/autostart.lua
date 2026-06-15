-- =============================================================================
-- autostart.lua — Startup daemons
-- =============================================================================
-- hl.on("hyprland.start", fn) replaces `exec-once` from hyprlang.
-- hl.exec_cmd() is async by design — no need for `& disown`.
--
-- Most daemons are managed by systemd (Restart=on-failure handles crashes).
-- Enable once per user with:
--   systemctl --user enable --now hyprpolkitagent
--   systemctl --user enable --now hypridle
--   systemctl --user enable --now hyprpaper
--   systemctl --user enable --now swaync
--
-- waybar is NOT managed by systemd — it exits with code 0 when DPMS turns off
-- monitors (clean Wayland disconnect), so Restart=on-failure never triggers.
-- Instead it runs in a watchdog loop below that restarts it regardless of exit code.
-- =============================================================================

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark")
    -- Small delay ensures the compositor socket is ready before setting the wallpaper.
    -- If the wallpaper does not appear on login, increase the sleep value (e.g. sleep 2).
    hl.exec_cmd("sleep 1 && hyprctl hyprpaper wallpaper ',~/.config/hypr/wallpapers/gradient.jpg'")
    -- Watchdog loop: restarts waybar 2s after any exit (crash, DPMS off, etc.)
    hl.exec_cmd("bash -c 'while true; do waybar; done'")
    hl.exec_cmd("firefox")
end)
