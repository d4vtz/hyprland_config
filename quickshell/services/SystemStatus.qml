pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    property string network: "--"
    property bool wifiEnabled: false
    property bool bluetoothEnabled: false
    property bool bluetoothAudioActive: false
    property string battery: "--"
    property string batteryState: "Sin batería"
    property string batteryTime: "--"
    property string batteryHealth: "--"
    property string batteryCycles: "--"
    property bool acConnected: false
    property real brightness: 0
    property real cpuUsage: 0
    property real cpuTemperature: 0
    property real cpuFrequency: 0
    property real memoryUsage: 0
    property string memoryText: "--"
    property real diskUsage: 0
    property string diskText: "--"
    property real gpuUsage: 0
    property real gpuTemperature: 0
    property real gpuFrequency: 0
    property string powerProfile: "balanced"
    property string powerProfiles: ""
    property string powerBackend: "none"
    property bool nightLightEnabled: false
    property string userName: ""
    property string hostName: ""
    property string distribution: "Arch Linux"
    property string kernel: ""
    property string uptime: ""

    function refresh() {
        networkProcess.running = true
        batteryProcess.running = true
        brightnessProcess.running = true
        sensorsProcess.running = true
        stateProcess.running = true
        identityProcess.running = true
    }

    property Timer timer: Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property Process networkProcess: Process {
        command: ["sh", "-c", "printf '%s|' \"$(nmcli -t -f WIFI general 2>/dev/null)\"; nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null | awk -F: '$1 == \"wifi\" && $2 == \"connected\" {print $3; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.wifiEnabled = fields[0] === "enabled"
                root.network = fields[1] || (root.wifiEnabled ? "Sin conexión" : "Wi-Fi apagado")
            }
        }
    }

    property Process batteryProcess: Process {
        command: ["bash", "-c", "b=$(find /sys/class/power_supply -maxdepth 1 -name 'BAT*' -print -quit); ac=0; for p in /sys/class/power_supply/*/online; do [[ -r $p && $(<$p) == 1 ]] && ac=1; done; [[ -z $b ]] && { printf 'CA|Sin batería|--|%s|--|--' \"$ac\"; exit; }; cap=$(<$b/capacity); st=$(<$b/status); case \"$st\" in Charging) label=Cargando;; Discharging) label=Descargando;; Full) label='Carga completa';; 'Not charging') label='Conectada, sin cargar';; *) label=\"$st\";; esac; now=$(cat \"$b/energy_now\" 2>/dev/null || cat \"$b/charge_now\" 2>/dev/null || echo 0); full=$(cat \"$b/energy_full\" 2>/dev/null || cat \"$b/charge_full\" 2>/dev/null || echo \"$now\"); design=$(cat \"$b/energy_full_design\" 2>/dev/null || cat \"$b/charge_full_design\" 2>/dev/null || echo 0); cycles=$(cat \"$b/cycle_count\" 2>/dev/null || echo --); [[ ${design:-0} -gt 0 ]] && health=$((full*100/design)) || health=--; rate=$(cat \"$b/power_now\" 2>/dev/null || cat \"$b/current_now\" 2>/dev/null || echo 0); time=--; if [[ ${rate:-0} -gt 0 ]]; then [[ $st == Charging ]] && amount=$((full-now)) || amount=$now; secs=$((amount*3600/rate)); time=$(printf '%dh %02d min' $((secs/3600)) $(((secs%3600)/60))); fi; printf '%s|%s|%s|%s|%s|%s' \"$cap\" \"$label\" \"$time\" \"$ac\" \"$health\" \"$cycles\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.battery = fields[0] || "CA"
                root.batteryState = fields[1] || "Sin batería"
                root.batteryTime = fields[2] || "--"
                root.acConnected = fields[3] === "1"
                root.batteryHealth = fields[4] || "--"
                root.batteryCycles = fields[5] || "--"
            }
        }
    }

    property Process sensorsProcess: Process {
        command: ["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/hardware-status.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.cpuUsage = Number(fields[0]) || 0
                root.cpuTemperature = Number(fields[1]) || 0
                root.cpuFrequency = Number(fields[2]) || 0
                root.memoryUsage = (Number(fields[3]) || 0) / 100
                root.memoryText = fields[4] || "--"
                root.diskUsage = (Number(fields[5]) || 0) / 100
                root.diskText = fields[6] || "--"
                root.gpuUsage = Number(fields[7]) || 0
                root.gpuTemperature = Number(fields[8]) || 0
                root.gpuFrequency = Number(fields[9]) || 0
            }
        }
    }

    property Process stateProcess: Process {
        command: ["bash", "-c", "bt=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2;exit}'); backend=none; profile=unavailable; profiles=; if command -v powerprofilesctl >/dev/null 2>&1; then backend=powerprofilesctl; profile=$(powerprofilesctl get 2>/dev/null || echo unavailable); profiles=$(powerprofilesctl list 2>/dev/null | sed -nE 's/^[[:space:]]*\\*?[[:space:]]*(performance|balanced|power-saver):.*/\\1/p' | paste -sd,); elif command -v tuned-adm >/dev/null 2>&1; then backend=tuned; raw=$(tuned-adm active 2>/dev/null | sed -n 's/^Current active profile: //p'); case $raw in throughput-performance) profile=performance;; powersave) profile=power-saver;; balanced) profile=balanced;; *) profile=$raw;; esac; available=$(tuned-adm list 2>/dev/null); profiles=; grep -q 'throughput-performance' <<<\"$available\" && profiles=performance; grep -qE '(^|[[:space:]])balanced([[:space:]]|$)' <<<\"$available\" && profiles=${profiles:+$profiles,}balanced; grep -qE '(^|[[:space:]])powersave([[:space:]]|$)' <<<\"$available\" && profiles=${profiles:+$profiles,}power-saver; fi; pgrep -x hyprsunset >/dev/null && night=1 || night=0; pactl list sinks 2>/dev/null | awk 'BEGIN{RS=\"\"} /State: RUNNING/ && /Name: bluez_output/{active=1} END{exit !active}' && bta=1 || bta=0; printf '%s|%s|%s|%s|%s|%s' \"$bt\" \"$profile\" \"$night\" \"$bta\" \"$profiles\" \"$backend\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.bluetoothEnabled = fields[0] === "yes"
                root.powerProfile = fields[1] || "balanced"
                root.nightLightEnabled = fields[2] === "1"
                root.bluetoothAudioActive = fields[3] === "1"
                root.powerProfiles = fields[4] || ""
                root.powerBackend = fields[5] || "none"
            }
        }
    }

    property Process brightnessProcess: Process {
        command: ["sh", "-c", "brightnessctl -m | awk -F, '{gsub(/%/, \"\", $4); print $4; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: root.brightness = Math.max(0, Math.min(1, Number(text.trim()) / 100))
        }
    }

    property Process identityProcess: Process {
        command: ["bash", "-c", "source /etc/os-release 2>/dev/null || true; printf '%s|%s|%s|%s|%s' \"$(id -un)\" \"$(hostnamectl --static 2>/dev/null || hostname)\" \"${PRETTY_NAME:-Arch Linux}\" \"$(uname -r)\" \"$(uptime -p | sed 's/^up //')\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.userName = fields[0] || "usuario"
                root.hostName = fields[1] || "equipo"
                root.distribution = fields[2] || "Arch Linux"
                root.kernel = fields[3] || ""
                root.uptime = fields[4] || ""
            }
        }
    }
}
