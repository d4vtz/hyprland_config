import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."
import "../components"

Pill {
    id: root
    required property var screen

    function workspaceFor(id) {
        const matches = Hyprland.workspaces.values.filter(workspace => workspace.id === id)
        return matches.length > 0 ? matches[0] : null
    }

    RowLayout {
        spacing: 2

        Repeater {
            model: 7
            delegate: Rectangle {
                required property int index
                readonly property int workspaceId: index + 1
                readonly property var workspace: root.workspaceFor(workspaceId)
                readonly property bool focused: workspace !== null && workspace.active &&
                    workspace.monitor !== null && workspace.monitor.name === root.screen.name
                readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
                readonly property bool urgent: workspace !== null && workspace.urgent
                implicitWidth: 28
                implicitHeight: 26
                radius: 7
                color: urgent ? Theme.red : focused ? Theme.current : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: parent.workspaceId
                    color: parent.urgent ? Theme.background :
                           parent.focused ? Theme.foreground :
                           parent.occupied ? Theme.purple : Theme.subtle
                    font.bold: parent.focused || parent.urgent
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (parent.workspace)
                            parent.workspace.activate()
                        else
                            Hyprland.dispatch(Hyprland.usingLua
                                ? 'hl.dsp.focus({ workspace = "' + parent.workspaceId + '" })'
                                : "workspace " + parent.workspaceId)
                    }
                }
            }
        }
    }
}
