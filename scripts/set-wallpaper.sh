#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -f $1 ]]; then
  printf 'Uso: %s /ruta/a/imagen\n' "${0##*/}" >&2
  exit 2
fi

wallpaper=$(realpath "$1")

# Hyprpaper moderno carga la imagen al asignarla; preload/unload son IPC antiguo.
while IFS= read -r monitor; do
  hyprctl hyprpaper wallpaper "$monitor, $wallpaper, cover"
done < <(hyprctl monitors -j | jq -r '.[].name')
