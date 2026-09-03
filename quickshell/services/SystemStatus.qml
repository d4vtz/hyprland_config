pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    property string network: "--"
    property string battery: "--"
    property real brightness: 0
    property string userName: ""
    property string hostName: ""
    property string uptime: ""

    function refresh() {
        networkProcess.running = true
        batteryProcess.running = true
        brightnessProcess.running = true
        identityProcess.running = true
    }

    property Timer timer: Timer {
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property Process networkProcess: Process {
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device | awk -F: '$2 == \"connected\" {print $1 \"|\" $3; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.network = fields.length > 1 ? fields[1] : "Sin red"
            }
        }
    }

    property Process batteryProcess: Process {
        command: ["sh", "-c", "for b in /sys/class/power_supply/BAT*/capacity; do [ -r \"$b\" ] && { cat \"$b\"; exit; }; done"]
        stdout: StdioCollector {
            onStreamFinished: root.battery = text.trim() || "CA"
        }
    }

    property Process brightnessProcess: Process {
        command: ["sh", "-c", "brightnessctl -m | awk -F, '{gsub(/%/, \"\", $4); print $4; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: root.brightness = Math.max(0, Math.min(1, Number(text.trim()) / 100))
        }
    }

    property Process identityProcess: Process {
        command: ["sh", "-c", "printf '%s|%s|%s' \"$(id -un)\" \"$(hostnamectl --static 2>/dev/null || hostname)\" \"$(uptime -p | sed 's/^up //')\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.userName = fields[0] || "usuario"
                root.hostName = fields[1] || "equipo"
                root.uptime = fields[2] || ""
            }
        }
    }
}
