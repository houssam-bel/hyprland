#!/usr/bin/env bash
#
# record.sh — screen recording with region selection and an audio toggle.
#
# Usage:
#   record.sh region        record a dragged rectangle (no audio)
#   record.sh screen        record the focused monitor (no audio)
#   record.sh region-audio  region + default microphone
#   record.sh screen-audio  monitor + default microphone
#   record.sh stop          stop the running recording
#   record.sh status        print an indicator for Waybar (empty when idle)
#
# Prefers wl-screenrec (VAAPI, low CPU) and falls back to wf-recorder.

set -uo pipefail

SAVE_DIR="${RECORDING_DIR:-$HOME/Videos/Recordings}"
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/screenrec.pid"
mkdir -p "$SAVE_DIR"

running() {
    [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

# --- status: Waybar calls this once a second, so it must be cheap and quiet
if [[ "${1:-}" == "status" ]]; then
    running && echo "󰑊 REC"
    exit 0
fi

# --- stop ----------------------------------------------------------------
if [[ "${1:-}" == "stop" ]]; then
    if running; then
        # SIGINT, not SIGKILL: the encoder has to finalise the container or
        # the file is unplayable.
        kill -INT "$(cat "$PIDFILE")" 2>/dev/null || true
        rm -f "$PIDFILE"
        notify-send -a Recorder "Recording stopped" "Saved to $SAVE_DIR"
    else
        notify-send -a Recorder "Nothing is recording"
    fi
    exit 0
fi

# --- refuse to start twice ------------------------------------------------
if running; then
    notify-send -a Recorder "Already recording" "Click the indicator to stop"
    exit 1
fi

# --- pick a backend -------------------------------------------------------
if command -v wl-screenrec >/dev/null 2>&1 && vainfo 2>/dev/null | grep -q EncSlice; then
    BACKEND=wl-screenrec
elif command -v wf-recorder >/dev/null 2>&1; then
    BACKEND=wf-recorder
else
    notify-send -a Recorder "No recorder installed" "Install wl-screenrec or wf-recorder"
    exit 1
fi

FILE="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).mp4"
MODE="${1:-region}"
ARGS=()

case "$MODE" in
    region|region-audio)
        GEOM="$(slurp)" || exit 0        # non-zero = Escape
        ARGS+=(-g "$GEOM")
        ;;
    screen|screen-audio)
        MON="$(hyprctl -j activeworkspace | jq -r '.monitor')"
        ARGS+=(-o "$MON")
        ;;
    *)
        echo "Usage: $0 {region|screen|region-audio|screen-audio|stop|status}" >&2
        exit 1
        ;;
esac

[[ "$MODE" == *-audio ]] && ARGS+=(--audio)

# A 3s countdown so the notification and any menu are gone before capture
# starts — otherwise the first frames are of the menu you just used.
notify-send -a Recorder "Recording in 3s" "$MODE"
sleep 3

"$BACKEND" "${ARGS[@]}" -f "$FILE" &
echo $! > "$PIDFILE"

notify-send -a Recorder "Recording started" "$(basename "$FILE")"
