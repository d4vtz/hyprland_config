#!/usr/bin/env bash
set -euo pipefail

qs kill 2>/dev/null || true
pkill waybar 2>/dev/null || true
exec uwsm app -- waybar

