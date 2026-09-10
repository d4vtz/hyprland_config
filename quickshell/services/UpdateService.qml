pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var archUpdates: []
    property var aurUpdates: []
    property var flatpakUpdates: []
    property var firmwareUpdates: []
    property var archNews: []
    property string lastChecked: "--:--"
    property bool refreshing: false

    readonly property int archCount: archUpdates.length
    readonly property int aurCount: aurUpdates.length
    readonly property int flatpakCount: flatpakUpdates.length
    readonly property int firmwareCount: firmwareUpdates.length
    readonly property int totalCount: archCount + aurCount + flatpakCount + firmwareCount
    readonly property bool hasUpdates: totalCount > 0

    function refresh() {
        if (refreshing)
            return
        refreshing = true
        pending = 4
        archProcess.running = true
        aurProcess.running = true
        flatpakProcess.running = true
        firmwareProcess.running = true
        newsProcess.running = true
    }

    function finishOne() {
        pending = Math.max(0, pending - 1)
        if (pending === 0) {
            refreshing = false
            lastChecked = Qt.formatTime(new Date(), "HH:mm")
        }
    }

    function runFullUpgrade() {
        upgradeProcess.command = ["kitty", "--title", "Orion · Actualización del sistema", "-e", "bash", "-lc",
            "systemd-inhibit --what=idle:sleep:shutdown --who='Orion Shell' --why='Actualización del sistema' paru; printf '\\nPulsa Enter para cerrar...'; read -r"]
        upgradeProcess.running = true
    }

    function runFlatpakUpgrade() {
        upgradeProcess.command = ["kitty", "--title", "Orion · Flatpak", "-e", "bash", "-lc",
            "flatpak update; printf '\\nPulsa Enter para cerrar...'; read -r"]
        upgradeProcess.running = true
    }

    function runFirmwareUpgrade() {
        upgradeProcess.command = ["kitty", "--title", "Orion · Firmware", "-e", "bash", "-lc",
            "sudo fwupdmgr update; printf '\\nPulsa Enter para cerrar...'; read -r"]
        upgradeProcess.running = true
    }

    property int pending: 0

    property Timer timer: Timer {
        interval: 1800000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property Process archProcess: Process {
        command: ["bash", "-lc", "checkupdates 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.archUpdates = text.trim() ? text.trim().split("\n") : []
                root.finishOne()
            }
        }
    }

    property Process aurProcess: Process {
        command: ["bash", "-lc", "if command -v paru >/dev/null; then paru -Qua 2>/dev/null || true; elif command -v yay >/dev/null; then yay -Qua 2>/dev/null || true; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.aurUpdates = text.trim() ? text.trim().split("\n") : []
                root.finishOne()
            }
        }
    }

    property Process flatpakProcess: Process {
        command: ["bash", "-lc", "if command -v flatpak >/dev/null; then flatpak remote-ls --updates --columns=application 2>/dev/null || true; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.flatpakUpdates = text.trim() ? text.trim().split("\n") : []
                root.finishOne()
            }
        }
    }

    property Process firmwareProcess: Process {
        command: ["bash", "-lc", "if command -v fwupdmgr >/dev/null; then fwupdmgr get-updates --json 2>/dev/null | jq -r '.Devices[]?.Releases[]?.Name // empty' 2>/dev/null || true; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.firmwareUpdates = text.trim() ? text.trim().split("\n") : []
                root.finishOne()
            }
        }
    }

    property Process newsProcess: Process {
        command: ["bash", "-lc", "curl -m 6 -fsSL https://archlinux.org/feeds/news/ 2>/dev/null | sed -n 's:.*<title>\\(.*\\)</title>.*:\\1:p' | sed '1d' | head -n 3"]
        stdout: StdioCollector {
            onStreamFinished: root.archNews = text.trim() ? text.trim().split("\n") : []
        }
    }

    property Process upgradeProcess: Process {
        onExited: root.refresh()
    }
}
