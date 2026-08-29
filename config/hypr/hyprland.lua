-- ======================================================================
-- ~/.config/hypr/hyprland.lua — entry point
-- ======================================================================
--
-- This file deliberately contains NO settings. Its only job is to hand
-- control to settings/init.lua, which loads every module in a defined
-- order and survives a syntax error in any one of them.
--
-- Why the indirection instead of nine require() calls here:
--   * order is declared in one place, next to the comment explaining it;
--   * every module is uncached before loading, so `hyprctl reload` really
--     re-reads changed files (Lua's require() memoises by module name and
--     would otherwise serve you the palette from before Matugen ran);
--   * a broken module is reported and skipped rather than aborting the
--     whole config and leaving you in a session with no keybindings.
--
-- Docs: https://wiki.hypr.land/Configuring/Start/
-- ======================================================================

require("settings/init").load()
