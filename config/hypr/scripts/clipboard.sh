#!/usr/bin/env bash
#
# clipboard.sh — browse and restore cliphist history through rofi.
#
# Usage:
#   clipboard.sh show     pick an entry and copy it back
#   clipboard.sh delete   pick an entry and remove it from history
#   clipboard.sh wipe     clear the entire history (asks first)
#
# Requires the two wl-paste watchers started in settings/autostart.lua.
# Without them the history is always empty and this looks broken.

set -euo pipefail

command -v cliphist >/dev/null 2>&1 || {
    notify-send -a Clipboard "cliphist is not installed" 2>/dev/null || true
    exit 1
}

case "${1:-show}" in
    show)
        # cliphist list emits "<id>\t<preview>". -display-columns 2 hides the
        # numeric id in the menu while the full line still reaches decode —
        # decode needs the id, you do not need to look at it.
        cliphist list \
            | rofi -dmenu -i -p "Clipboard" -display-columns 2 \
            | cliphist decode \
            | wl-copy
        ;;

    delete)
        cliphist list \
            | rofi -dmenu -i -p "Delete" -display-columns 2 \
            | cliphist delete
        notify-send -a Clipboard "Entry deleted" 2>/dev/null || true
        ;;

    wipe)
        # Confirm first — this is irreversible. "No" is the first line, so a
        # reflexive Enter cancels rather than wipes.
        CONFIRM="$(printf 'No\nYes' | rofi -dmenu -i -p "Wipe all clipboard history?")"
        if [[ "$CONFIRM" == "Yes" ]]; then
            cliphist wipe
            notify-send -a Clipboard "History wiped" 2>/dev/null || true
        fi
        ;;

    *)
        echo "Usage: $0 {show|delete|wipe}" >&2
        exit 1
        ;;
esac
