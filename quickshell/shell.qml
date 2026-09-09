import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "components"
import "modules"

ShellRoot {
    NotificationToast {}
    Dashboard { id: dashboard }

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
                            onClicked: launcher.running = true
                        }
                        Process { id: launcher; command: ["rofi", "-show", "drun"] }
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
                    Hardware {}
                    SystemArea {}
                }
            }
        }
    }
}
