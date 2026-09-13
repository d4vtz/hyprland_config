#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
shell_dir="$root/quickshell"
i18n_dir="$shell_dir/plugin/src/Caelestia/I18n"
overlay_dir="$root/overlays/caelestia"

install -Dm644 "$overlay_dir/i18n/es_MX.po" "$i18n_dir/trs/es_MX.po"
install -Dm644 "$overlay_dir/qml/components/widgets/MaintenanceCard.qml" \
  "$shell_dir/components/widgets/MaintenanceCard.qml"
install -Dm644 "$overlay_dir/qml/modules/sidebar/Content.qml" \
  "$shell_dir/modules/sidebar/Content.qml"
install -Dm644 "$overlay_dir/qml/modules/dashboard/Performance.qml" \
  "$shell_dir/modules/dashboard/Performance.qml"

cmake_file="$i18n_dir/CMakeLists.txt"
if ! grep -q 'trs/es_MX\.po' "$cmake_file"; then
  sed -i '/set(po_files/a\    trs/es_MX.po' "$cmake_file"
fi

printf 'Overlays Orion aplicados: es_MX y mantenimiento integrado.\n'
