-- =============================================================================
-- monitors.lua — Monitor layout
-- =============================================================================
-- hl.monitor({ output, mode, position, scale })
-- The `mode` string accepts the "WxH@Hz" format, same as hyprlang.
--
-- DP-1  — external monitor, top position
-- DP-2  — external monitor, top position
-- eDP-1 — laptop panel, bottom position, 1.25x HiDPI scale
-- =============================================================================

hl.monitor({ output = "DP-1",  mode = "1920x1080@100", position = "0x0",    scale = 1    })
hl.monitor({ output = "DP-2",  mode = "1920x1080@100", position = "0x0",    scale = 1    })
hl.monitor({ output = "eDP-1", mode = "2560x1600@165", position = "0x1080", scale = 1.25 })
