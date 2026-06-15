-- =============================================================================
-- animations.lua — Animations and bezier curves
-- =============================================================================
-- hl.curve() replaces the `bezier` directive.
-- hl.animation() replaces the `animation` directive.
-- Bezier control points are passed as a list of {x, y} pairs.
-- =============================================================================

hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",          enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "myBezier", style = "slidevert" })
