#!/usr/bin/env bash
set -euo pipefail

confirm() {
  local message=$1
  if command -v kdialog >/dev/null; then
    kdialog --warningyesno "$message"
  else
    [[ $(printf 'Cancelar\nConfirmar\n' | rofi -dmenu -p 'Confirmación') == Confirmar ]]
  fi
}

case ${1:-} in
  cache)
    confirm "¿Eliminar versiones antiguas de la caché de Pacman?" || exit 0
    pkexec /usr/bin/paccache -r
    ;;
  trash)
    confirm "¿Vaciar permanentemente la papelera?" || exit 0
    /usr/bin/gio trash --empty
    ;;
esac
