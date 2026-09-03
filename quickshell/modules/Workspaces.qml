import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."
import "../components"

Pill {
    id: root
    required property var screen

    RowLayout {
        spacing: 2

        Repeater {
            model: 7
            delegate: Rectangle {
                required property int index
                readonly property int workspaceId: index + 1
                readonly property bool focused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === workspaceId
                implicitWidth: 28
                implicitHeight: 26
                radius: 7
                color: focused ? Theme.current : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: parent.workspaceId
                    color: parent.focused ? Theme.foreground : Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch(Hyprland.usingLua
                        ? 'hl.dsp.focus({ workspace = "' + parent.workspaceId + '" })'
                        : "workspace " + parent.workspaceId)
                }
            }
        }
    }
}

