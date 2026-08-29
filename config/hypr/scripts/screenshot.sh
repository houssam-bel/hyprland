#!/usr/bin/env bash
#
# screenshot.sh — grim + slurp capture, swappy annotation, clipboard + disk.
#
# Usage:
#   screenshot.sh region   drag a rectangle
#   screenshot.sh window   click a window (geometry comes from hyprctl)
#   screenshot.sh output   the focused monitor
#   screenshot.sh full     every monitor stitched together
#
# Every mode saves to disk AND copies to the clipboard, then opens swappy.
# Pressing Escape in slurp cancels cleanly and leaves no zero-byte file.

set -euo pipefail

SAVE_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$SAVE_DIR"
FILE="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

MODE="${1:-region}"

# Hyprland's own client list, turned into the geometry list slurp wants, so
# clicking anywhere inside a window selects that whole window.
window_geometries() {
    local ws
    ws="$(hyprctl -j activeworkspace | jq '.id')"
    hyprctl -j clients | jq -r --argjson ws "$ws" '
        .[]
        | select(.workspace.id == $ws and .hidden == false and .mapped == true)
        | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
}

case "$MODE" in
    region)
        # slurp prints "X,Y WxH" and exits non-zero on Escape.
        GEOM="$(slurp -d)" || exit 0
        grim -g "$GEOM" "$FILE"
        ;;

    window)
        GEOM="$(window_geometries | slurp -r)" || exit 0
        grim -g "$GEOM" "$FILE"
        ;;

    output)
        MON="$(hyprctl -j activeworkspace | jq -r '.monitor')"
        grim -o "$MON" "$FILE"
        ;;

    full)
        grim "$FILE"
        ;;

    *)
        echo "Usage: $0 {region|window|output|full}" >&2
        exit 1
        ;;
esac

# grim can exit 0 having written nothing useful if the selection was empty.
[[ -s "$FILE" ]] || { rm -f "$FILE"; exit 0; }

# Copy BEFORE annotation, so a quick paste works even if you close swappy
# without saving.
wl-copy < "$FILE"

# -f loads a file, -o writes back to the same path. Absent swappy, the
# screenshot is already saved and copied, so this stays non-fatal.
if command -v swappy >/dev/null 2>&1; then
    swappy -f "$FILE" -o "$FILE" || true
    # Re-copy in case swappy modified it.
    wl-copy < "$FILE"
fi

notify-send -a Screenshot "Captured" "$(basename "$FILE")" -i "$FILE" 2>/dev/null || true
