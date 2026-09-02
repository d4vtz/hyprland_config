#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -f $1 ]]; then
  printf 'Uso: %s /ruta/a/imagen\n' "${0##*/}" >&2
  exit 2
fi

wallpaper=$(realpath "$1")
hyprctl hyprpaper preload "$wallpaper"
hyprctl hyprpaper wallpaper ",$wallpaper"
hyprctl hyprpaper unload unused
