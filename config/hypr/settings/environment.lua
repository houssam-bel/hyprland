-- ======================================================================
---- ENVIRONMENT VARIABLES ----
-- ======================================================================
--
-- Variables exported into the Hyprland session.
--
-- These are read by toolkits when an application STARTS, so a change here
-- needs the affected app restarted — `hyprctl reload` alone is not enough.
--
-- Docs: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
-- ======================================================================

-- ---- Cursor -----------------------------------------------------------
-- All four must agree. XCURSOR_* is read by XWayland and GTK, HYPRCURSOR_*
-- by native Hyprland surfaces. Set only one pair and the cursor visibly
-- changes size or shape as it crosses between window types.
hl.env("XCURSOR_THEME",   "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE",  "24")

-- ---- Qt ---------------------------------------------------------------
-- "wayland;xcb" = prefer native Wayland, fall back to X11 instead of
-- refusing to start. Dolphin and every other KDE app lands here.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
-- Route Qt theming through qt6ct so config/qt6ct/qt6ct.conf can point Qt
-- apps at the same palette Matugen writes for GTK.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- Let Hyprland draw the border instead of Qt drawing its own client-side
-- decoration on top of it.
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
-- Honour per-monitor fractional scaling. Harmless at scale 1.
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- ---- GTK / SDL / Java -------------------------------------------------
hl.env("GDK_BACKEND",     "wayland,x11,*")   -- same fallback chain as Qt
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
-- Without this, Java/Swing windows render as an unpainted grey rectangle
-- under XWayland.
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- ---- Application-specific --------------------------------------------
hl.env("MOZ_ENABLE_WAYLAND", "1")              -- Firefox native Wayland
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto") -- VSCode, Discord, Vesktop

-- ---- Deliberately NOT set --------------------------------------------
-- XDG_CURRENT_DESKTOP, XDG_SESSION_TYPE and XDG_SESSION_DESKTOP.
-- A display manager or uwsm already exports these correctly; overriding
-- them here breaks xdg-desktop-portal discovery, which breaks screen
-- sharing and file pickers.
