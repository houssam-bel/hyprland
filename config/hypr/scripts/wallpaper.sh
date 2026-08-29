#!/usr/bin/env bash
#
# wallpaper.sh — set the wallpaper and regenerate the whole colour scheme.
#
# Usage:
#   wallpaper.sh random         pick at random from $WALLPAPER_DIR
#   wallpaper.sh pick           choose one through rofi
#   wallpaper.sh restore        re-apply the cached wallpaper, no retheme
#   wallpaper.sh init           daemon + restore, or random on a first run
#   wallpaper.sh /path/to/img   set a specific file
#
# Light vs dark is decided from the image's mean luminance UNLESS theme.sh
# has pinned a mode in $MODE_FILE.
#
# Component reloads are NOT done here. Every Matugen template owns its own
# post_hook, so `matugen image X` behaves identically to running this
# script — one code path, not two that can drift apart.

set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
STATE_FILE="${STATE_FILE:-$HOME/.cache/current_wallpaper}"
MODE_FILE="${MODE_FILE:-$HOME/.cache/theme_mode}"

# Transition. "grow" expands from a point; combined with --transition-pos at
# the cursor it reads as though the click itself painted the new wallpaper.
TRANSITION_TYPE="${TRANSITION_TYPE:-grow}"
TRANSITION_FPS="${TRANSITION_FPS:-60}"
TRANSITION_DURATION="${TRANSITION_DURATION:-1.2}"

# Mean luminance above this percentage counts as a light image.
LIGHT_THRESHOLD="${LIGHT_THRESHOLD:-55}"

mkdir -p "$(dirname "$STATE_FILE")" "$WALLPAPER_DIR"

# --- Backend -----------------------------------------------------------
# awww is the animated fork this config is written against; swww is the
# upstream it forked from and takes the same flags. Preferring awww and
# falling back keeps the config working on a machine that only has one.
if [[ -n "${WALLPAPER_BACKEND:-}" ]]; then
    :
elif command -v awww >/dev/null 2>&1; then
    WALLPAPER_BACKEND=awww
elif command -v swww >/dev/null 2>&1; then
    WALLPAPER_BACKEND=swww
else
    echo "wallpaper.sh: neither awww nor swww is installed." >&2
    exit 1
fi
DAEMON="${WALLPAPER_BACKEND}-daemon"

die() { echo "wallpaper.sh: $*" >&2; exit 1; }

# All the image types the backend can decode.
list_wallpapers() {
    find -L "$WALLPAPER_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
        -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' \) "$@"
}

# `query` fails when nothing is listening — that is the liveness probe.
# The loop is a real readiness wait: the daemon has to have its socket up
# before the client can talk to it, and a fixed `sleep 1` is a guess that is
# either too short on a cold boot or wasted time on a warm one.
ensure_daemon() {
    "$WALLPAPER_BACKEND" query >/dev/null 2>&1 && return 0

    setsid "$DAEMON" >/dev/null 2>&1 &

    local waited=0
    while (( waited < 40 )); do     # 40 x 0.1s = 4s ceiling
        "$WALLPAPER_BACKEND" query >/dev/null 2>&1 && return 0
        sleep 0.1
        waited=$(( waited + 1 ))
    done

    die "$DAEMON did not come up within 4s"
}

apply() {
    local img="$1"
    local pos_args=()

    # Grow/outer transitions look best originating at the cursor. hyprctl is
    # absent when this runs outside a Hyprland session, so it stays optional.
    if [[ "$TRANSITION_TYPE" == "grow" || "$TRANSITION_TYPE" == "outer" ]] \
       && command -v hyprctl >/dev/null 2>&1; then
        local pos
        pos="$(hyprctl cursorpos 2>/dev/null | tr -d ' ')" || pos=""
        [[ -n "$pos" ]] && pos_args=(--transition-pos "$pos")
    fi

    "$WALLPAPER_BACKEND" img "$img" \
        --transition-type "$TRANSITION_TYPE" \
        --transition-fps "$TRANSITION_FPS" \
        --transition-duration "$TRANSITION_DURATION" \
        "${pos_args[@]}"
}

# Mean luminance, 0-100. Scaling to a single pixel makes that pixel's grey
# value the average of the whole image — one ImageMagick call instead of a
# histogram walk.
luminance() {
    local img="$1" magick_bin=""
    command -v magick  >/dev/null 2>&1 && magick_bin=magick
    [[ -z "$magick_bin" ]] && command -v convert >/dev/null 2>&1 && magick_bin=convert
    [[ -z "$magick_bin" ]] && { echo 40; return; }   # assume dark; matches most wallpapers

    "$magick_bin" "$img" -colorspace Gray -resize 1x1 \
        -format "%[fx:int(mean*100)]" info: 2>/dev/null || echo 40
}

resolve_mode() {
    local img="$1" forced
    forced="$(cat "$MODE_FILE" 2>/dev/null || echo auto)"

    # Anything other than the literal words light/dark — including a missing
    # file — means "decide from the image".
    if [[ "$forced" == "light" || "$forced" == "dark" ]]; then
        echo "Mode pinned to ${forced} by theme.sh" >&2
        echo "$forced"
        return
    fi

    local brightness
    brightness="$(luminance "$img")"
    if (( brightness > LIGHT_THRESHOLD )); then
        echo "Mean luminance ${brightness}% -> light theme" >&2
        echo light
    else
        echo "Mean luminance ${brightness}% -> dark theme" >&2
        echo dark
    fi
}

retheme() {
    local img="$1" mode
    mode="$(resolve_mode "$img")"

    # Renders every template in ~/.config/matugen/config.toml and fires each
    # one's post_hook. Hyprland, Waybar, SwayNC, Kitty, Rofi, GTK and
    # hyprlock all pick up the new palette from this single call.
    matugen image "$img" --mode "$mode"

    # The one thing no template can do: GTK's light/dark preference is a
    # gsettings key, not a file.
    gsettings set org.gnome.desktop.interface color-scheme "prefer-${mode}" 2>/dev/null || true

    notify-send -a Wallpaper "Theme updated" \
        "$(basename "$img") · ${mode}" -i "$img" 2>/dev/null || true
}

# --- Resolve which image to use ----------------------------------------
ACTION="${1:-random}"

case "$ACTION" in
    restore|init)
        ensure_daemon
        CACHED="$(cat "$STATE_FILE" 2>/dev/null || true)"

        if [[ -n "$CACHED" && -f "$CACHED" ]]; then
            apply "$CACHED"
            exit 0
        fi

        # No cache. `restore` has nothing to do; `init` falls through to
        # random so a first login is not a black screen.
        [[ "$ACTION" == "restore" ]] && exit 0
        ACTION=random
        ;;
esac

case "$ACTION" in
    random)
        # -print0 / -z keeps filenames containing spaces intact through shuf.
        WALLPAPER="$(list_wallpapers -print0 | shuf -z -n1 | tr -d '\0')"
        ;;
    pick)
        WALLPAPER="$(list_wallpapers -print | sort | rofi -dmenu -i -p "Wallpaper")"
        ;;
    *)
        WALLPAPER="$ACTION"
        ;;
esac

[[ -n "${WALLPAPER:-}" ]] || die "no wallpaper selected (is $WALLPAPER_DIR empty?)"
[[ -f "$WALLPAPER" ]]     || die "not a file: $WALLPAPER"

# Absolute path: the state file is read by hyprlock and by `restore` from a
# different working directory.
WALLPAPER="$(readlink -f "$WALLPAPER")"

ensure_daemon
apply "$WALLPAPER"
echo "$WALLPAPER" > "$STATE_FILE"
retheme "$WALLPAPER"
