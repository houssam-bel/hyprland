# Theming

How one wallpaper change repaints the whole desktop, and how to extend it.

## The chain

```
scripts/wallpaper.sh
   │
   1. resolve an image        random | rofi pick | explicit path
   2. ensure the daemon       awww query as a liveness probe, then poll
                              the socket for up to 4s
   3. apply it                awww img --transition-type grow
                              --transition-pos <cursor>
   4. remember it             ~/.cache/current_wallpaper
   5. decide the mode         ~/.cache/theme_mode pins light|dark,
                              otherwise mean luminance > 55% = light
   6. matugen image "$WALLPAPER" --mode "$MODE"
   7. gsettings color-scheme  the one thing no template can do
```

Step 6 is where everything happens. Matugen renders each template and runs
that template's own `post_hook`.

| Template | Output | Hook |
|---|---|---|
| `hyprland-colors.lua` | `hypr/settings/colors.lua` | `hyprctl reload` |
| `gtk-css-colors.css` | `waybar/colors.css` | `pkill -SIGUSR2 waybar` |
| `gtk-css-colors.css` | `swaync/colors.css` | `swaync-client -rs` |
| `kitty-colors.conf` | `kitty/colors.conf` | `pkill -SIGUSR1 kitty` |
| `rofi-colors.rasi` | `rofi/colors.rasi` | — |
| `gtk-app-colors.css` | `gtk-3.0/gtk.css`, `gtk-4.0/gtk.css` | — |
| `hyprlock-colors.conf` | `hypr/hyprlock-colors.conf` | — |

The three without a hook do not need one: rofi and hyprlock read their config
at launch, and GTK applications read `gtk.css` at startup. Nothing is missing.

## Why reloads live in Matugen, not in the script

Every `[templates.*]` block owns its `post_hook`, so:

```bash
matugen image ~/Pictures/Wallpapers/foo.jpg --mode dark
```

does exactly what `wallpaper.sh` does — minus setting the wallpaper itself.
One code path, not two that drift. `reload_apps` / `reload_apps_list` are
deliberately unused: their schema has moved between Matugen major versions,
while explicit hooks are version-stable and you can read what they do.

## The `require()` cache trap

This is the single most confusing failure in the whole pipeline.

Lua's `require()` memoises by module name. Matugen rewrites
`settings/colors.lua` and fires `hyprctl reload`; Hyprland re-runs
`hyprland.lua`; `require("settings/colors")` returns the **cached** table from
before the rewrite. The colours never change and nothing errors.

Two places clear the cache, both deliberately:

- `settings/init.lua` clears `package.loaded` for every module before loading.
- `settings/look_and_feel.lua` clears `settings/colors` immediately before
  requiring it, so the module is still correct if loaded on its own.

## Colour name conventions

Three different syntaxes, and the differences are real:

| Consumer | Syntax | Example |
|---|---|---|
| GTK CSS (Waybar, SwayNC, GTK apps) | underscores | `@on_surface` |
| rasi (rofi) | hyphens | `@on-surface` |
| hyprlang (hyprlock) | `$` variables | `$on_surface` |
| Lua (Hyprland) | table keys | `colors.on_surface` |

Do not "fix" one to match another — they are different languages.

## The Lua contract

`settings/look_and_feel.lua` requires exactly six keys from
`settings/colors.lua`:

```
primary   secondary   surface   on_surface   outline   error
```

each an `"rgba(RRGGBBAA)"` or `"rgb(RRGGBB)"` string. Drop one and
`col.inactive_border` becomes `nil`, which errors on reload. There is a
fallback palette inline in `look_and_feel.lua` so a fresh clone loads before
Matugen has ever run.

Verify the contract after a change:

```bash
lua -e 'local t = dofile(os.getenv("HOME").."/.config/hypr/settings/colors.lua")
        for _,k in ipairs{"primary","secondary","surface","on_surface","outline","error"} do
          print(k, t[k] or "*** MISSING ***")
        end'
```

## Forcing light or dark

`theme.sh` writes `~/.cache/theme_mode`. `wallpaper.sh` reads it **before**
running luminance detection, so a forced mode survives the next wallpaper
change instead of being silently overridden on the next `SUPER + W`.

```bash
theme.sh dark      # pin dark
theme.sh toggle    # flip
theme.sh auto      # remove the pin, re-run detection on the current wallpaper
theme.sh status    # light | dark | auto
```

Anything other than the literal words `light` or `dark` in that file —
including a missing file — means "decide from the image".

## Adding a new consumer

Say you want `btop` to follow the wallpaper.

1. Write `config/matugen/templates/btop-colors.theme`, using
   `{{colors.<name>.default.hex}}` placeholders. Run
   `matugen image X --dry-run --show-colors` to see every available name.
2. Add a block to `config/matugen/config.toml`:

   ```toml
   [templates.btop]
   input_path  = "~/.config/matugen/templates/btop-colors.theme"
   output_path = "~/.config/btop/themes/matugen.theme"
   ```

3. Add a `post_hook` only if the app can reload live. If it reads its config
   at startup, leave it out — a hook that does nothing is worse than none,
   because it looks like it should work.
4. Commit a seed output file if the app fails to start without one. Waybar and
   rofi both do; that is why their `colors.*` files are tracked.

## Verifying a render

The classic silent failure is a typo'd colour name: Matugen leaves the literal
`{{...}}` in the output rather than erroring.

```bash
# 1. Render from a known wallpaper.
matugen image ~/Pictures/Wallpapers/01-dusk-gradient.png --mode dark

# 2. Every output exists and is non-empty.
for f in ~/.config/hypr/settings/colors.lua \
         ~/.config/waybar/colors.css \
         ~/.config/swaync/colors.css \
         ~/.config/rofi/colors.rasi \
         ~/.config/kitty/colors.conf \
         ~/.config/gtk-3.0/gtk.css \
         ~/.config/gtk-4.0/gtk.css \
         ~/.config/hypr/hyprlock-colors.conf; do
  printf '%-45s %s\n' "$f" "$( [[ -s $f ]] && echo OK || echo 'MISSING/EMPTY' )"
done

# 3. No unrendered keywords. This must print NOTHING.
grep -rn '{{' ~/.config/hypr/settings/colors.lua ~/.config/waybar/colors.css \
              ~/.config/rofi/colors.rasi ~/.config/kitty/colors.conf \
              ~/.config/gtk-3.0/gtk.css
```

If step 3 prints lines from `kitty/colors.conf` mentioning `base16`, your
Matugen build does not expose base16 keywords. Delete that block from
`templates/kitty-colors.conf`; the Material colours above it are enough for a
usable terminal.

## Luminance detection

```bash
magick "$WALLPAPER" -colorspace Gray -resize 1x1 -format "%[fx:int(mean*100)]" info:
```

Scaling to a single pixel makes that pixel's grey value the mean of the whole
image — one ImageMagick call rather than a histogram walk. Above
`LIGHT_THRESHOLD` (default 55) the image counts as light.

With no ImageMagick installed the function returns 40, i.e. dark, which is the
right guess for the large majority of wallpapers.
