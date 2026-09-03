#!/usr/bin/env bash
set -euo pipefail

# Recorre de forma circular solamente los escritorios numerados configurados.
# Uso: workspace-cycle.sh <cantidad> <next|previous>
workspace_count=${1:-7}
direction=${2:-next}

if ! [[ $workspace_count =~ ^[1-9][0-9]*$ ]]; then
  printf 'Cantidad de escritorios no válida: %s\n' "$workspace_count" >&2
  exit 2
fi

current=$(hyprctl activeworkspace -j | jq -r '.id')
if ! [[ $current =~ ^[0-9]+$ ]]; then
  printf 'No se pudo obtener un escritorio numerado activo.\n' >&2
  exit 1
fi

case $direction in
  next)
    target=$((current % workspace_count + 1))
    ;;
  previous)
    target=$(((current - 2 + workspace_count) % workspace_count + 1))
    ;;
  *)
    printf 'Dirección no válida: %s (usa next o previous)\n' "$direction" >&2
    exit 2
    ;;
esac

hyprctl dispatch workspace "$target"
