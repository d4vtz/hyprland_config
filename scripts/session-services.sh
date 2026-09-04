#!/usr/bin/env bash
set -u

run_once() {
  local process=$1
  shift
  command -v "$1" >/dev/null 2>&1 || return 0
  pgrep -u "$UID" -x "$process" >/dev/null 2>&1 || uwsm app -- "$@"
}

run_once qs qs
run_once hyprpaper hyprpaper
run_once hypridle hypridle
run_once nm-applet nm-applet --indicator
run_once blueman-applet blueman-applet
run_once kdeconnectd kdeconnectd
run_once udiskie udiskie --automount --notify --smart-tray

# Dos watchers separados conservan texto e imágenes en cliphist.
if ! pgrep -u "$UID" -f 'wl-paste --type text --watch cliphist store' >/dev/null 2>&1; then
  uwsm app -- wl-paste --type text --watch cliphist store
fi
if ! pgrep -u "$UID" -f 'wl-paste --type image --watch cliphist store' >/dev/null 2>&1; then
  uwsm app -- wl-paste --type image --watch cliphist store
fi

uwsm app -- "$HOME/.config/hypr/scripts/restore-wallpaper.sh"
