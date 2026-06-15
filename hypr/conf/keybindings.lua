-- =============================================================================
-- keybindings.lua — All keybindings
-- =============================================================================
-- Syntax: hl.bind(keys, dispatcher [, flags])
--   keys       — string: "SUPER + SHIFT + S", "Print", "XF86AudioMute" ...
--   dispatcher — an hl.dsp.* value or an anonymous Lua function
--   flags      — optional table: { locked, repeating, mouse, ... }
--
-- Flag equivalents:
--   bind   → (no flags)
--   bindl  → { locked = true }
--   bindle → { locked = true, repeating = true }
--   bindm  → { mouse = true }
--
-- Variables (mainMod, terminal, fileManager, menu, scriptDir) are defined
-- as globals in hyprland.lua.
-- =============================================================================

-- --- Core applications ---
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("pkill rofi || " .. menu))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- --- Power & session ---
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("poweroff"))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("reboot"))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("systemctl suspend"))

-- --- Screenshots ---
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(scriptDir .. "/screenshot-region.sh"))
hl.bind("Print",                   hl.dsp.exec_cmd(scriptDir .. "/screenshot-monitor.sh"))

-- --- Focus movement (Mod + Arrow / Vim) ---
-- Left/Right delegate to smart-focus.sh for screen-edge detection
hl.bind(mainMod .. " + RIGHT", hl.dsp.exec_cmd(scriptDir .. "/smart-focus.sh right"))
hl.bind(mainMod .. " + LEFT",  hl.dsp.exec_cmd(scriptDir .. "/smart-focus.sh left"))
hl.bind(mainMod .. " + UP",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + DOWN",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + L",     hl.dsp.exec_cmd(scriptDir .. "/smart-focus.sh right"))
hl.bind(mainMod .. " + H",     hl.dsp.exec_cmd(scriptDir .. "/smart-focus.sh left"))
hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down" }))

-- --- Window movement (Mod + Shift + Arrow / Vim) ---
-- Left/Right delegate to smart-move.sh for cross-workspace movement at the edge
hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.exec_cmd(scriptDir .. "/smart-move.sh right"))
hl.bind(mainMod .. " + SHIFT + LEFT",  hl.dsp.exec_cmd(scriptDir .. "/smart-move.sh left"))
hl.bind(mainMod .. " + SHIFT + UP",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + DOWN",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + L",     hl.dsp.exec_cmd(scriptDir .. "/smart-move.sh right"))
hl.bind(mainMod .. " + SHIFT + H",     hl.dsp.exec_cmd(scriptDir .. "/smart-move.sh left"))
hl.bind(mainMod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down" }))

-- --- Scratchpad — global special workspace ---
hl.bind(mainMod .. " + S",       hl.dsp.workspace.toggle_special("global"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd(scriptDir .. "/scratchpad-toggle.sh"))

-- --- Mouse ---
-- `mouse = true` flag is equivalent to the `bindm` prefix in hyprlang
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- --- Media & hardware keys ---
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume      @DEFAULT_AUDIO_SINK@ 5%-"),    { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@   toggle"),       { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"),                              { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                              { locked = true, repeating = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                               { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                     { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                                 { locked = true })
