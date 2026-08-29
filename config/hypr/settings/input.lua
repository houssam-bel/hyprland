-- ======================================================================
---- INPUT ----
-- ======================================================================
--
-- Keyboard, pointer, touchpad and gestures.
--
-- Docs: https://wiki.hypr.land/Configuring/Variables/#input
-- ======================================================================

hl.config({
    input = {
        -- ---- Keyboard -------------------------------------------------
        kb_layout  = "fr",   -- French AZERTY. Change to "us" for QWERTY.
        kb_variant = "",     -- "" is standard fr; set only if your board needs it
        kb_model   = "",
        kb_options = "",     -- e.g. "compose:ralt" to make AltGr a compose key
        kb_rules   = "",

        -- NumLock on at login. This does NOT affect the Numpad workspace
        -- binds — those are keycode-based and NumLock-independent by design
        -- (see settings/keybindings.lua §4) — it only means typing digits
        -- on the Numpad produces digits.
        numlock_by_default = true,

        repeat_rate  = 40,   -- repeats per second once repeat starts
        repeat_delay = 400,  -- ms held before repeat starts; the 600 default drags

        -- ---- Pointer --------------------------------------------------
        follow_mouse  = 1,   -- 1 = focus follows the cursor across windows
        mouse_refocus = true,
        sensitivity   = 0,   -- -1.0..1.0; 0 = libinput default, unmodified
        accel_profile = "",  -- "" = device default; "flat" disables acceleration

        -- ---- Touchpad -------------------------------------------------
        touchpad = {
            natural_scroll       = true,  -- content follows the fingers
            disable_while_typing = true,  -- kills palm-induced cursor jumps
            tap_to_click         = true,
            clickfinger_behavior = true,  -- 2-finger click = RMB, 3-finger = MMB
            scroll_factor        = 1.0,
            drag_lock            = true,  -- a brief lift mid-drag does not drop it
        },
    },
})

-- ---- Gestures ---------------------------------------------------------
-- The old monolithic gestures{} block was replaced by discrete hl.gesture()
-- calls. Three fingers horizontally is the workspace swipe.
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- A four-finger gesture bound to an arbitrary dispatcher is possible on
-- builds that accept action = "dispatcher", but the exact key name for the
-- payload has moved between releases. Confirm the shape your build wants
-- before enabling it:
--     hyprctl repl 'hl.gesture'
--
-- hl.gesture({
--     fingers    = 4,
--     direction  = "up",
--     action     = "dispatcher",
--     dispatcher = hl.dsp.exec_cmd(require("settings/programs").menu),
-- })

-- ---- Per-device overrides ---------------------------------------------
-- Get the exact name from `hyprctl devices`, then uncomment and edit. This
-- is how you give an external mouse a different profile to the trackpad.
--
-- hl.device({
--     name          = "logitech-mx-master-3",
--     sensitivity   = -0.2,
--     accel_profile = "flat",
-- })
