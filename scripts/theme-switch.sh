#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
theme=${1:-}

if [[ -z $theme || ! -f "$root/themes/$theme.lua" ||
      ! -f "$root/themes/$theme.css" ||
      ! -f "$root/themes/$theme.rasi" ||
      ! -f "$root/themes/$theme-hyprlock.conf" ]]; then
  printf 'Tema inválido. Temas completos disponibles:\n' >&2
  find "$root/themes" -maxdepth 1 -name '*.lua' -printf '  %f\n' |
    sed 's/\.lua$//' >&2
  exit 2
fi

sed -i -E 's/theme = "[^"]+"/theme = "'"$theme"'"/' "$root/lua/settings.lua"
ln -sfn "$theme.css" "$root/themes/current.css"
ln -sfn "$theme.rasi" "$root/themes/current.rasi"
ln -sfn "$theme-hyprlock.conf" "$root/themes/current-hyprlock.conf"

hyprctl reload
pkill -SIGUSR2 waybar || true
swaync-client -R
swaync-client -rs
printf 'Tema activo: %s\n' "$theme"
