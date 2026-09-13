#!/usr/bin/env bash
set -euo pipefail
selection=$(printf '%s\n' \
  'Música|music' \
  'Comunicación|communication' \
  'Monitor del sistema|sysmon' \
  'Tareas|todo' \
  'Scratchpad|scratchpad' \
  | rofi -dmenu -i -p 'Espacios especiales') || exit 0
workspace=${selection##*|}
hyprctl dispatch togglespecialworkspace "$workspace"
