#!/usr/bin/env bash
set -euo pipefail
repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"
git submodule update --init quickshell
git -C quickshell fetch origin main
current=$(git -C quickshell rev-parse HEAD)
upstream=$(git -C quickshell rev-parse origin/main)
case ${1:-check} in
  check)
    printf 'Base Orion: %s\nUpstream:   %s\n' "$current" "$upstream"
    [[ $current == "$upstream" ]] && printf 'Caelestia ya está actualizada.\n' || printf 'Hay una actualización disponible.\n'
    ;;
  update)
    [[ -z $(git status --porcelain) ]] || { printf 'Hay cambios locales sin guardar.\n' >&2; exit 1; }
    git -C quickshell checkout "$upstream"
    git add quickshell
    git commit -m "chore: update Caelestia upstream to ${upstream:0:8}"
    printf 'Caelestia actualizada; valida la capa Orion antes de publicar.\n'
    ;;
  *) printf 'Uso: %s [check|update]\n' "${0##*/}" >&2; exit 2 ;;
esac
