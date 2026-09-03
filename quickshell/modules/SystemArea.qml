import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import ".."
import "../components"
import "../services"

Pill {
    id: root

    property bool expanded: false
    active: expanded

    RowLayout {
        spacing: 10
        Repeater {
            model: SystemTray.items
            delegate: Image {
                required property var modelData
                source: modelData.icon
                sourceSize.width: 16
                sourceSize.height: 16
                width: 16
                height: 16
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.activate()
                }
            }
        }
        Text { text: "󰂚"; color: Theme.purple; font.family: Theme.fontFamily }
        Text { text: "󰐥"; color: Theme.pink; font.family: Theme.fontFamily }
    }

    MouseArea {
        parent: root
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    Process { id: sessionCommand }
    Process { id: notifications; command: ["swaync-client", "-t", "-sw"] }

    PanelWindow {
        visible: root.expanded
        anchors { top: true; right: true }
        margins { top: 2; right: 8 }
        implicitWidth: 330
        implicitHeight: 258
        exclusiveZone: 0
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: Theme.radius + 2
            color: Theme.background
            border.color: "#66557d"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: SystemStatus.userName
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            font.bold: true
                        }
                        Text {
                            text: SystemStatus.hostName
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: SystemStatus.uptime ? "Activo " + SystemStatus.uptime : ""
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: 8
                    color: notificationArea.containsMouse ? Theme.current : Theme.surface
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        Text { text: "󰂚"; color: Theme.purple; font.family: Theme.fontFamily; font.pixelSize: 16 }
                        Text { Layout.fillWidth: true; text: "Centro de notificaciones"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 11 }
                        Text { text: "󰅂"; color: Theme.muted; font.family: Theme.fontFamily }
                    }
                    MouseArea {
                        id: notificationArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            notifications.running = true
                            root.expanded = false
                        }
                    }
                }

                Text {
                    text: "Sesión"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }

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
                            Layout.preferredHeight: 62
                            radius: 8
                            color: actionArea.containsMouse ? Theme.current : Theme.surface
                            border.color: actionArea.containsMouse ? modelData.color : "#45485a"

                            Column {
                                anchors.centerIn: parent
                                spacing: 5
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.icon
                                    color: modelData.color
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 17
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label
                                    color: Theme.muted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 7
                                }
                            }

                            MouseArea {
                                id: actionArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    sessionCommand.command = ["sh", "-c", modelData.command]
                                    sessionCommand.running = true
                                    root.expanded = false
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "󰂚  SwayNC"; color: Theme.purple; font.family: Theme.fontFamily; font.pixelSize: 9 }
                    Item { Layout.fillWidth: true }
                    Text { text: SystemTray.items.values.length + " elementos en bandeja"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                }
            }
        }

        Shortcut {
            sequence: "Esc"
            onActivated: root.expanded = false
        }
    }
}
