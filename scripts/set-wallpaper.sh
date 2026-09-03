#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -f $1 ]]; then
  printf 'Uso: %s /ruta/a/imagen\n' "${0##*/}" >&2
  exit 2
fi

wallpaper=$(realpath "$1")
state_dir=${XDG_STATE_HOME:-"$HOME/.local/state"}/hyprland
state_file=$state_dir/wallpaper

# Hyprpaper moderno carga la imagen al asignarla; preload/unload son IPC antiguo.
while IFS= read -r monitor; do
  hyprctl hyprpaper wallpaper "$monitor, $wallpaper, cover"
done < <(hyprctl monitors -j | jq -r '.[].name')

# El estado pertenece a esta máquina y no al repositorio de dotfiles.
install -d -m 700 "$state_dir"
temporary=$(mktemp "$state_dir/.wallpaper.XXXXXX")
trap 'rm -f "$temporary"' EXIT
printf '%s\n' "$wallpaper" > "$temporary"
mv "$temporary" "$state_file"
trap - EXIT

printf 'Fondo aplicado y guardado: %s\n' "$wallpaper"
