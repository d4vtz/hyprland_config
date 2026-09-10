pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int count: 0
    readonly property bool hasEntries: count > 0

    function refresh() {
        counter.running = true
    }

    property Timer timer: Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property Process counter: Process {
        command: ["bash", "-lc", "cliphist list 2>/dev/null | wc -l"]
        stdout: StdioCollector {
            onStreamFinished: root.count = Number(text.trim()) || 0
        }
    }
}
