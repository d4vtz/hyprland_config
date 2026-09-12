#!/usr/bin/env bash
set -u

fail=0
warn=0

ok()   { printf '✓ %s\n' "$*"; }
bad()  { printf '✗ %s\n' "$*" >&2; fail=$((fail+1)); }
note() { printf '! %s\n' "$*"; warn=$((warn+1)); }

need_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        ok "$1"
    else
        bad "Falta $1"
    fi
}

printf 'Orion Shell doctor\n\n'

for cmd in qs hyprctl nmcli bluetoothctl brightnessctl wpctl cliphist cava gtk-launch ps; do
    need_cmd "$cmd"
done

printf '\nArchivos principales\n'
for f in     "$HOME/.config/quickshell/shell.qml"     "$HOME/.config/quickshell/Theme.qml"     "$HOME/.config/quickshell/modules/Launcher.qml"     "$HOME/.config/quickshell/modules/Dashboard.qml"     "$HOME/.config/quickshell/modules/ControlCenter.qml"     "$HOME/.config/quickshell/modules/ActivityCenter.qml"     "$HOME/.config/quickshell/modules/SystemMonitor.qml"     "$HOME/.config/quickshell/modules/SettingsPanel.qml"; do
    [[ -r "$f" ]] && ok "$f" || bad "No se puede leer $f"
done

printf '\nServicios opcionales\n'
if command -v powerprofilesctl >/dev/null 2>&1; then
    ok "powerprofilesctl"
else
    note "powerprofilesctl no está disponible; los perfiles de energía quedarán deshabilitados"
fi

if command -v kdialog >/dev/null 2>&1 || command -v zenity >/dev/null 2>&1; then
    ok "selector gráfico de fondo"
else
    note "Instala kdialog o zenity para elegir fondos desde Orion Settings"
fi

printf '\nIPC\n'
if pgrep -af quickshell >/dev/null 2>&1; then
    ok "Quickshell está ejecutándose"
    ipc_failed=0
    for call in \
        "launcher hide" "dashboard hide" "controlcenter hide" \
        "activity hide" "monitor hide" "settings hide" "session hide" \
        "panels closeAll"; do
        read -r target function <<<"$call"
        if ! qs ipc call "$target" "$function" >/dev/null 2>&1; then
            bad "IPC no responde: $target $function"
            ipc_failed=1
        fi
    done
    (( ipc_failed == 0 )) && ok "Todos los destinos IPC de Orion responden"
else
    note "Quickshell no está ejecutándose; inicia con: qs"
fi

printf '\nResumen: %d error(es), %d advertencia(s)\n' "$fail" "$warn"
exit "$(( fail > 0 ? 1 : 0 ))"
