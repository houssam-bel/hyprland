# Wallpapers

`install.sh` copies everything in this directory into `~/Pictures/Wallpapers`,
which is where `scripts/wallpaper.sh` looks (override with `$WALLPAPER_DIR`).

The two files here are generated gradients, committed so that the theming
pipeline works the moment you finish installing — one dark and one light, so
you can watch luminance detection pick a mode in both directions:

| File | Mean luminance | Mode chosen |
|---|---|---|
| `01-dusk-gradient.png` | ~15% | dark |
| `02-dawn-gradient.png` | ~85% | light |

They are placeholders. Drop your own images into `~/Pictures/Wallpapers` and
delete these — nothing references them by name.
