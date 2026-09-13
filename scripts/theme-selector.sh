#!/usr/bin/env bash
set -euo pipefail
selection=$(caelestia scheme list 2>/dev/null | sed '/^[[:space:]]*$/d' | rofi -dmenu -i -p 'Tema Caelestia') || exit 0
[[ -n $selection ]] || exit 0
name=${selection%%[[:space:]]*}
caelestia scheme set -n "$name" -f medium -m dark
