import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

Item {
    id: root

    property bool open: false
    property var targetScreen: null
    property date now: new Date()

    function closePanel() { open = false; PanelCoordinator.close("dashboard") }
    function showPanel(screen) { if (screen) targetScreen = screen; PanelCoordinator.request("dashboard"); open = true }
    function toggle(screen) { if (open) closePanel(); else showPanel(screen) }

    IpcHandler {
        target: "dashboard"
        function toggle(): void { root.toggle() }
        function show(): void { root.showPanel(null) }
        function hide(): void { root.closePanel() }
    }

    PanelWindow {
        screen: root.targetScreen
        visible: root.open
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea {
            anchors.fill: parent
            onClicked: root.closePanel()
        }

        Surface {
            id: panelSurface
            focus: root.open
            Keys.onEscapePressed: event => { root.closePanel(); event.accepted = true }
            width: Math.min(760, parent.width - 40)
            height: Math.min(520, parent.height - 80)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 58
            elevated: false

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingXl
                spacing: Theme.spacingLg

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: Qt.formatDateTime(root.now, "hh:mm")
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: 34
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: Qt.formatDateTime(root.now, "dddd d 'de' MMMM")
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: SystemStatus.userName + "@" + SystemStatus.hostName
                        color: Theme.purple
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 2
                    columnSpacing: Theme.spacingMd
                    rowSpacing: Theme.spacingMd

                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingSm
                            SectionTitle {
                                Layout.fillWidth: true
                                icon: "󰖨"
                                title: "Sistema"
                                subtitle: SystemStatus.distribution
                                accent: Theme.purple
                            }
                            Item { Layout.fillHeight: true }
                            Text {
                                text: "CPU  " + Math.round(SystemStatus.cpuUsage) + "%"
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                            }
                            Text {
                                text: "RAM  " + Math.round(SystemStatus.memoryUsage * 100) + "%  ·  " + SystemStatus.memoryText
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                            Text {
                                text: "GPU  " + Math.round(SystemStatus.gpuUsage) + "%"
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingSm
                            SectionTitle {
                                Layout.fillWidth: true
                                icon: "󰤨"
                                title: "Conectividad"
                                subtitle: SystemStatus.network
                                accent: Theme.cyan
                            }
                            Item { Layout.fillHeight: true }
                            Text {
                                text: SystemStatus.wifiEnabled ? "Wi-Fi activo" : "Wi-Fi apagado"
                                color: SystemStatus.wifiEnabled ? Theme.cyan : Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                            }
                            Text {
                                text: SystemStatus.bluetoothEnabled ? "Bluetooth activo" : "Bluetooth apagado"
                                color: SystemStatus.bluetoothEnabled ? Theme.purple : Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingSm
                            SectionTitle {
                                Layout.fillWidth: true
                                icon: "󰁹"
                                title: "Energía"
                                subtitle: SystemStatus.powerProfile
                                accent: Theme.green
                            }
                            Item { Layout.fillHeight: true }
                            Text {
                                text: SystemStatus.battery === "CA" ? "Alimentación externa" : SystemStatus.battery + "%"
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: 22
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: SystemStatus.batteryState + "  ·  " + SystemStatus.batteryTime
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingSm
                            SectionTitle {
                                Layout.fillWidth: true
                                icon: "󰋊"
                                title: "Almacenamiento"
                                subtitle: "/"
                                accent: Theme.orange
                            }
                            Item { Layout.fillHeight: true }
                            Text {
                                text: Math.round(SystemStatus.diskUsage * 100) + "%"
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: 22
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: SystemStatus.diskText
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                    }
                }
            }
        }

    }

    Timer { interval: 1000; repeat: true; running: root.open; onTriggered: root.now = new Date() }
    Connections { target: PanelCoordinator; function onActivePanelChanged() { if (root.open && PanelCoordinator.activePanel !== "dashboard") root.closePanel() } }
}
