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

git -C "$root" submodule update --init --recursive
mkdir -p "$config_dir" "$config_dir/autostart" "$config_dir/quickshell"
link_config "$root" "$config_dir/hypr"
link_config "$root/quickshell" "$config_dir/quickshell/caelestia"
link_config "$root/waybar" "$config_dir/waybar"
link_config "$root/rofi" "$config_dir/rofi"
link_config "$root/autostart/nm-applet.desktop" "$config_dir/autostart/nm-applet.desktop"
chmod +x "$root/scripts/"*.sh "$root/scripts/orionctl" 2>/dev/null || true
printf 'Enlaces instalados. Cierra la sesión y entra en Hyprland (uwsm-managed).\n'
