pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    property string network: "--"
    property string battery: "--"

    function refresh() {
        networkProcess.running = true
        batteryProcess.running = true
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
}

