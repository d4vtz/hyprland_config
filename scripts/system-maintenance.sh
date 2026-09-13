#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

confirm() {
  local message=$1
  if command -v kdialog >/dev/null; then
    kdialog --warningyesno "$message"
  else
    [[ $(printf 'Cancelar\nConfirmar\n' | rofi -dmenu -p 'Confirmación') == Confirmar ]]
  fi
}

count_lines() {
  awk 'NF { count++ } END { print count + 0 }'
}

case ${1:-} in
  status)
    official=0
    aur=0
    failed=0
    upstream=0

    if command -v checkupdates >/dev/null; then
      official=$(checkupdates 2>/dev/null | count_lines || true)
    fi
    if command -v paru >/dev/null; then
      aur=$(paru -Qua 2>/dev/null | count_lines || true)
    fi

    failed=$(
      {
        systemctl --failed --no-legend 2>/dev/null || true
        systemctl --user --failed --no-legend 2>/dev/null || true
      } | count_lines
    )

    if bash "$script_dir/caelestia-upstream.sh" machine 2>/dev/null | grep -qx available; then
      upstream=1
    fi
    printf '%s|%s|%s|%s\n' "$official" "$aur" "$failed" "$upstream"
    ;;
  update)
    confirm "¿Actualizar paquetes oficiales y AUR?" || exit 0
    exec uwsm app -- kitty --class orion-maintenance -e paru -Syu
    ;;
  cache)
    confirm "¿Eliminar versiones antiguas de la caché de Pacman?" || exit 0
    exec uwsm app -- kitty --class orion-maintenance -e bash -lc \
      'sudo paccache -r; printf "\nProceso terminado.\n"; read -r -p "Pulsa Enter para cerrar..."'
    ;;
  services)
    exec uwsm app -- kitty --class orion-maintenance -e bash -lc \
      'systemctl --failed; printf "\nServicios de usuario:\n"; systemctl --user --failed; read -r -p "Pulsa Enter para cerrar..."'
    ;;
  upstream-check)
    exec bash "$script_dir/caelestia-upstream.sh" check
    ;;
  upstream-update)
    confirm "¿Actualizar Caelestia, reaplicar Orion y recompilar?" || exit 0
    exec uwsm app -- kitty --class orion-maintenance -e bash "$script_dir/caelestia-upstream.sh" update
    ;;
  *)
    printf 'Uso: %s {status|update|cache|services|upstream-check|upstream-update}\n' "${0##*/}" >&2
    exit 2
    ;;
esac
