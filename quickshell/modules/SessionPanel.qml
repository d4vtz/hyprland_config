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

    function showPanel() {
        open = true
        Qt.callLater(sessionView.takeFocus)
    }

    function toggle() {
        if (open) {
            open = false
            return
        }
        showPanel()
    }

    IpcHandler {
        target: "session"
        function toggle(): void { root.toggle() }
        function show(): void { root.showPanel() }
        function hide(): void { root.open = false }
    }

    PanelWindow {
        visible: root.open
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea {
            anchors.fill: parent
            onClicked: root.open = false
        }

        Surface {
            width: 470
            height: 370
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingXl
                spacing: Theme.spacingMd

                SectionTitle {
                    Layout.fillWidth: true
                    icon: "󰐥"
                    title: "Sesión"
                    subtitle: "Orion · " + SystemStatus.distribution
                    accent: Theme.purple
                }

                SessionView {
                    id: sessionView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onCloseRequested: root.open = false
                }
            }
        }

        Shortcut {
            sequence: "Esc"
            onActivated: {
                if (!sessionView.handleEscape())
                    root.open = false
            }
        }
    }
}
