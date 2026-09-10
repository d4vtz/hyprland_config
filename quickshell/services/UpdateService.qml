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
    property string lastChecked: "--:--"
    property bool refreshing: false
    property string errorText: ""

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
        errorText = ""
        checkProcess.running = true
    }

    function runFullUpgrade() {
        upgradeProcess.command = ["kitty", "--title", "Orion · Actualización del sistema", "-e", "bash", "-lc",
            "systemd-inhibit --what=idle:sleep:shutdown --who='Orion Shell' --why='Actualización del sistema' sh -c 'if command -v paru >/dev/null; then paru -Syu; elif command -v yay >/dev/null; then yay -Syu; else sudo pacman -Syu; fi'; printf '\\nPulsa Enter para cerrar...'; read -r"]
        upgradeProcess.running = true
    }

    function runFlatpakUpgrade() {
        upgradeProcess.command = ["kitty", "--title", "Orion · Flatpak", "-e", "bash", "-lc",
            "flatpak update; printf '\\nPulsa Enter para cerrar...'; read -r"]
        upgradeProcess.running = true
    }

    function runFirmwareUpgrade() {
        upgradeProcess.command = ["kitty", "--title", "Orion · Firmware", "-e", "bash", "-lc",
            "fwupdmgr refresh --force; fwupdmgr update; printf '\\nPulsa Enter para cerrar...'; read -r"]
        upgradeProcess.running = true
    }

    property Timer timer: Timer {
        interval: 1800000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property Process checkProcess: Process {
        command: ["bash", "-lc",
            "set +e; " +
            "printf '__ORION_ARCH__\\n'; " +
            "if command -v checkupdates >/dev/null 2>&1; then checkupdates 2>/dev/null; else printf '__ERR__ checkupdates no disponible\\n'; fi; " +
            "printf '__ORION_AUR__\\n'; " +
            "if command -v paru >/dev/null 2>&1; then paru -Qua 2>/dev/null; elif command -v yay >/dev/null 2>&1; then yay -Qua 2>/dev/null; fi; " +
            "printf '__ORION_FLATPAK__\\n'; " +
            "if command -v flatpak >/dev/null 2>&1; then flatpak remote-ls --updates --columns=application 2>/dev/null; fi; " +
            "printf '__ORION_FIRMWARE__\\n'; " +
            "if command -v fwupdmgr >/dev/null 2>&1; then fwupdmgr get-updates 2>/dev/null | sed -n '/→/p' | sed 's/^[[:space:]]*//'; fi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                let section = ""
                let arch = []
                let aur = []
                let flatpak = []
                let firmware = []
                let errors = []

                for (const raw of text.split("\n")) {
                    const line = raw.trim()
                    if (!line)
                        continue
                    if (line === "__ORION_ARCH__") { section = "arch"; continue }
                    if (line === "__ORION_AUR__") { section = "aur"; continue }
                    if (line === "__ORION_FLATPAK__") { section = "flatpak"; continue }
                    if (line === "__ORION_FIRMWARE__") { section = "firmware"; continue }
                    if (line.startsWith("__ERR__")) { errors.push(line.slice(7).trim()); continue }

                    if (section === "arch") arch.push(line)
                    else if (section === "aur") aur.push(line)
                    else if (section === "flatpak") flatpak.push(line)
                    else if (section === "firmware") firmware.push(line)
                }

                root.archUpdates = arch
                root.aurUpdates = aur
                root.flatpakUpdates = flatpak
                root.firmwareUpdates = firmware
                root.errorText = errors.join(" · ")
                root.lastChecked = Qt.formatTime(new Date(), "HH:mm")
            }
        }

        onExited: {
            root.refreshing = false
            if (exitCode !== 0 && root.errorText.length === 0)
                root.errorText = "La comprobación terminó con código " + exitCode
        }
    }

    property Process upgradeProcess: Process {
        onExited: root.refresh()
    }
}
