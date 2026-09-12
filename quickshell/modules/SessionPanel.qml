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
    property var targetScreen: null

    function showPanel(screen) {
        if (screen) targetScreen = screen
        PanelCoordinator.request("session")
        open = true
        Qt.callLater(sessionView.takeFocus)
    }

    function toggle(screen) {
        if (open) {
            open = false
            PanelCoordinator.close("session")
            return
        }
        showPanel(screen)
    }

    IpcHandler {
        target: "session"
        function toggle(): void { root.toggle() }
        function show(): void { root.showPanel(null) }
        function hide(): void { root.open = false; PanelCoordinator.close("session") }
    }

    PanelWindow {
        screen: root.targetScreen
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
            id: panelSurface
            focus: root.open
            Keys.onEscapePressed: event => { root.open = false; PanelCoordinator.close("session"); event.accepted = true }
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

    Connections { target: PanelCoordinator; function onActivePanelChanged() { if (root.open && PanelCoordinator.activePanel !== "session") root.open = false } }
}
