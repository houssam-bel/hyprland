# Keybindings

Generated from `config/hypr/settings/keybindings.lua`. `SUPER` is the main
modifier, set once as `mainMod` in `settings/programs.lua`.

## Letters in use

Check here before adding a bind.

```
A pin        B browser    C colour-pick  D launcher   E files
F fullscreen G group      L lock         N notifs     P pseudotile
Q close      R run        T split        U scratchpad V clipboard
W wallpaper

Free: H I J K M O X Y
SUPER+ALT+{Z,Q,S,D} is reserved for directional focus.
```

## Applications

| Bind | Action |
|---|---|
| `SUPER + Return` | Terminal (kitty) |
| ``SUPER + ` `` | Drop-down scratchpad terminal |
| `SUPER + E` | File manager (Dolphin) |
| `SUPER + B` | Browser (Firefox) |
| `SUPER + D` | App launcher (`rofi -show drun`) |
| `SUPER + R` | Run a command (`rofi -show run`) |
| `SUPER + Tab` | Window switcher (`rofi -show window`) |
| `SUPER + N` | Notification centre (SwayNC) |
| `SUPER + L` | Lock screen (hyprlock) |

## Window management

| Bind | Action |
|---|---|
| `SUPER + Q` | Close window |
| `SUPER + SHIFT + Q` | Force kill window |
| `SUPER + Space` | Toggle floating |
| `SUPER + F` | Fullscreen |
| `SUPER + SHIFT + F` | Maximise (keeps the bar) |
| `SUPER + P` | Pseudotile |
| `SUPER + A` | Pin to all workspaces |
| `SUPER + G` | Toggle tab group |
| `SUPER + T` | Toggle split direction |
| `SUPER + ← ↑ ↓ →` | Focus in that direction |
| `SUPER + ALT + Q S Z D` | Focus left/down/up/right (AZERTY home row) |
| `SUPER + SHIFT + ← ↑ ↓ →` | Swap window in that direction |
| `SUPER + CTRL + ← →` | Move window to the left/right monitor |
| `SUPER + left-drag` | Move window |
| `SUPER + right-drag` | Resize window |
| `SUPER + U` | Toggle the scratchpad (`special:magic`) |
| `SUPER + SHIFT + U` | Send window to the scratchpad |

Dragging any border or gap also resizes, without a modifier
(`general.resize_on_border`).

## Workspaces

| Bind | Action |
|---|---|
| `SUPER + Numpad 1-0` | Switch to workspace 1-10 |
| `SUPER + SHIFT + Numpad` | Move the window there and follow it |
| `SUPER + CTRL + Numpad` | Send the window there, stay put |
| `SUPER + 1-0` (digit row) | Switch to workspace 1-10 |
| `SUPER + SHIFT + 1-0` | Move the window there |
| `SUPER + Numpad + / -` | Next / previous workspace |
| `SUPER + scroll` | Next / previous workspace |

Both ranges are bound by **XKB keycode**, not keysym.

For the Numpad that is because every key emits two different keysyms
depending on NumLock (`KP_1` vs `KP_End`, and so on). A config binding only
`KP_1`..`KP_9` works until NumLock is toggled once and then silently stops —
the reason so many Numpad configs "randomly break". Raw `code:NN` is read
before XKB translation, so it is identical in both states. The keysym pairs
are bound as well, belt and braces; duplicate binds to the same action are
harmless.

For the digit row it is because French AZERTY puts the digits behind Shift,
so literal `"1"`..`"0"` binds never match. `code:10`..`code:19` address the
physical keys whatever the layout.

Check any key with `wev -f wl_keyboard:key`. It reports XKB keycodes, which
match the table in `keybindings.lua` verbatim — do **not** add 8 to what it
prints.

## Screenshots, clipboard, theming

| Bind | Action |
|---|---|
| `Print` | Screenshot a region |
| `SHIFT + Print` | Screenshot a window |
| `CTRL + Print` | Screenshot the focused monitor |
| `ALT + Print` | Screenshot every monitor |
| `SUPER + SHIFT + S` | Screenshot a region (alias) |
| `SUPER + C` | Colour picker, copied to the clipboard |
| `SUPER + V` | Clipboard history |
| `SUPER + SHIFT + V` | Delete a clipboard entry |
| `SUPER + W` | Random wallpaper + full retheme |
| `SUPER + SHIFT + W` | Pick a wallpaper + full retheme |
| `SUPER + SHIFT + T` | Force light / dark |
| `SUPER + CTRL + T` | Theme follows the wallpaper again |

## Recording

| Bind | Action |
|---|---|
| `SUPER + F9` | Record a region |
| `SUPER + SHIFT + F9` | Record a region with microphone |
| `SUPER + F10` | Record the focused monitor |
| `SUPER + F11` | Stop recording |

A `REC` indicator appears in Waybar while recording; clicking it stops.

## Hardware keys

All flagged `locked`, so they still work on the lock screen. Volume and
brightness also `repeating`, so holding them ramps smoothly.

| Key | Action |
|---|---|
| `XF86AudioRaiseVolume` / `LowerVolume` | Volume ±5% (capped at 100%) |
| `XF86AudioMute` / `MicMute` | Mute output / input |
| `XF86MonBrightnessUp` / `Down` | Brightness ±5%, perceptual curve, 2% floor |
| `XF86AudioNext` / `Prev` / `Play` / `Pause` / `Stop` | playerctl |
| `SUPER + SHIFT + M` | Audio mixer (pavucontrol) |
| `SUPER + SHIFT + B` | Bluetooth manager (blueman) |

## Session

| Bind | Action |
|---|---|
| `SUPER + SHIFT + P` | Power menu |
| `SUPER + SHIFT + R` | Reload the config |
| `SUPER + SHIFT + E` | Exit Hyprland |
