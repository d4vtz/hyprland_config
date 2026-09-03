import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.SystemTray
import ".."
import "../services"

ColumnLayout {
    id: root
    spacing: 10

    Process { id: sessionCommand }

    RowLayout {
        Layout.fillWidth: true
        ColumnLayout {
            spacing: 1
            Text { text: SystemStatus.userName; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 14; font.bold: true }
            Text { text: SystemStatus.hostName; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10 }
        }
        Item { Layout.fillWidth: true }
        Text { text: SystemStatus.uptime ? "Activo " + SystemStatus.uptime : ""; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9 }
    }

    Text { text: "Bandeja del sistema"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10 }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 54
        radius: 8
        color: Theme.surface
        RowLayout {
            anchors.centerIn: parent
            spacing: 14
            Repeater {
                model: SystemTray.items
                delegate: Image {
                    required property var modelData
                    source: modelData.icon
                    sourceSize.width: 20
                    sourceSize.height: 20
                    width: 20
                    height: 20
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.activate() }
                }
            }
            Text {
                visible: SystemTray.items.values.length === 0
                text: "Sin elementos"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 10
            }
        }
    }

    Text { text: "Sesión"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10 }

    GridLayout {
        Layout.fillWidth: true
        columns: 5
        columnSpacing: 7
        Repeater {
            model: [
                { icon: "󰌾", color: Theme.cyan, command: "loginctl lock-session", label: "Bloquear" },
                { icon: "󰒲", color: Theme.green, command: "systemctl suspend", label: "Suspender" },
                { icon: "󰍃", color: Theme.purple, command: "hyprctl dispatch 'hl.dsp.exit()'", label: "Salir" },
                { icon: "󰑐", color: Theme.orange, command: "systemctl reboot", label: "Reiniciar" },
                { icon: "󰐥", color: Theme.red, command: "systemctl poweroff", label: "Apagar" }
            ]
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                radius: 8
                color: actionArea.containsMouse ? Theme.current : Theme.surface
                border.color: actionArea.containsMouse ? modelData.color : "#45485a"
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.icon; color: modelData.color; font.family: Theme.fontFamily; font.pixelSize: 17 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.label; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 7 }
                }
                MouseArea {
                    id: actionArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sessionCommand.command = ["sh", "-c", modelData.command]
                        sessionCommand.running = true
                    }
                }
            }
        }
    }

    Item { Layout.fillHeight: true }
}

