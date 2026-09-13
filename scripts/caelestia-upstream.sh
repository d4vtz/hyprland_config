#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
shell_dir="$repo_root/quickshell"

cd "$repo_root"
git submodule update --init quickshell
git -C "$shell_dir" fetch origin main

current=$(git -C "$shell_dir" rev-parse HEAD)
upstream=$(git -C "$shell_dir" rev-parse origin/main)

case ${1:-check} in
  machine)
    [[ $current == "$upstream" ]] && printf 'current\n' || printf 'available\n'
    ;;
  check)
    printf 'Base Orion: %s\nUpstream:   %s\n' "$current" "$upstream"
    [[ $current == "$upstream" ]] \
      && printf 'Caelestia ya está actualizada.\n' \
      || printf 'Hay una actualización disponible.\n'
    ;;
  update)
    if [[ -n $(git status --porcelain --ignore-submodules=dirty) ]]; then
      printf 'Hay cambios de Orion sin guardar; confirma o descártalos antes de actualizar.\n' >&2
      exit 1
    fi

    if [[ $current == "$upstream" ]]; then
      printf 'Caelestia ya está actualizada. Se reaplicarán los overlays.\n'
    else
      # Retira únicamente los archivos administrados por el overlay para permitir
      # que Git cambie de revisión sin borrar otros cambios del usuario.
      git -C "$shell_dir" restore -- \
        plugin/src/Caelestia/I18n/CMakeLists.txt \
        modules/sidebar/Content.qml \
        modules/dashboard/Performance.qml 2>/dev/null || true
      rm -f -- \
        "$shell_dir/plugin/src/Caelestia/I18n/trs/es_MX.po" \
        "$shell_dir/components/widgets/MaintenanceCard.qml"

      git -C "$shell_dir" checkout --detach "$upstream"
      git add quickshell
      git commit -m "chore: update Caelestia upstream to ${upstream:0:8}"
    fi

    bash "$repo_root/scripts/apply-caelestia-overlay.sh"

    cmake -S "$shell_dir" -B "$shell_dir/build" \
      -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
    cmake --build "$shell_dir/build"
    sudo cmake --install "$shell_dir/build"

    printf '\nCaelestia y los overlays Orion quedaron instalados. Reiniciando shell...\n'
    qs -c caelestia kill >/dev/null 2>&1 || true
    caelestia shell -d >/dev/null 2>&1 &
    disown
    ;;
  *)
    printf 'Uso: %s [check|machine|update]\n' "${0##*/}" >&2
    exit 2
    ;;
esac
