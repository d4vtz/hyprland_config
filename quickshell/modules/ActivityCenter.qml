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
    property int tab: 0

    function closePanel() { open = false; PanelCoordinator.close("activity") }

    function activatePage(page) {
        tab = page
        if (tab === 1) {
            clipboard.refresh()
            Qt.callLater(clipboard.takeFocus)
        } else if (tab === 2) {
            UpdateService.refresh()
        } else if (tab === 3) {
            maintenance.refresh()
        }
    }

    function toggle(page, screen) {
        if (open && tab === page) {
            closePanel()
            return
        }
        if (screen) targetScreen = screen
        PanelCoordinator.request("activity")
        open = true
        activatePage(page)
    }

    IpcHandler {
        target: "activity"
        function notifications(): void { root.toggle(0) }
        function clipboard(): void { root.toggle(1) }
        function updates(): void { root.toggle(2) }
        function hide(): void { root.closePanel() }
    }

    PanelWindow {
        screen: root.targetScreen
        visible: root.open
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { anchors.fill: parent; onClicked: root.closePanel() }

        Surface {
            id: panelSurface
            focus: root.open
            Keys.onEscapePressed: event => { root.closePanel(); event.accepted = true }
            width: 460
            height: 590
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 58
            anchors.rightMargin: 10

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingXl
                spacing: Theme.spacingMd

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm

                    Repeater {
                        model: [
                            { icon: "notifications", label: "Avisos", page: 0, accent: Theme.cyan },
                            { icon: "content_paste", label: "Portapapeles", page: 1, accent: Theme.pink },
                            { icon: "system_update", label: "Actualizaciones", page: 2, accent: Theme.orange },
                            { icon: "build", label: "Mantenimiento", page: 3, accent: Theme.green }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: Theme.cardRadius
                            color: root.tab === modelData.page ? Theme.current : Theme.surface
                            border.width: 0
                            border.color: root.tab === modelData.page ? modelData.accent : Theme.border

                            Row {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: modelData.icon; color: modelData.accent; font.family: Theme.materialIconFamily; font.pixelSize: 18 }
                                Text { text: modelData.label; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activatePage(modelData.page)
                            }
                        }
                    }
                }

                NotificationsView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.tab === 0
                }

                ClipboardView {
                    id: clipboard
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.tab === 1
                    onCopied: root.closePanel()
                }

                UpdatesView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.tab === 2
                }
                MaintenanceView {
                    id: maintenance
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.tab === 3
                }
            }
        }

    }
    Connections { target: PanelCoordinator; function onActivePanelChanged() { if (root.open && PanelCoordinator.activePanel !== "activity") root.closePanel() } }
}
