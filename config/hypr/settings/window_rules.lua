-- ======================================================================
---- WINDOWS AND WORKSPACES ----
-- ======================================================================
--
-- Structure: match{} holds CONDITIONS; everything outside it holds EFFECTS.
--
-- Rules run top to bottom and the LAST matching rule wins for any given
-- effect — so general rules go first and specific overrides go last.
--
-- The regex engine is Google RE2. Prefix a pattern with "negative:" to
-- invert it. Find a window's class and title with:  hyprctl clients
--
-- Docs: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- ======================================================================

-- ======================================================================
-- 1. GLOBAL CORRECTNESS
-- ======================================================================

-- Ignore apps that demand maximisation on launch. Almost always right in a
-- tiling compositor, where "maximise" fights the layout.
hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- XWayland drag-and-drop leaves a phantom borderless window behind that
-- steals focus and swallows the drop.
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- ======================================================================
-- 2. FLOATING DIALOGS
-- ======================================================================

-- System utilities that are useless tiled. Centred at a fixed size.
hl.window_rule({
    name   = "float-system-utils",
    match  = { class = "^(pavucontrol|org\\.pulseaudio\\.pavucontrol|blueman-manager|nm-connection-editor|nwg-look|qt6ct|qt5ct)$" },
    float  = true,
    size   = "800 600",
    center = true,
})

-- Portal-driven file pickers and polkit prompts. GTK and Qt both land here.
hl.window_rule({
    name   = "float-portals",
    match  = { class = "^(xdg-desktop-portal-gtk|org\\.kde\\.polkit-kde-authentication-agent-1|hyprpolkitagent)$" },
    float  = true,
    center = true,
})

-- Generic modal dialogs, matched by TITLE because the class is usually the
-- parent application's.
hl.window_rule({
    name   = "float-dialogs",
    match  = { title = "^(Open File|Save File|Open Folder|Choose Files|Confirm|Preferences|Settings)" },
    float  = true,
    center = true,
})

-- Swappy, the screenshot annotator. Floats so it lands on top of whatever
-- you just captured instead of reflowing the layout underneath it.
hl.window_rule({
    name   = "float-swappy",
    match  = { class = "^(swappy)$" },
    float  = true,
    center = true,
})

-- Kitty launched with --class scratchpad becomes a floating drop-down.
-- monitor_w / monitor_h resolve at placement time, so one rule is correct
-- on both a 1366x768 panel and a 1920x1080 external screen.
hl.window_rule({
    name  = "scratch-terminal",
    match = { class = "^scratchpad$" },
    float = true,
    size  = "monitor_w*0.7 monitor_h*0.6",
    move  = "monitor_w*0.15 monitor_h*0.1",
})

-- Picture-in-picture video: float, pin above everything, park bottom-right.
hl.window_rule({
    name  = "float-pip",
    match = { title = "^(Picture-in-Picture|Picture in picture)$" },
    float = true,
    pin   = true,
    size  = "monitor_w*0.25 monitor_h*0.25",
    move  = "monitor_w*0.73 monitor_h*0.70",
})

-- ======================================================================
-- 3. OPACITY
-- ======================================================================

-- "active inactive". Opacity is MULTIPLICATIVE across matching rules — two
-- 0.9 rules give you 0.81. Append " override" for an absolute value.
hl.window_rule({
    name    = "opacity-terminal",
    match   = { class = "^(kitty)$" },
    opacity = "0.92 0.85",
})

hl.window_rule({
    name    = "opacity-filemanager",
    match   = { class = "^(dolphin|org\\.kde\\.dolphin)$" },
    opacity = "0.95 0.88",
})

-- Media and browsers stay fully opaque: translucency ruins video and photos.
hl.window_rule({
    name    = "opacity-opaque-apps",
    match   = { class = "^(firefox|mpv|imv|vlc|Gimp|swappy)$" },
    opacity = "1.0 1.0 override",
})

-- ======================================================================
-- 4. MEDIA AND FULLSCREEN BEHAVIOUR
-- ======================================================================

-- Never blank the screen during fullscreen playback. Scoped to fullscreen
-- so a background browser tab cannot hold the display awake all day.
hl.window_rule({
    name         = "inhibit-idle-video",
    match        = { class = "^(mpv|vlc|firefox)$" },
    idle_inhibit = "fullscreen",
})

-- Blur behind an opaque video window is pure wasted GPU time.
hl.window_rule({
    name    = "no-blur-media",
    match   = { class = "^(mpv|vlc|imv)$" },
    no_blur = true,
})

-- ======================================================================
-- 5. GAMING
-- ======================================================================

-- Allow tearing for content Hyprland identifies as a game. Cuts input
-- latency at the cost of visible tears. general.allow_tearing stays false;
-- the per-window `immediate` flag is what actually opts a window in.
hl.window_rule({
    name      = "gaming-tearing",
    match     = { content = "game" },
    immediate = true,
    no_blur   = true,
    rounding  = 0,
})

-- Steam's tooltips and notification popups misbehave when tiled. The
-- negative lookahead keeps the main Steam window out of the match.
hl.window_rule({
    name             = "steam-popups",
    match            = { class = "^steam$", title = "^(?!Steam$).*" },
    float            = true,
    no_initial_focus = true,
})

-- ======================================================================
-- 6. LAYER RULES (bars, launchers, notification shells)
-- ======================================================================
-- Layers are not windows. They are matched by NAMESPACE, which you can list
-- with `hyprctl layers`.

-- Blur behind the shell surfaces so the Matugen palette reads correctly
-- against any wallpaper.
hl.layer_rule({ name = "blur-waybar", match = { namespace = "^waybar$" }, blur = true })
hl.layer_rule({ name = "blur-rofi",   match = { namespace = "^rofi$" },   blur = true })
hl.layer_rule({ name = "blur-swaync", match = { namespace = "^swaync-(control-center|notification-window)$" }, blur = true })

-- Ignore the wallpaper's own alpha when blurring, otherwise the bar picks
-- up a milky wash over a dark wallpaper.
hl.layer_rule({ name = "waybar-ignorealpha", match = { namespace = "^waybar$" }, ignore_alpha = 0.3 })

-- The slurp selection overlay must not animate, or grim captures the fade.
hl.layer_rule({ name = "no-anim-selection", match = { namespace = "^selection$" }, no_anim = true })

-- ======================================================================
-- 7. SMART GAPS ("no gaps when only")
-- ======================================================================
-- Two halves that must stay together:
--   workspace_rule -> removes the gaps
--   window_rule    -> removes the border and the rounding
-- Enable only the first and you get a rounded, bordered window sitting
-- flush against the screen edge. Both, or neither.
--
-- SELECTORS
--   w[tv1]   workspace holding exactly 1 tiled, visible window
--            (w = window count, t = tiled only, v = visible only)
--   f[1]     workspace that currently has a fullscreen window
--   s[false] NOT a special workspace
--
-- s[false] is load-bearing: SUPER+U opens the special:magic scratchpad, and
-- without it the scratchpad also loses its gaps and border — exactly wrong
-- for a floating overlay panel.
--
-- Selectors only match workspaces that exist at evaluation time; they
-- cannot pre-configure a workspace you have never visited.

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]s[false]",   gaps_out = 0, gaps_in = 0 })

-- `rounding` is a DYNAMIC effect, so it re-evaluates as windows open and
-- close. That re-evaluation is what makes the whole thing feel automatic.
hl.window_rule({
    name        = "no-gaps-single-tiled",
    match       = { float = false, workspace = "w[tv1]s[false]" },
    border_size = 0,
    rounding    = 0,
})

hl.window_rule({
    name        = "no-gaps-fullscreen",
    match       = { float = false, workspace = "f[1]s[false]" },
    border_size = 0,
    rounding    = 0,
})
