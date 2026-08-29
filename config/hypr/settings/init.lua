-- ======================================================================
-- settings/init.lua — module loader
-- ======================================================================
--
-- LOAD ORDER IS SIGNIFICANT.
--
--   environment   must run before autostart, or daemons spawned at start
--                 inherit the wrong toolkit variables.
--   permissions   must be early; Hyprland reads it once at startup.
--   monitors      before window_rules, whose expressions (monitor_w, ...)
--                 resolve against the outputs declared there.
--   look_and_feel before keybindings, so bind flags see final gaps/borders.
--   window_rules  last of the config modules: the LAST matching rule wins,
--                 so these overrides sit on top of everything above.
--   autostart     genuinely last — it launches processes, and a process
--                 must never start before the config it reads is applied.
--
-- settings/programs.lua is NOT in this list. It is pure data with no hl.*
-- calls; other modules require() it directly.
--
-- settings/colors.lua is NOT in this list either. It is required (with a
-- fallback) from look_and_feel.lua, the only consumer.
-- ======================================================================

local M = {}

M.modules = {
    "settings/environment",
    "settings/permissions",
    "settings/monitors",
    "settings/look_and_feel",
    "settings/input",
    "settings/keybindings",
    "settings/window_rules",
    "settings/autostart",
}

-- Modules that are pure data and get uncached alongside the list above, so
-- editing them and reloading takes effect instead of serving a stale copy.
M.data_modules = {
    "settings/programs",
    "settings/colors",
}

-- Surface a load failure where you will actually see it: an on-screen
-- notification if the compositor is up, and always on stderr for
-- `journalctl --user -b | grep Hyprland`.
local function report(module, err)
    io.stderr:write(("[hyprland.lua] FAILED to load %s\n  %s\n"):format(module, err))
    pcall(function()
        hl.notification.create({
            text    = "Config error in " .. module .. "\n" .. tostring(err),
            timeout = 10000,
        })
    end)
end

function M.load()
    -- Drop every cached module first, including the data ones, so a reload
    -- is a genuine re-read rather than a replay of the last boot.
    for _, name in ipairs(M.data_modules) do
        package.loaded[name] = nil
    end

    local failed = 0
    for _, name in ipairs(M.modules) do
        package.loaded[name] = nil
        local ok, err = pcall(require, name)
        if not ok then
            report(name, err)
            failed = failed + 1
        end
    end

    return failed
end

return M
