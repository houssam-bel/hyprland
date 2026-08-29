#!/usr/bin/env bash
#
# theme.sh — force light or dark, independent of wallpaper luminance.
#
# Usage:
#   theme.sh light    force light
#   theme.sh dark     force dark
#   theme.sh toggle   flip the current mode
#   theme.sh auto     hand control back to wallpaper luminance
#   theme.sh status   print the current mode
#
# The pin is a file, ~/.cache/theme_mode, which wallpaper.sh reads on every
# run. That indirection is the whole point: it is what makes a forced mode
# survive the next wallpaper change instead of being silently overridden.

set -euo pipefail

MODE_FILE="${MODE_FILE:-$HOME/.cache/theme_mode}"
WALL_FILE="${STATE_FILE:-$HOME/.cache/current_wallpaper}"

mkdir -p "$(dirname "$MODE_FILE")"

current() { cat "$MODE_FILE" 2>/dev/null || echo auto; }

# Re-render every template in the given mode. post_hooks handle the reloads.
apply_mode() {
    local mode="$1" wallpaper
    wallpaper="$(cat "$WALL_FILE" 2>/dev/null || true)"

    [[ -n "$wallpaper" && -f "$wallpaper" ]] || {
        echo "theme.sh: no current wallpaper recorded — run wallpaper.sh first." >&2
        exit 1
    }

    matugen image "$wallpaper" --mode "$mode"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-${mode}" 2>/dev/null || true
}

case "${1:-toggle}" in
    light|dark)
        MODE="$1"
        echo "$MODE" > "$MODE_FILE"
        apply_mode "$MODE"
        notify-send -a Theme "Theme forced to ${MODE}" 2>/dev/null || true
        ;;

    toggle)
        # From "auto" the first toggle goes to dark, so one keypress always
        # produces a visible change rather than a no-op.
        if [[ "$(current)" == "light" ]]; then MODE=dark; else MODE=light; fi
        echo "$MODE" > "$MODE_FILE"
        apply_mode "$MODE"
        notify-send -a Theme "Theme forced to ${MODE}" 2>/dev/null || true
        ;;

    auto)
        echo auto > "$MODE_FILE"
        # Re-run the wallpaper path so luminance detection decides again.
        WALLPAPER="$(cat "$WALL_FILE" 2>/dev/null || true)"
        [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]] || {
            echo "theme.sh: no current wallpaper recorded." >&2
            exit 1
        }
        notify-send -a Theme "Theme follows the wallpaper again" 2>/dev/null || true
        exec "$(dirname "$(readlink -f "$0")")/wallpaper.sh" "$WALLPAPER"
        ;;

    status)
        current
        ;;

    *)
        echo "Usage: $0 {light|dark|toggle|auto|status}" >&2
        exit 1
        ;;
esac
