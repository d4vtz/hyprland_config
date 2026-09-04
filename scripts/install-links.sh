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
mkdir -p "$config_dir/autostart"
link_config "$root" "$config_dir/hypr"
link_config "$root/quickshell" "$config_dir/quickshell"
link_config "$root/rofi" "$config_dir/rofi"
link_config "$root/autostart/nm-applet.desktop" "$config_dir/autostart/nm-applet.desktop"

find "$root/scripts" -maxdepth 1 -type f -name '*.sh' -exec chmod +x {} +

"$root/scripts/check-dependencies.sh" || true

printf 'Enlaces instalados. Cierra la sesión y entra en Hyprland (uwsm-managed).\n'
