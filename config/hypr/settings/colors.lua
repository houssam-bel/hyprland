-- =====================================================================
-- SEED PALETTE — overwritten by Matugen on the first wallpaper change.
-- =====================================================================
--
-- Matugen renders matugen/templates/hyprland-colors.lua over this file
-- every time the wallpaper changes. It is committed only so that a fresh
-- clone has a valid palette before Matugen has ever run.
--
-- Because it is tracked AND regenerated, `git status` will show it dirty
-- after your first wallpaper change. To stop that churn:
--     git update-index --skip-worktree config/hypr/settings/colors.lua
--
-- CONTRACT: exactly these six keys. See settings/look_and_feel.lua.
-- =====================================================================

return {
    primary    = "rgba(89b4faee)",
    secondary  = "rgba(a6e3a1ee)",
    surface    = "rgba(1e1e2eff)",
    on_surface = "rgba(cdd6f4ff)",
    outline    = "rgba(45475a88)",
    error      = "rgba(f38ba8ff)",
}
