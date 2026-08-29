#!/usr/bin/env bash
#
# install.sh — link this repository into ~/.config.
#
# Usage:
#   ./install.sh                install everything
#   ./install.sh --dry-run      print what would happen, change nothing
#   ./install.sh --copy         copy instead of symlink
#   ./install.sh --packages     also install the package lists with pacman
#   ./install.sh hypr waybar    install only the named components
#
# Symlinks are the default so that editing ~/.config/hypr/... edits the
# repository — `git diff` stays meaningful and there is no "which copy is
# real" question. Use --copy if you want the two to diverge.
#
# Anything already present at a destination is MOVED to a timestamped
# backup directory, never deleted.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
SRC_DIR="$REPO_DIR/config"
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
MODE="link"
WITH_PACKAGES=0
COMPONENTS=()

# ---- Colours, but only on a real terminal -----------------------------
if [[ -t 1 ]]; then
    B=$'\e[1m'; G=$'\e[32m'; Y=$'\e[33m'; R=$'\e[31m'; N=$'\e[0m'
else
    B=""; G=""; Y=""; R=""; N=""
fi

info() { echo "${B}::${N} $*"; }
ok()   { echo "  ${G}✓${N} $*"; }
warn() { echo "  ${Y}!${N} $*"; }
err()  { echo "  ${R}✗${N} $*" >&2; }

run() {
    if (( DRY_RUN )); then
        echo "  ${Y}would run:${N} $*"
    else
        "$@"
    fi
}

# ---- Arguments ---------------------------------------------------------
while (( $# )); do
    case "$1" in
        --dry-run)  DRY_RUN=1 ;;
        --copy)     MODE=copy ;;
        --packages) WITH_PACKAGES=1 ;;
        -h|--help)  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*)         err "unknown option: $1"; exit 1 ;;
        *)          COMPONENTS+=("$1") ;;
    esac
    shift
done

# No components named = every directory under config/.
if (( ${#COMPONENTS[@]} == 0 )); then
    while IFS= read -r d; do COMPONENTS+=("$(basename "$d")"); done \
        < <(find "$SRC_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
fi

# ---- Packages ----------------------------------------------------------
install_packages() {
    info "Installing packages"

    if ! command -v pacman >/dev/null 2>&1; then
        err "pacman not found — this installer targets Arch Linux"
        return 1
    fi

    # Read into an ARRAY, not a string: a package list expanded unquoted
    # would be glob-expanded against the working directory, and quoted it
    # would arrive as one absurd package name.
    local pkgs=()
    mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$REPO_DIR/packages/pacman.txt")
    (( ${#pkgs[@]} )) && run sudo pacman -S --needed --noconfirm "${pkgs[@]}"

    if command -v yay >/dev/null 2>&1 || command -v paru >/dev/null 2>&1; then
        local helper
        helper="$(command -v yay || command -v paru)"
        local aur=()
        mapfile -t aur < <(grep -vE '^\s*(#|$)' "$REPO_DIR/packages/aur.txt")
        (( ${#aur[@]} )) && run "$helper" -S --needed --noconfirm "${aur[@]}"
    else
        warn "no AUR helper (yay/paru) — skipping packages/aur.txt"
        warn "install those by hand, or the animated wallpaper backend will be missing"
    fi
}

# ---- Linking -----------------------------------------------------------
link_component() {
    local name="$1"
    local src="$SRC_DIR/$name"
    local dest="$DEST_DIR/$name"

    [[ -d "$src" ]] || { err "no such component: $name"; return 1; }

    # An existing correct symlink is a no-op, not a backup-and-relink.
    if [[ -L "$dest" && "$(readlink -f "$dest")" == "$src" ]]; then
        ok "$name (already linked)"
        return 0
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        run mkdir -p "$BACKUP_DIR"
        run mv "$dest" "$BACKUP_DIR/$name"
        warn "$name — existing config moved to $BACKUP_DIR/$name"
    fi

    run mkdir -p "$DEST_DIR"

    if [[ "$MODE" == "copy" ]]; then
        run cp -r "$src" "$dest"
        ok "$name (copied)"
    else
        run ln -s "$src" "$dest"
        ok "$name (linked)"
    fi
}

# ---- Directories the scripts assume exist ------------------------------
make_dirs() {
    info "Creating working directories"
    local d
    for d in "$HOME/Pictures/Wallpapers" \
             "$HOME/Pictures/Screenshots" \
             "$HOME/Videos/Recordings" \
             "$HOME/.cache"; do
        run mkdir -p "$d"
        ok "$d"
    done
}

# ---- Seed wallpapers ---------------------------------------------------
# Copied, not linked: ~/Pictures/Wallpapers is yours to add to and delete
# from, and a symlink farm would make deleting one of these confusing.
seed_wallpapers() {
    local assets="$SRC_DIR/hypr/assets/wallpapers"
    shopt -s nullglob
    local files=("$assets"/*.{jpg,jpeg,png,webp})
    shopt -u nullglob

    (( ${#files[@]} )) || return 0

    info "Seeding wallpapers"
    local f
    for f in "${files[@]}"; do
        if [[ -e "$HOME/Pictures/Wallpapers/$(basename "$f")" ]]; then
            ok "$(basename "$f") (already there)"
        else
            run cp "$f" "$HOME/Pictures/Wallpapers/"
            ok "$(basename "$f")"
        fi
    done
}

# ---- Main --------------------------------------------------------------
(( DRY_RUN )) && info "${Y}DRY RUN${N} — nothing will be changed"

(( WITH_PACKAGES )) && install_packages

info "Linking components into $DEST_DIR"
FAILED=0
for c in "${COMPONENTS[@]}"; do
    link_component "$c" || FAILED=1
done

make_dirs
seed_wallpapers

info "Making helper scripts executable"
run chmod +x "$SRC_DIR"/hypr/scripts/*.sh
ok "config/hypr/scripts/*.sh"

echo
if (( FAILED )); then
    err "Finished with errors — see above."
    exit 1
fi

cat <<'NEXT'
Done.

Next steps
  1. Put some images in ~/Pictures/Wallpapers
  2. Generate the first palette:
       ~/.config/hypr/scripts/wallpaper.sh random
  3. Reload Hyprland and check for config errors:
       hyprctl reload && hyprctl configerrors

If you use a display manager, log out and pick the Hyprland session.
NEXT
