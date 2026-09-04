import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "components"
import "modules"

ShellRoot {
    NotificationToast {}
    DesktopOsd {}

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            color: "transparent"
            implicitHeight: Theme.barHeight + 8
            anchors { top: true; left: true; right: true }
            exclusiveZone: Theme.barHeight + 8

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                color: Theme.barBackground
                radius: 11
                border.color: "transparent"

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8
                    anchors.rightMargin: 48
                    spacing: 7
                    clip: true
                    Pill {
                        id: launcherPill
                        Text { text: "󰣇"; color: Theme.purple; font.family: Theme.iconFamily; font.pixelSize: 16 }
                        MouseArea {
                            parent: launcherPill
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: launcher.running = true
                        }
                        Process { id: launcher; command: ["rofi", "-show", "drun"] }
                    }
                    Workspaces { screen: modelData }
                    ActiveWindow {}
                }

                Clock { anchors.centerIn: parent }

                RowLayout {
                    anchors.left: parent.horizontalCenter
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 48
                    anchors.rightMargin: 8
                    spacing: 7
                    clip: true
                    Media {}
                    Hardware {}
                    SystemArea {}
                }
            }
        }
    }
}
