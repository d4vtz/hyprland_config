#!/usr/bin/env bash
set -euo pipefail

choice=$(printf '%s\n' \
  "Apagada" \
  "Suave · 5000 K" \
  "Cálida · 4500 K" \
  "Muy cálida · 4000 K" \
  "Lectura nocturna · 3500 K" |
  rofi -dmenu -i -p "Luz nocturna")

pkill -x hyprsunset 2>/dev/null || true

case $choice in
  "Suave · 5000 K") temperature=5000 ;;
  "Cálida · 4500 K") temperature=4500 ;;
  "Muy cálida · 4000 K") temperature=4000 ;;
  "Lectura nocturna · 3500 K") temperature=3500 ;;
  *) exit 0 ;;
esac

uwsm app -- hyprsunset -t "$temperature" >/dev/null 2>&1 &
