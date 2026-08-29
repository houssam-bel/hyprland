-- ======================================================================
---- KEYBINDINGS ----
-- ======================================================================
--
-- hl.bind(keys, dispatcher, flags)
--   keys        "SUPER + SHIFT + Q" — modifiers joined by +, key last
--   dispatcher  an hl.dsp.* value, OR a Lua function for multi-step actions
--   flags       { locked, release, repeating, long_press, non_consuming,
--                 mouse, click, drag, transparent, ignore_mods, description }
--
-- IMPORTANT: hl.dsp.* functions RETURN a description table, they do not
-- act. Inside a plain Lua function you must wrap them in hl.dispatch().
--
-- LETTERS IN USE (SUPER + <letter>) — check here before adding a bind:
--   A pin        B browser    C colour-pick  D launcher   E files
--   F fullscreen G group      L lock         N notifs     P pseudotile
--   Q close      R run        T split        U scratchpad V clipboard
--   W wallpaper
--   Free: H I J K M O X Y
--   SUPER+ALT+{Z,Q,S,D} is reserved for directional focus (see §3).
-- ======================================================================

local p       = require("settings/programs")
local mainMod = p.mainMod

-- ======================================================================
-- 1. APPLICATIONS
-- ======================================================================

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(p.terminal),    { description = "Terminal" })
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(p.fileManager), { description = "File manager" })
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(p.browser),     { description = "Browser" })
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd(p.menu),        { description = "App launcher" })
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd(p.runMenu),     { description = "Run command" })
hl.bind(mainMod .. " + Tab",    hl.dsp.exec_cmd(p.windowMenu),  { description = "Window switcher" })
hl.bind(mainMod .. " + N",      hl.dsp.exec_cmd(p.notifCenter), { description = "Notification centre" })
hl.bind(mainMod .. " + L",      hl.dsp.exec_cmd(p.locker),      { description = "Lock screen" })

-- Drop-down scratchpad terminal. Paired with the "scratch-terminal" rule in
-- settings/window_rules.lua, which is what makes it float and centre.
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd(p.terminal .. " --class scratchpad"),
    { description = "Scratch terminal" })

-- ======================================================================
-- 2. HELPER SCRIPTS
-- ======================================================================
-- Binds point at scripts, never at inline shell pipelines. A pipeline in a
-- bind cannot be tested on its own and turns quoting into a minefield.

-- ---- Screenshots ------------------------------------------------------
hl.bind("Print",                   hl.dsp.exec_cmd(p.screenshot .. " region"), { description = "Screenshot region" })
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd(p.screenshot .. " window"), { description = "Screenshot window" })
hl.bind("CTRL + Print",            hl.dsp.exec_cmd(p.screenshot .. " output"), { description = "Screenshot monitor" })
hl.bind("ALT + Print",             hl.dsp.exec_cmd(p.screenshot .. " full"),   { description = "Screenshot all monitors" })
-- Duplicate of Print, for keyboards where Print is awkward to reach.
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(p.screenshot .. " region"), { description = "Screenshot region" })

-- ---- Colour picker ----------------------------------------------------
-- -a copies straight to the clipboard, so the value is ready to paste.
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Pick a colour" })

-- ---- Clipboard --------------------------------------------------------
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd(p.clipboard .. " show"),   { description = "Clipboard history" })
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(p.clipboard .. " delete"), { description = "Delete clipboard entry" })

-- ---- Wallpaper and theming -------------------------------------------
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd(p.wallpaper .. " random"), { description = "Random wallpaper + retheme" })
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(p.wallpaper .. " pick"),   { description = "Pick wallpaper + retheme" })
-- Force light/dark independently of the wallpaper's luminance.
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(p.theme .. " toggle"),     { description = "Toggle light/dark" })
hl.bind(mainMod .. " + CTRL + T",  hl.dsp.exec_cmd(p.theme .. " auto"),       { description = "Theme follows wallpaper again" })

-- ---- Session menu -----------------------------------------------------
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(p.powermenu), { description = "Power menu" })

-- ---- Screen recording -------------------------------------------------
-- Function keys rather than letters: SUPER+R is the run menu and every
-- other mnemonic letter is already spoken for.
hl.bind(mainMod .. " + F9",         hl.dsp.exec_cmd(p.record .. " region"),       { description = "Record region" })
hl.bind(mainMod .. " + SHIFT + F9", hl.dsp.exec_cmd(p.record .. " region-audio"), { description = "Record region + mic" })
hl.bind(mainMod .. " + F10",        hl.dsp.exec_cmd(p.record .. " screen"),       { description = "Record monitor" })
hl.bind(mainMod .. " + F11",        hl.dsp.exec_cmd(p.record .. " stop"),         { description = "Stop recording" })

-- ======================================================================
-- 3. WINDOW MANAGEMENT
-- ======================================================================

hl.bind(mainMod .. " + Q",         hl.dsp.window.close(),                      { description = "Close window" })
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill(),                       { description = "Force kill window" })
hl.bind(mainMod .. " + Space",     hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })

hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Fullscreen" })
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }),  { description = "Maximise (keeps the bar)" })

hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), { description = "Pseudotile" })
hl.bind(mainMod .. " + A", hl.dsp.window.pin(),    { description = "Pin to all workspaces" })
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(),  { description = "Toggle tab group" })

-- hl.dsp.layout() is the layoutmsg interface. The standalone `togglesplit`
-- dispatcher was removed; this form replaced it.
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"), { description = "Toggle split direction" })

-- ---- Directional focus ------------------------------------------------
local directions = { "left", "right", "up", "down" }

for _, dir in ipairs(directions) do
    hl.bind(mainMod .. " + " .. dir,
            hl.dsp.focus({ direction = dir }),
            { description = "Focus " .. dir })
end

-- ZQSD home-row alternative, on SUPER+ALT.
--
-- ZQSD not WASD: on AZERTY these four keys occupy the physical positions
-- WASD holds on QWERTY, so the hand shape is identical.
--
-- ALT is required, not stylistic: SUPER+Q closes the window and SUPER+D is
-- the launcher. Without ALT, two of the four directions collide with binds
-- used far more often. All four carry ALT so the scheme stays uniform.
local zqsd = {
    { key = "Q", dir = "left"  },
    { key = "D", dir = "right" },
    { key = "Z", dir = "up"    },
    { key = "S", dir = "down"  },
}

for _, b in ipairs(zqsd) do
    hl.bind(mainMod .. " + ALT + " .. b.key,
            hl.dsp.focus({ direction = b.dir }),
            { description = "Focus " .. b.dir .. " (ZQSD)" })
end

-- ---- Move, swap and resize --------------------------------------------
for _, dir in ipairs(directions) do
    hl.bind(mainMod .. " + SHIFT + " .. dir,
            hl.dsp.window.swap({ direction = dir }),
            { description = "Swap window " .. dir })
end

-- Keyboard resize. VERIFY BEFORE ENABLING: the payload key for a relative
-- resize has changed shape between releases, and a wrong one raises at load
-- time, which costs you EVERY bind in this file (settings/init.lua isolates
-- the module, not the individual bind). Confirm the shape your build wants:
--     hyprctl repl 'hl.dispatch(hl.dsp.window.resize({ delta = { 40, 0 } }))'
-- and uncomment once it resizes instead of erroring.
--
-- local resize_steps = {
--     { dir = "left",  delta = { -40, 0 } },
--     { dir = "right", delta = {  40, 0 } },
--     { dir = "up",    delta = { 0, -40 } },
--     { dir = "down",  delta = { 0,  40 } },
-- }
--
-- for _, r in ipairs(resize_steps) do
--     hl.bind(mainMod .. " + CTRL + SHIFT + " .. r.dir,
--             hl.dsp.window.resize({ delta = r.delta }),
--             { repeating = true, description = "Resize " .. r.dir })
-- end
--
-- Until then: SUPER + right-drag resizes with the mouse (see below), and
-- general.resize_on_border lets you drag any border directly.

-- Move a window between monitors. Meaningful only while a second output is
-- connected; inert rather than an error otherwise.
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.move({ monitor = "l" }), { description = "Window to left monitor" })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ monitor = "r" }), { description = "Window to right monitor" })

-- ---- Mouse ------------------------------------------------------------
-- The `mouse` flag is mandatory for drag and resize binds.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ---- Scratchpad (special workspace) -----------------------------------
hl.bind(mainMod .. " + U",         hl.dsp.workspace.toggle_special("magic"),           { description = "Toggle scratchpad" })
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Window to scratchpad" })

-- ======================================================================
-- 4. NUMPAD WORKSPACE NAVIGATION
-- ======================================================================
--
-- THE PROBLEM
-- Every Numpad key emits TWO different keysyms depending on NumLock:
--     NumLock ON       NumLock OFF
--     KP_7 KP_8 KP_9   KP_Home  KP_Up    KP_Prior
--     KP_4 KP_5 KP_6   KP_Left  KP_Begin KP_Right
--     KP_1 KP_2 KP_3   KP_End   KP_Down  KP_Next
--     KP_0             KP_Insert
-- A config binding only KP_1..KP_9 works until NumLock is toggled once,
-- then silently stops. That is why most Numpad configs found online
-- "randomly break" — they were written and tested in one NumLock state.
--
-- THE FIX
-- Raw keycodes (code:NN) are read BEFORE XKB translation, so they are
-- identical in both NumLock states AND immune to the French layout. The
-- keysym pairs are bound as well for belt and braces; a duplicate bind to
-- the same action is harmless.
--
-- WHERE THE NUMBERS COME FROM
-- XKB keycode = Linux evdev code + 8. The codes below are already XKB.
-- `wev` also reports XKB keycodes, so its output matches this table
-- verbatim — do not add 8 to what wev prints. Check any key with:
--     wev -f wl_keyboard:key
-- Or confirm one against Hyprland's own bind engine:
--     hyprctl repl 'hl.bind("SUPER + code:87", function() hl.notification.create({ text = "ok", timeout = 2000 }) end)'

local BIND_MODE = "both"   -- "code" | "keysym" | "both"

local numpad = {
    -- ws  XKB code   NumLock ON    NumLock OFF
    { ws = 1,  code = 87, on = "KP_1", off = "KP_End"    },
    { ws = 2,  code = 88, on = "KP_2", off = "KP_Down"   },
    { ws = 3,  code = 89, on = "KP_3", off = "KP_Next"   },
    { ws = 4,  code = 83, on = "KP_4", off = "KP_Left"   },
    { ws = 5,  code = 84, on = "KP_5", off = "KP_Begin"  },
    { ws = 6,  code = 85, on = "KP_6", off = "KP_Right"  },
    { ws = 7,  code = 79, on = "KP_7", off = "KP_Home"   },
    { ws = 8,  code = 80, on = "KP_8", off = "KP_Up"     },
    { ws = 9,  code = 81, on = "KP_9", off = "KP_Prior"  },
    { ws = 10, code = 90, on = "KP_0", off = "KP_Insert" },
}

-- The key tokens to bind for one entry, honouring BIND_MODE.
local function tokens_for(entry)
    local t = {}
    if BIND_MODE == "code" or BIND_MODE == "both" then
        t[#t + 1] = "code:" .. entry.code
    end
    if BIND_MODE == "keysym" or BIND_MODE == "both" then
        t[#t + 1] = entry.on
        t[#t + 1] = entry.off
    end
    return t
end

for _, e in ipairs(numpad) do
    for _, key in ipairs(tokens_for(e)) do
        -- SUPER + key          -> switch to workspace
        hl.bind(mainMod .. " + " .. key,
                hl.dsp.focus({ workspace = e.ws }),
                { description = "Workspace " .. e.ws })

        -- SUPER + SHIFT + key  -> move the active window there and follow it
        hl.bind(mainMod .. " + SHIFT + " .. key,
                hl.dsp.window.move({ workspace = e.ws }),
                { description = "Move window to workspace " .. e.ws })

        -- SUPER + CTRL + key   -> send the window there, stay put
        --
        -- APPROXIMATION: window.move follows the window, so this jumps and
        -- comes straight back and you see a brief flash. If your build
        -- exposes a silent variant, collapse this to one dispatch. Check:
        --     hyprctl repl 'hl.dsp.window.move'
        hl.bind(mainMod .. " + CTRL + " .. key,
                function()
                    hl.dispatch(hl.dsp.window.move({ workspace = e.ws }))
                    hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
                end,
                { description = "Send window to workspace " .. e.ws .. " silently" })
    end
end

-- Numpad +/- for relative navigation.
-- code:86 = KP_Add (evdev 78), code:82 = KP_Subtract (evdev 74). Neither
-- collides with the workspace codes above.
hl.bind(mainMod .. " + code:86", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
hl.bind(mainMod .. " + code:82", hl.dsp.focus({ workspace = "e-1" }), { description = "Prev workspace" })

-- ======================================================================
-- 5. DIGIT-ROW WORKSPACES (kept alongside the Numpad)
-- ======================================================================
-- French AZERTY puts the digits behind Shift, so literal "1".."0" binds
-- never match. XKB keycodes 10..19 address the physical digit row whatever
-- the layout — the same technique as §4, a different key range.
for i = 1, 10 do
    local code = 9 + i   -- code:10 = physical "1" ... code:19 = physical "0"
    hl.bind(mainMod .. " + code:" .. code,
            hl.dsp.focus({ workspace = i }),
            { description = "Workspace " .. i .. " (digit row)" })
    hl.bind(mainMod .. " + SHIFT + code:" .. code,
            hl.dsp.window.move({ workspace = i }),
            { description = "Move window to workspace " .. i .. " (digit row)" })
end

-- Scroll through workspaces with SUPER + wheel.
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- ======================================================================
-- 6. HARDWARE KEYS
-- ======================================================================
-- `locked`    = still fires while hyprlock is up (volume from the lock screen)
-- `repeating` = auto-repeats while held (smooth volume/brightness ramps)

-- -l 1 caps the volume at 100%, so holding the key cannot push the sink
-- into software amplification and distortion.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })

-- -e4 = perceptual (not linear) curve, so the steps feel even at the bottom
-- of the range. -n2 = never go below 2%, so you cannot black the panel out.
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"),       { locked = true })

hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(p.volumeGui), { description = "Audio mixer" })
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(p.bluetooth), { description = "Bluetooth manager" })

-- ======================================================================
-- 7. SESSION
-- ======================================================================
-- uwsm users: replace hl.dsp.exit() with hl.dsp.exec_cmd("uwsm stop").
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit(),                     { description = "Exit Hyprland" })
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload config" })
