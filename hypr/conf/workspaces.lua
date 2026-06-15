-- =============================================================================
-- workspaces.lua — Workspace-to-monitor rules and keybindings
-- =============================================================================
-- hl.workspace_rule({ workspace, monitor, ... }) replaces the
-- `workspace = N, monitor:OUTPUT` directive from hyprlang.
-- Lua loops eliminate the repetition that existed in the original .conf.
-- =============================================================================

-- Workspaces 1–5 on the laptop panel, 6–10 on the external monitor
for i = 1, 5  do hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" }) end
for i = 6, 10 do hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1"  }) end

-- Switch to workspace / move window to workspace
-- `i % 10` maps workspace 10 to the 0 key, same as the original .conf.
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
