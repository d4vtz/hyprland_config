#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
shell_dir="$root/quickshell"
i18n_dir="$shell_dir/plugin/src/Caelestia/I18n"
overlay_dir="$root/overlays/caelestia/i18n"

install -Dm644 "$overlay_dir/es_MX.po" "$i18n_dir/trs/es_MX.po"

cmake_file="$i18n_dir/CMakeLists.txt"
if ! grep -q 'trs/es_MX\.po' "$cmake_file"; then
  sed -i '/set(po_files/a\    trs/es_MX.po' "$cmake_file"
fi

printf 'Overlay Orion aplicado: traducción es_MX registrada.\n'
