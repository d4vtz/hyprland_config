#!/usr/bin/env bash
set -euo pipefail

action=${1:-}

confirm() {
  local message=$1
  if command -v kdialog >/dev/null 2>&1; then
    kdialog --warningyesno "$message"
  else
    [[ $(printf '%s\n' 'Cancelar' 'Confirmar' | rofi -dmenu -p "$message") == Confirmar ]]
  fi
}

case "$action" in
  lock) loginctl lock-session ;;
  suspend) systemctl suspend ;;
  logout)
    confirm '¿Cerrar la sesión de Hyprland?' && hyprctl dispatch 'hl.dsp.exit()'
    ;;
  reboot)
    confirm '¿Reiniciar el equipo?' && systemctl reboot
    ;;
  poweroff)
    confirm '¿Apagar el equipo?' && systemctl poweroff
    ;;
  *) printf 'Acción desconocida: %s\n' "$action" >&2; exit 2 ;;
esac
