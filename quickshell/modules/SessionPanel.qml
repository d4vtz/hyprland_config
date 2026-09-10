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
            height: 300
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingXl
                spacing: Theme.spacingMd

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingLg

                    SectionTitle {
                        Layout.fillWidth: true
                        icon: "󰐥"
                        title: "Sesión"
                        subtitle: "Orion Shell"
                        accent: Theme.purple
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 135
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: SystemStatus.userName
                            horizontalAlignment: Text.AlignRight
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Activo " + SystemStatus.uptime
                            horizontalAlignment: Text.AlignRight
                            color: Theme.green
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }

                SessionView {
                    id: sessionView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onCloseRequested: root.open = false
                    onPanelCloseRequested: root.open = false
                }
            }
        }
    }
}
