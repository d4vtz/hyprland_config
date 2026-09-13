#!/usr/bin/env bash
set -euo pipefail
selection=$(cliphist list | rofi -dmenu -i -p 'Portapapeles' -mesg 'Enter: copiar · Escape: cerrar') || exit 0
printf '%s' "$selection" | cliphist decode | wl-copy
