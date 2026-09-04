#!/usr/bin/env bash
set -euo pipefail

choice=$(printf '%s\n' 'Aplicaciones' 'Ventanas' 'Archivos' 'Portapapeles' | rofi -dmenu -i -p 'Buscar') || exit 0

case "$choice" in
  Aplicaciones) exec rofi -show drun ;;
  Ventanas) exec rofi -show window ;;
  Portapapeles) exec qs ipc call system clipboard ;;
  Archivos)
    command -v fd >/dev/null 2>&1 || {
      notify-send 'Búsqueda de archivos' 'Instala fd para habilitar esta función.'
      exit 1
    }
    selected=$(fd --type f --hidden --exclude .git . "$HOME" 2>/dev/null \
      | sed "s|^$HOME/||" | rofi -dmenu -i -p 'Abrir archivo') || exit 0
    [[ -n $selected ]] && xdg-open "$HOME/$selected"
    ;;
esac
