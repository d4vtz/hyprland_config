import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../services"

ColumnLayout {
    id: root
    spacing: 12

    Process { id: sessionCommand }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 112
        radius: 10
        color: Theme.surface
        border.color: Theme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 5
            Text {
                text: SystemStatus.userName + "@" + SystemStatus.hostName
                color: Theme.cyan
                font.family: Theme.fontFamily
                font.pixelSize: 16
                font.bold: true
            }
            Text {
                text: SystemStatus.distribution
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Kernel  " + SystemStatus.kernel
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }
                Text {
                    text: "Activo " + SystemStatus.uptime
                    color: Theme.green
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }
            }
        }
    }

    Text {
        text: "Acciones de sesión"
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: 10
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 5
        columnSpacing: 8

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
                Layout.preferredHeight: 76
                radius: 9
                color: actionArea.containsMouse ? Theme.current : Theme.surface
                border.color: modelData.label === "Apagar" ? Theme.red :
                              actionArea.containsMouse ? modelData.color : Theme.border

                Column {
                    anchors.centerIn: parent
                    spacing: 7
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.icon
                        color: modelData.color
                        font.family: Theme.iconFamily
                        font.pixelSize: 21
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.label
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 8
                    }
                }

                MouseArea {
                    id: actionArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sessionCommand.command = ["bash", "-c", modelData.command]
                        sessionCommand.running = true
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 52
        radius: 9
        color: Theme.elevated
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 13
            anchors.rightMargin: 13
            Text { text: "󰣇"; color: Theme.purple; font.family: Theme.iconFamily; font.pixelSize: 18 }
            Text { text: "Hyprland sobre Arch Linux"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10 }
            Item { Layout.fillWidth: true }
            Text { text: SystemStatus.powerProfile; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9 }
        }
    }

    Item { Layout.fillHeight: true }
}
