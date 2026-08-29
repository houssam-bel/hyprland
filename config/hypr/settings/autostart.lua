-- ======================================================================
---- AUTOSTART ----
-- ======================================================================
--
-- hl.on("hyprland.start", fn) runs once when the compositor finishes
-- initialising. This replaces the old exec-once directive.
--
-- Nothing here blocks: every command is fire-and-forget. If a daemon needs
-- another to exist first, that ordering lives inside the helper script, not
-- in a sleep chain here.
--
-- Docs: https://wiki.hypr.land/Configuring/Basics/Autostart/
-- ======================================================================

local p = require("settings/programs")

hl.on("hyprland.start", function()
    -- ---- Authentication agent -----------------------------------------
    -- Without this, anything asking for elevated privileges hangs with no
    -- prompt and no error — the single most common "my system is broken"
    -- symptom on a fresh Hyprland install.
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- ---- Clipboard history --------------------------------------------
    -- Two watchers: text and images are separate MIME streams and a single
    -- watcher silently drops whichever one it was not started for.
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- ---- Wallpaper -----------------------------------------------------
    -- `wallpaper.sh init` starts the daemon, waits for its socket, then
    -- restores the cached wallpaper — or picks one at random on a first
    -- run. Doing that in the script rather than with a `sleep 1 &&` chain
    -- here means the wait is a real readiness check, not a guess.
    hl.exec_cmd(p.wallpaper .. " init")

    -- ---- Shell components ----------------------------------------------
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")

    -- ---- Idle and lock --------------------------------------------------
    hl.exec_cmd("hypridle")

    -- ---- Tray applets ----------------------------------------------------
    -- blueman-applet also runs the pairing agent; without it, pairing a new
    -- device from the tray fails with no dialogue.
    hl.exec_cmd("blueman-applet")
    -- Uncomment if you prefer nm-applet's tray icon to Waybar's network module.
    -- hl.exec_cmd("nm-applet --indicator")
end)

-- Re-apply the wallpaper when a monitor is hot-plugged, otherwise the newly
-- connected screen comes up black.
hl.on("monitor.added", function()
    hl.exec_cmd(p.wallpaper .. " restore")
end)
