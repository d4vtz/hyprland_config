#!/usr/bin/env bash
set -euo pipefail

choice=$(printf '%s\n' 'Bloquear' 'Cerrar sesión' 'Suspender' 'Reiniciar' 'Apagar' |
  rofi -dmenu -i -p 'Energía') || exit 0

case "$choice" in
  'Bloquear') loginctl lock-session ;;
  'Cerrar sesión') hyprctl dispatch 'hl.dsp.exit()' ;;
  'Suspender') systemctl suspend ;;
  'Reiniciar') systemctl reboot ;;
  'Apagar') systemctl poweroff ;;
esac
