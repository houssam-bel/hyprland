-- ======================================================================
---- LOOK AND FEEL ----
-- ======================================================================
--
-- Gaps, borders, rounding, blur, shadows and animations.
--
-- This is the module Matugen drives. Everything colour-related is read
-- from settings/colors.lua, which Matugen regenerates from the wallpaper.
--
-- CONTRACT — settings/colors.lua must return a table with these six keys:
--     primary, secondary, surface, on_surface, outline, error
-- each an "rgba(RRGGBBAA)" or "rgb(RRGGBB)" string literal. Drop one and
-- col.inactive_border becomes nil, which errors on reload.
--
-- Docs: https://wiki.hypr.land/Configuring/Variables/
-- ======================================================================

-- Drop the cached copy before requiring. Lua's require() memoises by module
-- name, so without this a `hyprctl reload` fired by Matugen's post_hook
-- would quietly reuse the palette from before Matugen rewrote the file —
-- the single most confusing failure mode in this whole pipeline.
package.loaded["settings/colors"] = nil

local ok, colors = pcall(require, "settings/colors")
if not ok then
    -- Neutral fallback, used only before Matugen has ever run. Keeping it
    -- here means a fresh clone loads cleanly with no wallpaper set.
    colors = {
        primary    = "rgba(89b4faee)",
        secondary  = "rgba(a6e3a1ee)",
        surface    = "rgba(1e1e2eff)",
        on_surface = "rgba(cdd6f4ff)",
        outline    = "rgba(45475a88)",
        error      = "rgba(f38ba8ff)",
    }
end

hl.config({
    general = {
        gaps_in     = 5,    -- px between adjacent tiled windows
        gaps_out    = 20,   -- px between windows and the screen edge
        border_size = 2,

        col = {
            -- Two colours plus an angle give the focused window a 45°
            -- gradient border. Both are pulled from the wallpaper palette.
            active_border   = { colors = { colors.primary, colors.secondary }, angle = 45 },
            inactive_border = colors.outline,
        },

        resize_on_border = true,   -- drag a border or gap to resize, no modifier
        allow_tearing    = false,  -- global off; opted in per-window in window_rules
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,     -- 2 = circular corners; higher = squircle

        active_opacity   = 1.0,
        inactive_opacity = 1.0, -- global stays 1.0; translucency is per-app

        shadow = {
            enabled      = true,
            range        = 4,          -- px spread
            render_power = 3,          -- falloff steepness
            color        = 0xee1a1a1a, -- 0xAARRGGBB INTEGER, not an rgba() string
        },

        blur = {
            enabled     = true,
            size        = 3,       -- kernel radius
            passes      = 2,       -- each extra pass roughly doubles GPU cost
            vibrancy    = 0.1696,  -- saturation boost behind translucent surfaces
            new_optimizations = true,
            -- Blur only what is actually translucent. On an integrated GPU
            -- this is the difference between a smooth bar and a stuttering one.
            xray        = false,
            popups      = true,
            popups_ignorealpha = 0.2,
        },
    },

    animations = { enabled = true },

    dwindle = {
        preserve_split = true,   -- keep the split direction as windows close
        smart_split    = false,
    },

    master = {
        new_status = "master",
    },

    -- ONE misc block. Two `misc = {}` keys in the same table constructor is
    -- legal Lua but the second silently replaces the first, so anything in
    -- the earlier block is lost without a warning.
    misc = {
        force_default_wallpaper = 0,     -- 0 = no bundled anime mascot
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        focus_on_activate       = true,  -- honour "please focus me" requests
        vfr = true,   -- variable refresh: idle frames are skipped. Real battery win.
        vrr = 1,      -- 0 off, 1 on, 2 fullscreen-only. 1 needs a FreeSync panel.
    },
})

-- ---- Animation curves -------------------------------------------------
-- Bezier curves take control points as {x, y} pairs; springs are a physical
-- simulation and take mass / stiffness / dampening instead.
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

-- ---- Animation assignments --------------------------------------------
-- "leaf" names the animated element; higher speed = shorter duration.
hl.animation({ leaf = "global",     enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",     enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.1,  spring = "easy",       style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear",     style = "popin 87%" })
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",   enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
