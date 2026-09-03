#!/usr/bin/env bash
set -euo pipefail

qs kill 2>/dev/null || true
pkill waybar 2>/dev/null || true
pgrep -x swaync >/dev/null || uwsm app -- swaync
exec uwsm app -- waybar
