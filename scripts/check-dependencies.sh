#!/usr/bin/env bash
set -u

required=(uwsm qs rofi hyprpaper hyprlock hypridle wl-paste cliphist wpctl brightnessctl playerctl jq)
recommended=(udiskie kdeconnectd nm-applet blueman-applet grimblast satty fd notify-send xdg-open)
missing_required=()
missing_recommended=()

for command_name in "${required[@]}"; do
  command -v "$command_name" >/dev/null 2>&1 || missing_required+=("$command_name")
done
for command_name in "${recommended[@]}"; do
  command -v "$command_name" >/dev/null 2>&1 || missing_recommended+=("$command_name")
done

if ((${#missing_required[@]})); then
  printf 'Faltan dependencias necesarias: %s\n' "${missing_required[*]}" >&2
fi
if ((${#missing_recommended[@]})); then
  printf 'Faltan integraciones opcionales: %s\n' "${missing_recommended[*]}" >&2
fi

((${#missing_required[@]} == 0))
