-- =============================================================================
-- input.lua — Input, cursor, and XWayland
-- =============================================================================
-- hl.config({ category = { option = value } }) replaces hyprlang blocks.
-- Multiple hl.config() calls are additive — each one only updates the
-- keys passed, without overwriting the rest.
-- =============================================================================

hl.config({
    input = {
        kb_layout    = "pt",
        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = true,
        },
    },

    -- Hardware cursors must be disabled for stable rendering with Nvidia on Wayland
    cursor = {
        no_hardware_cursors = true,
    },

    -- Prevent XWayland apps from inheriting the eDP-1 scale factor
    xwayland = {
        force_zero_scaling = true,
    },
})

-- Per-device config: bind the Wacom tablet to the laptop panel.
-- hl.device() is equivalent to the `device { }` block in hyprlang.
hl.device({
    name   = "wacom-intuos-bt-m-pen",
    output = "eDP-1",
})
