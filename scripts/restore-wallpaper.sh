#!/usr/bin/env bash
set -euo pipefail

state_file=${XDG_STATE_HOME:-"$HOME/.local/state"}/hyprland/wallpaper

[[ -r $state_file ]] || exit 0
IFS= read -r wallpaper < "$state_file"

if [[ ! -f $wallpaper ]]; then
  printf 'No se restauró el fondo: ya no existe %s\n' "$wallpaper" >&2
  exit 1
fi

# Hyprpaper puede tardar unos instantes en exponer su socket IPC.
for _ in {1..30}; do
  if monitors=$(hyprctl monitors -j 2>/dev/null) &&
     jq -e 'length > 0' >/dev/null <<<"$monitors"; then
    applied=true
    while IFS= read -r monitor; do
      if ! hyprctl hyprpaper wallpaper "$monitor, $wallpaper, cover" >/dev/null 2>&1; then
        applied=false
        break
      fi
    done < <(jq -r '.[].name' <<<"$monitors")

    [[ $applied == true ]] && exit 0
  fi
  sleep 0.2
done

printf 'Hyprpaper no estuvo disponible para restaurar el fondo.\n' >&2
exit 1
