import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

ColumnLayout {
    id: root
    property int failedServices: 0
    property string cacheSize: "--"
    property string trashSize: "--"
    property int orphanCount: 0
    property string lastUpgrade: "--"
    spacing: 9

    function refresh() { statusProcess.running = true }
    Component.onCompleted: refresh()

    Process {
        id: statusProcess
        command: ["bash", "-c", "failed=$(( $(systemctl --failed --no-legend 2>/dev/null | wc -l) + $(systemctl --user --failed --no-legend 2>/dev/null | wc -l) )); cache=$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1); trash=$(du -sh \"${XDG_DATA_HOME:-$HOME/.local/share}/Trash\" 2>/dev/null | cut -f1); orphans=$(pacman -Qtdq 2>/dev/null | wc -l); last=$(grep '\\[ALPM\\] upgraded' /var/log/pacman.log 2>/dev/null | tail -n1 | cut -d']' -f1 | tr -d '['); printf '%s|%s|%s|%s|%s' \"$failed\" \"${cache:---}\" \"${trash:---}\" \"$orphans\" \"${last:---}\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.failedServices = Number(fields[0]) || 0
                root.cacheSize = fields[1] || "--"
                root.trashSize = fields[2] || "--"
                root.orphanCount = Number(fields[3]) || 0
                root.lastUpgrade = fields[4] || "--"
            }
        }
    }
    Process { id: action; onExited: root.refresh() }
    Process { id: terminal }

    StatusCard {
        icon: root.failedServices > 0 ? "󰀦" : "󰄬"
        title: "Servicios systemd"
        detail: root.failedServices > 0 ? root.failedServices + " unidades con fallos" : "Sin unidades fallidas"
        accent: root.failedServices > 0 ? Theme.red : Theme.green
        buttonText: root.failedServices > 0 ? "Revisar" : ""
        onActionRequested: {
            terminal.command = ["kitty", "--title", "Servicios fallidos", "-e", "bash", "-lc",
                "systemctl --failed; systemctl --user --failed; printf '\\nPulsa Enter para cerrar...'; read -r"]
            terminal.running = true
        }
    }
    StatusCard {
        icon: "󰃨"
        title: "Caché de Pacman"
        detail: root.cacheSize
        accent: Theme.orange
        buttonText: "Limpiar"
        onActionRequested: {
            action.command = ["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/system-maintenance.sh", "cache"]
            action.running = true
        }
    }
    StatusCard {
        icon: "󰩹"
        title: "Papelera"
        detail: root.trashSize
        accent: Theme.pink
        buttonText: "Vaciar"
        onActionRequested: {
            action.command = ["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/system-maintenance.sh", "trash"]
            action.running = true
        }
    }
    StatusCard {
        icon: "󰏖"
        title: "Paquetes huérfanos"
        detail: root.orphanCount === 0 ? "Ninguno" : root.orphanCount + " detectados"
        accent: root.orphanCount > 0 ? Theme.orange : Theme.cyan
        buttonText: root.orphanCount > 0 ? "Ver" : ""
        onActionRequested: {
            terminal.command = ["kitty", "--title", "Paquetes huérfanos", "-e", "bash", "-lc",
                "pacman -Qtdq; printf '\\nPulsa Enter para cerrar...'; read -r"]
            terminal.running = true
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Text { text: "Última actualización"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9 }
        Item { Layout.fillWidth: true }
        Text { text: root.lastUpgrade; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 9 }
        Text {
            text: "󰑐"
            color: Theme.cyan
            font.family: Theme.iconFamily
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.refresh() }
        }
    }
    Item { Layout.fillHeight: true }

    component StatusCard: Rectangle {
        id: card
        property string icon: ""
        property string title: ""
        property string detail: ""
        property color accent: Theme.purple
        property string buttonText: ""
        signal actionRequested()
        Layout.fillWidth: true
        Layout.preferredHeight: 64
        radius: 9
        color: Theme.surface
        border.color: Theme.border
        RowLayout {
            anchors.fill: parent
            anchors.margins: 11
            spacing: 10
            Text { text: card.icon; color: card.accent; font.family: Theme.iconFamily; font.pixelSize: 19 }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: card.title; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                Text { text: card.detail; color: card.accent; font.family: Theme.fontFamily; font.pixelSize: 9 }
            }
            Rectangle {
                visible: card.buttonText !== ""
                width: 64
                height: 28
                radius: 7
                color: maintenanceArea.containsMouse ? Theme.current : Theme.elevated
                border.color: card.accent
                Text { anchors.centerIn: parent; text: card.buttonText; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 8 }
                MouseArea { id: maintenanceArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: card.actionRequested() }
            }
        }
    }
}
