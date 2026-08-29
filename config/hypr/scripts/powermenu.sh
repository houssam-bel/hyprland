#!/usr/bin/env bash
#
# powermenu.sh — rofi session menu, with confirmation on anything that
# closes your session or the machine.

set -euo pipefail

options="󰌾  Lock
󰤄  Suspend
󰗽  Log out
󰜉  Reboot
󰐥  Shut down"

chosen="$(echo "$options" | rofi -dmenu -i -p "Power" -theme-str 'listview { lines: 5; }')"
[[ -z "$chosen" ]] && exit 0

confirm() {
    # "No" is the first line, so Enter cancels.
    [[ "$(printf 'No\nYes' | rofi -dmenu -i -p "$1?")" == "Yes" ]]
}

case "$chosen" in
    *Lock*)        loginctl lock-session ;;
    *Suspend*)     systemctl suspend ;;
    # uwsm users: replace the dispatch with `uwsm stop`.
    *"Log out"*)   confirm "Log out"    && hyprctl dispatch 'hl.dsp.exit()' ;;
    *Reboot*)      confirm "Reboot"     && systemctl reboot ;;
    *"Shut down"*) confirm "Shut down"  && systemctl poweroff ;;
esac
