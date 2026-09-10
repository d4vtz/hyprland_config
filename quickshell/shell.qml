import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "components"
import "modules"
import "services"

ShellRoot {
    NotificationToast {}

    Launcher { id: launcher }
    Dashboard { id: dashboard }
    ControlCenter { id: controlCenter }
    ActivityCenter { id: activityCenter }
    SessionPanel { id: sessionPanel }
    SystemMonitor { id: systemMonitor }
    SettingsPanel { id: settingsPanel }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            color: "transparent"
            implicitHeight: 46
            anchors { top: true; left: true; right: true }
            exclusiveZone: 46

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                color: Theme.barBackground
                radius: Theme.cardRadius
                border.color: "transparent"

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Theme.spacingSm
                    spacing: 7

                    Pill {
                        id: launcherPill
                        active: launcher.open
                        Text {
                            text: "󰣇"
                            color: Theme.purple
                            font.family: Theme.iconFamily
                            font.pixelSize: 16
                        }
                        MouseArea {
                            parent: launcherPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: launcher.toggle()
                        }
                    }

                    Pill {
                        id: dashboardPill
                        active: dashboard.open
                        Text {
                            text: "󰕮"
                            color: Theme.pink
                            font.family: Theme.iconFamily
                            font.pixelSize: 16
                        }
                        MouseArea {
                            parent: dashboardPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: dashboard.toggle()
                        }
                    }

                    Workspaces { screen: modelData }
                    ActiveWindow {}
                }

                Clock { anchors.centerIn: parent }

                RowLayout {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Theme.spacingSm
                    spacing: 7

                    Media {}

                    Pill {
                        id: monitorPill
                        active: systemMonitor.open
                        Text {
                            text: "󰍛 " + Math.round(SystemStatus.cpuUsage) + "%"
                            color: Theme.green
                            font.family: Theme.iconFamily
                            font.pixelSize: 13
                        }
                        MouseArea {
                            parent: monitorPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: systemMonitor.toggle()
                        }
                    }

                    Pill {
                        id: controlCenterPill
                        active: controlCenter.open
                        RowLayout {
                            spacing: 8

                            Text {
                                text: SystemStatus.battery === "CA"
                                      ? "󰚥"
                                      : (SystemStatus.batteryState === "Cargando" ? "󰂄" : "󰁹")
                                color: SystemStatus.batteryState === "Cargando" ? Theme.green
                                     : SystemStatus.acConnected ? Theme.yellow
                                     : Theme.orange
                                font.family: Theme.iconFamily
                                font.pixelSize: 15
                            }

                            Text {
                                text: SystemStatus.battery + (SystemStatus.battery === "CA" ? "" : "%")
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }

                            Text {
                                text: SystemStatus.wifiEnabled ? "󰖩" : "󰖪"
                                color: SystemStatus.wifiEnabled ? Theme.cyan : Theme.muted
                                font.family: Theme.iconFamily
                                font.pixelSize: 15
                            }

                            Text {
                                text: "󰕾"
                                color: Theme.cyan
                                font.family: Theme.iconFamily
                                font.pixelSize: 15
                            }
                        }
                        MouseArea {
                            parent: controlCenterPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: controlCenter.toggle()
                        }
                    }

                    Pill {
                        id: activityPill
                        active: activityCenter.open

                        Text {
                            text: NotificationService.doNotDisturb ? "󰂛" : "󰂚"
                            color: NotificationService.doNotDisturb ? Theme.red : Theme.purple
                            font.family: Theme.iconFamily
                            font.pixelSize: 16
                        }

                        Text {
                            visible: NotificationService.count > 0
                            text: NotificationService.count
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Text {
                            visible: ClipboardStatus.hasEntries
                            text: "󰅇"
                            color: Theme.pink
                            font.family: Theme.iconFamily
                            font.pixelSize: 14
                        }

                        Text {
                            visible: UpdateService.hasUpdates
                            text: "󰏔 " + UpdateService.totalCount
                            color: Theme.orange
                            font.family: Theme.iconFamily
                            font.pixelSize: 14
                        }

                        MouseArea {
                            parent: activityPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: activityCenter.toggle(0)
                        }
                    }

                    Pill {
                        id: caffeinePill
                        visible: CaffeineService.active
                        active: true

                        Text {
                            text: "󰅶"
                            color: Theme.yellow
                            font.family: Theme.iconFamily
                            font.pixelSize: 16
                        }

                        MouseArea {
                            parent: caffeinePill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: CaffeineService.toggle()
                        }
                    }

                    Pill {
                        id: sessionPill
                        active: sessionPanel.open
                        Text {
                            text: "󰐥"
                            color: Theme.red
                            font.family: Theme.iconFamily
                            font.pixelSize: 16
                        }
                        MouseArea {
                            parent: sessionPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: sessionPanel.toggle()
                        }
                    }

                    Pill {
                        id: settingsPill
                        active: settingsPanel.open
                        Text {
                            text: "󰒓"
                            color: Theme.muted
                            font.family: Theme.iconFamily
                            font.pixelSize: 16
                        }
                        MouseArea {
                            parent: settingsPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: settingsPanel.toggle()
                        }
                    }
                }
            }
        }
    }
}
