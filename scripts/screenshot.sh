#!/usr/bin/env bash
set -euo pipefail

target=${1:-area}
action=${2:-edit}
directory=${XDG_PICTURES_DIR:-"$HOME/Imágenes"}/Capturas
mkdir -p "$directory"
file="$directory/$(date +'%Y-%m-%d_%H-%M-%S').png"

command -v grimblast >/dev/null 2>&1 || {
  notify-send 'Capturas' 'No se encontró grimblast.'
  exit 127
}

case "$action" in
  copy)
    grimblast --notify copy "$target"
    ;;
  edit)
    grimblast save "$target" "$file" || exit 0
    if command -v satty >/dev/null 2>&1; then
      satty --filename "$file" --output-filename "$file"
    else
      notify-send 'Captura guardada' "$file"
    fi
    ;;
  save)
    grimblast --notify save "$target" "$file"
    ;;
  *)
    printf 'Uso: %s {area|output|active} {edit|copy|save}\n' "$0" >&2
    exit 2
    ;;
esac
