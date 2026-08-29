-- ======================================================================
---- MONITORS ----
-- ======================================================================
--
-- Display topology.
--
-- Reference arrangement: laptop panel on the left, external screen flush
-- to its right. eDP-1 is 1366 px wide, so HDMI-A-1 starts at x = 1366.
--
-- ORDER IS SIGNIFICANT. Hyprland applies the FIRST matching rule, so the
-- catch-all must stay at the bottom — a leading catch-all swallows every
-- specific rule above it.
--
-- Find your own output names and modes with:  hyprctl monitors all
--
-- Docs: https://wiki.hypr.land/Configuring/Basics/Monitors/
-- ======================================================================

-- Laptop internal panel, anchored at the origin.
hl.monitor({
    output   = "eDP-1",
    mode     = "1366x768@60",  -- explicit rate; "preferred" can land on 59.9x
    position = "0x0",
    scale    = 1,              -- 768 px tall is too short for fractional scaling
})

-- External display, physically to the right of the laptop.
-- Absent most of the time; an unmatched rule is simply inert, not an error.
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "1366x0",       -- starts exactly where eDP-1 ends
    scale    = 1,
})

-- CATCH-ALL for anything not named above — a projector, a dock, a friend's
-- TV. Without it an unknown output stays disabled and looks broken.
-- "auto" places it to the right of the existing outputs.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- ---- Lid behaviour ----------------------------------------------------
-- Closing the lid is deliberately a no-op here: Hyprland disables an output
-- when the lid switch fires, and not binding the switch suppresses that.
-- The systemd half lives outside this repo, in /etc/systemd/logind.conf:
--     HandleLidSwitch=ignore
--     HandleLidSwitchExternalPower=ignore

-- ---- Workspaces and monitors -----------------------------------------
-- Workspaces are deliberately NOT pinned to specific outputs. Binding, say,
-- workspaces 6-10 to HDMI-A-1 makes them unreachable the moment you undock.
-- Hyprland's default — workspaces follow the focused monitor — is correct
-- for a laptop that is docked only some of the time.
--
-- If you do run a permanently-attached second screen, uncomment:
-- hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-1" })
