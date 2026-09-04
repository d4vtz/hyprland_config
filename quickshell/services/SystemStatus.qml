pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    property string network: "--"
    property bool wifiEnabled: false
    property bool vpnActive: false
    property bool bluetoothEnabled: false
    property bool bluetoothConnected: false
    property bool bluetoothAudioActive: false
    property bool microphoneActive: false
    property string battery: "--"
    property string batteryState: "Sin batería"
    property string batteryTime: "--"
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
        stateProcess.running = true
    }

    function refreshSensors() { sensorsProcess.running = true }
    function refreshIdentity() { identityProcess.running = true }

    property Timer timer: Timer {
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property Timer sensorsTimer: Timer {
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refreshSensors()
    }

    property Timer identityTimer: Timer {
        interval: 60000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refreshIdentity()
    }

    property Process networkProcess: Process {
        command: ["sh", "-c", "wifi=$(nmcli -t -f WIFI general 2>/dev/null); connection=$(nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null | awk -F: '$1 == \"wifi\" && $2 == \"connected\" {print $3; exit}'); nmcli -t -f TYPE connection show --active 2>/dev/null | grep -Eq '^(vpn|wireguard)$' && vpn=1 || vpn=0; printf '%s|%s|%s' \"$wifi\" \"$connection\" \"$vpn\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.wifiEnabled = fields[0] === "enabled"
                root.network = fields[1] || (root.wifiEnabled ? "Sin conexión" : "Wi-Fi apagado")
                root.vpnActive = fields[2] === "1"
            }
        }
    }

    property Process batteryProcess: Process {
        command: ["bash", "-c", "b=$(find /sys/class/power_supply -maxdepth 1 -name 'BAT*' -print -quit); ac=0; for p in /sys/class/power_supply/*/online; do [[ -r $p && $(<$p) == 1 ]] && ac=1; done; [[ -z $b ]] && { printf 'CA|Sin batería|--|%s' \"$ac\"; exit; }; cap=$(<$b/capacity); st=$(<$b/status); case \"$st\" in Charging) label=Cargando;; Discharging) label=Descargando;; Full) label='Carga completa';; 'Not charging') label='Conectada, sin cargar';; *) label=\"$st\";; esac; now=$(cat \"$b/energy_now\" 2>/dev/null || cat \"$b/charge_now\" 2>/dev/null || echo 0); full=$(cat \"$b/energy_full\" 2>/dev/null || cat \"$b/charge_full\" 2>/dev/null || echo \"$now\"); rate=$(cat \"$b/power_now\" 2>/dev/null || cat \"$b/current_now\" 2>/dev/null || echo 0); if [[ ${rate:-0} -gt 0 ]]; then [[ $st == Charging ]] && amount=$((full-now)) || amount=$now; secs=$((amount*3600/rate)); printf '%s|%s|%dh %02d min|%s' \"$cap\" \"$label\" $((secs/3600)) $(((secs%3600)/60)) \"$ac\"; else printf '%s|%s|--|%s' \"$cap\" \"$label\" \"$ac\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.battery = fields[0] || "CA"
                root.batteryState = fields[1] || "Sin batería"
                root.batteryTime = fields[2] || "--"
                root.acConnected = fields[3] === "1"
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
        command: ["bash", "-c", "bt=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2;exit}'); bluetoothctl devices Connected 2>/dev/null | grep -q '^Device ' && btc=1 || btc=0; profile=$(powerprofilesctl get 2>/dev/null || echo unavailable); profiles=$(powerprofilesctl list 2>/dev/null | sed -nE 's/^[[:space:]]*\\*?[[:space:]]*(performance|balanced|power-saver):.*/\\1/p' | paste -sd,); pgrep -x hyprsunset >/dev/null && night=1 || night=0; pactl list sinks 2>/dev/null | awk 'BEGIN{RS=\"\"} /State: RUNNING/ && /Name: bluez_output/{active=1} END{exit !active}' && bta=1 || bta=0; pactl list source-outputs 2>/dev/null | grep -q 'State: RUNNING' && mic=1 || mic=0; printf '%s|%s|%s|%s|%s|%s|%s' \"$bt\" \"$btc\" \"$profile\" \"$night\" \"$bta\" \"$profiles\" \"$mic\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.bluetoothEnabled = fields[0] === "yes"
                root.bluetoothConnected = fields[1] === "1"
                root.powerProfile = fields[2] || "balanced"
                root.nightLightEnabled = fields[3] === "1"
                root.bluetoothAudioActive = fields[4] === "1"
                root.powerProfiles = fields[5] || ""
                root.microphoneActive = fields[6] === "1"
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
