#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
config_dir=${XDG_CONFIG_HOME:-"$HOME/.config"}

link_config() {
  local source=$1 target=$2
  if [[ -e $target && ! -L $target ]]; then
    printf 'No se reemplazó %s: ya existe y no es un enlace.\n' "$target" >&2
    return 1
  fi
  ln -sfn "$source" "$target"
}

mkdir -p "$config_dir"
link_config "$root" "$config_dir/hypr"
link_config "$root/quickshell" "$config_dir/quickshell"

chmod +x "$root/scripts/orionctl" "$root/scripts/wallpaper-menu.sh" "$root/scripts/orion-doctor.sh" 2>/dev/null || true

printf 'Enlaces instalados. Cierra la sesión y entra en Hyprland (uwsm-managed).\n'
