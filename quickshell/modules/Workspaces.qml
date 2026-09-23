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
                readonly property bool focused: Hyprland.focusedWorkspace
                    && Hyprland.focusedWorkspace.id === workspaceId

                implicitWidth: focused ? 34 : 30
                implicitHeight: 30
                radius: 15
                color: focused ? Theme.primary : "transparent"

                Behavior on implicitWidth {
                    NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutCubic }
                }

                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast }
                }

                Text {
                    anchors.centerIn: parent
                    text: parent.workspaceId
                    color: parent.focused ? Theme.primaryText : Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: parent.focused ? Font.DemiBold : Font.Normal
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch(
                        Hyprland.usingLua
                            ? 'hl.dsp.focus({ workspace = "' + parent.workspaceId + '" })'
                            : "workspace " + parent.workspaceId
                    )
                }
            }
        }
    }
}
