#!/usr/bin/env bash
set -euo pipefail

pkill waybar 2>/dev/null || true
pkill swaync 2>/dev/null || true
exec "$HOME/.config/hypr/scripts/orionctl" reload
