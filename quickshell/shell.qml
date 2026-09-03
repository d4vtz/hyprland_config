import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "components"
import "modules"

ShellRoot {
    NotificationToast {}

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
                color: "#e6111218"
                radius: 11
                border.color: "#452f465f"

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8
                    spacing: 7
                    Pill {
                        id: launcherPill
                        Text { text: "󰣇"; color: Theme.purple; font.family: Theme.fontFamily; font.pixelSize: 16 }
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
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 8
                    spacing: 7
                    Media {}
                    Hardware {}
                    SystemArea {}
                }
            }
        }
    }
}
