-- ======================================================================
---- MY PROGRAMS ----
-- ======================================================================
--
-- Single source of truth for default applications, the main modifier and
-- the paths of every helper script.
--
-- This module is PURE DATA: it makes no hl.* calls, it only returns a
-- table. Consumers do:  local p = require("settings/programs")
--
-- Change an application here and every bind, window rule and autostart
-- entry that references it follows automatically.
-- ======================================================================

local M = {}

-- ---- Modifier ---------------------------------------------------------
M.mainMod = "SUPER"   -- the Windows / Command key

-- ---- Applications -----------------------------------------------------
M.terminal    = "kitty"
M.fileManager = "dolphin"
M.browser     = "firefox"
M.locker      = "hyprlock"
M.volumeGui   = "pavucontrol"
M.bluetooth   = "blueman-manager"
M.network     = "nm-connection-editor"

-- Rofi modes. Kept as separate entries because each is bound to its own key.
M.menu        = "rofi -show drun"     -- app launcher (reads .desktop entries)
M.runMenu     = "rofi -show run"      -- raw binary launcher, no .desktop needed
M.windowMenu  = "rofi -show window"   -- switch between open windows

-- SwayNC control centre. -t toggles the panel, -sw skips the "wait for the
-- daemon" delay so the first press is not swallowed.
M.notifCenter = "swaync-client -t -sw"

-- ---- Helper scripts ---------------------------------------------------
-- Absolute paths built from $HOME rather than "~": Hyprland does not expand
-- a tilde inside exec_cmd strings, and a literal "~/..." silently fails.
local home = os.getenv("HOME")

M.scripts    = home .. "/.config/hypr/scripts"
M.wallpaper  = M.scripts .. "/wallpaper.sh"
M.theme      = M.scripts .. "/theme.sh"
M.clipboard  = M.scripts .. "/clipboard.sh"
M.screenshot = M.scripts .. "/screenshot.sh"
M.record     = M.scripts .. "/record.sh"
M.powermenu  = M.scripts .. "/powermenu.sh"

-- ---- Paths ------------------------------------------------------------
M.wallpaperDir  = home .. "/Pictures/Wallpapers"
M.screenshotDir = home .. "/Pictures/Screenshots"

return M
