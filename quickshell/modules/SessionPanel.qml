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

    function toggle() { open = !open }

    IpcHandler {
        target: "session"
        function toggle(): void { root.toggle() }
        function show(): void { root.open = true }
        function hide(): void { root.open = false }
    }

    PanelWindow {
        visible: root.open
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { anchors.fill: parent; onClicked: root.open = false }

        Surface {
            width: 470
            height: 360
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingXl
                spacing: Theme.spacingLg

                SectionTitle {
                    Layout.fillWidth: true
                    icon: "󰐥"
                    title: "Sesión"
                    subtitle: SystemStatus.userName + "@" + SystemStatus.hostName
                    accent: Theme.purple
                }

                SessionView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }

        Shortcut { sequence: "Esc"; onActivated: root.open = false }
    }
}
