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
                        OrionIcon { name: "start-here-symbolic"; fallback: "󰣇"; fallbackColor: Theme.purple; size: 18 }
                        MouseArea {
                            parent: launcherPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: launcher.toggle(modelData)
                        }
                    }

                    Pill {
                        id: dashboardPill
                        active: dashboard.open
                        OrionIcon { name: "view-dashboard-symbolic"; fallback: "󰕮"; fallbackColor: Theme.pink; size: 18 }
                        MouseArea {
                            parent: dashboardPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: dashboard.toggle(modelData)
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
                    Tray {}

                    Pill {
                        id: monitorPill
                        active: systemMonitor.open
                        RowLayout {
                            spacing: 5
                            OrionIcon { name: "utilities-system-monitor-symbolic"; fallback: "󰍛"; fallbackColor: Theme.green; size: 16 }
                            Text { text: Math.round(SystemStatus.cpuUsage) + "%"; color: Theme.green; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        }
                        MouseArea {
                            parent: monitorPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: systemMonitor.toggle(modelData)
                        }
                    }

                    Pill {
                        id: controlCenterPill
                        active: controlCenter.open
                        RowLayout {
                            spacing: 8

                            OrionIcon {
                                name: SystemStatus.battery === "CA" ? "ac-adapter-symbolic"
                                    : SystemStatus.batteryState === "Cargando" ? "battery-charging-symbolic"
                                    : "battery-symbolic"
                                fallback: SystemStatus.battery === "CA" ? "󰚥" : (SystemStatus.batteryState === "Cargando" ? "󰂄" : "󰁹")
                                fallbackColor: SystemStatus.batteryState === "Cargando" ? Theme.green : SystemStatus.acConnected ? Theme.yellow : Theme.orange
                                size: 17
                            }

                            Text {
                                text: SystemStatus.battery + (SystemStatus.battery === "CA" ? "" : "%")
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }

                            OrionIcon { name: SystemStatus.wifiEnabled ? "network-wireless-symbolic" : "network-wireless-offline-symbolic"; fallback: SystemStatus.wifiEnabled ? "󰖩" : "󰖪"; fallbackColor: SystemStatus.wifiEnabled ? Theme.cyan : Theme.muted; size: 17 }

                            OrionIcon { name: "audio-volume-high-symbolic"; fallback: "󰕾"; fallbackColor: Theme.cyan; size: 17 }
                        }
                        MouseArea {
                            parent: controlCenterPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: controlCenter.toggle(modelData)
                            onWheel: wheel => {
                                controlCenter.adjustVolume(wheel.angleDelta.y > 0 ? .05 : -.05)
                            }
                        }
                    }

                    Pill {
                        id: activityPill
                        active: activityCenter.open

                        OrionIcon { name: NotificationService.doNotDisturb ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"; fallback: NotificationService.doNotDisturb ? "󰂛" : "󰂚"; fallbackColor: NotificationService.doNotDisturb ? Theme.red : Theme.purple; size: 18 }

                        Text {
                            visible: NotificationService.count > 0
                            text: NotificationService.count
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        OrionIcon {
                            visible: ClipboardStatus.hasEntries
                            name: "edit-paste-symbolic"; fallback: "󰅇"; fallbackColor: Theme.pink; size: 16
                        }

                        RowLayout {
                            visible: UpdateService.hasUpdates
                            spacing: 4
                            OrionIcon { name: "system-software-update-symbolic"; fallback: "󰏔"; fallbackColor: Theme.orange; size: 16 }
                            Text { text: UpdateService.totalCount; color: Theme.orange; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        }

                        MouseArea {
                            parent: activityPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: activityCenter.toggle(0, modelData)
                        }
                    }

                    Pill {
                        id: caffeinePill
                        visible: CaffeineService.active
                        active: true

                        OrionIcon { name: "caffeine-cup-full-symbolic"; fallback: "󰅶"; fallbackColor: Theme.yellow; size: 18 }

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
                        OrionIcon { name: "system-shutdown-symbolic"; fallback: "󰐥"; fallbackColor: Theme.red; size: 18 }
                        MouseArea {
                            parent: sessionPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: sessionPanel.toggle(modelData)
                        }
                    }

                    Pill {
                        id: settingsPill
                        active: settingsPanel.open
                        OrionIcon { name: "preferences-system-symbolic"; fallback: "󰒓"; fallbackColor: Theme.muted; size: 18 }
                        MouseArea {
                            parent: settingsPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: settingsPanel.toggle(modelData)
                        }
                    }
                }
            }
        }
    }
}
