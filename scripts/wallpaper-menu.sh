#!/usr/bin/env bash
set -euo pipefail

start_dir="${HOME}/Imágenes"
[[ -d "$start_dir" ]] || start_dir="$HOME"

if command -v kdialog >/dev/null 2>&1; then
    file="$(kdialog --getopenfilename "$start_dir" "*.png *.jpg *.jpeg *.webp|Imágenes" 2>/dev/null || true)"
elif command -v zenity >/dev/null 2>&1; then
    file="$(zenity --file-selection --title="Seleccionar fondo" --filename="$start_dir/" 2>/dev/null || true)"
else
    printf "Se necesita kdialog o zenity para el selector gráfico.\n" >&2
    exit 1
fi

[[ -n "${file:-}" ]] || exit 0
exec "$HOME/.config/hypr/scripts/set-wallpaper.sh" "$file"
