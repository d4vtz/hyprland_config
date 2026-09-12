#!/usr/bin/env bash
set -euo pipefail
confirm() {
  local message=$1
  if command -v kdialog >/dev/null; then kdialog --warningyesno "$message"
  else [[ $(printf 'Cancelar\nConfirmar\n' | rofi -dmenu -p 'Confirmación') == Confirmar ]]; fi
}
case ${1:-} in
  update) confirm "¿Actualizar paquetes oficiales y AUR?" || exit 0; exec uwsm app -- kitty --class orion-maintenance -e paru -Syu ;;
  cache) confirm "¿Eliminar versiones antiguas de la caché de Pacman?" || exit 0; pkexec /usr/bin/paccache -r ;;
  services) exec uwsm app -- kitty --class orion-maintenance -e bash -lc 'systemctl --failed; printf "\nServicios de usuario:\n"; systemctl --user --failed; read -r -p "Pulsa Enter para cerrar..."' ;;
  upstream-check) exec "$(dirname -- "$0")/caelestia-upstream.sh" check ;;
  upstream-update) confirm "¿Actualizar Caelestia upstream?" || exit 0; exec uwsm app -- kitty --class orion-maintenance -e "$(dirname -- "$0")/caelestia-upstream.sh" update ;;
  *) printf 'Uso: %s {update|cache|services|upstream-check|upstream-update}\n' "${0##*/}" >&2; exit 2 ;;
esac
