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
    property int tab: 0

    function activatePage(page) {
        tab = page
        if (tab === 1) {
            clipboard.refresh()
            Qt.callLater(clipboard.takeFocus)
        } else if (tab === 2) {
            UpdateService.refresh()
        }
    }

    function toggle(page) {
        if (open && tab === page) {
            open = false
            return
        }
        open = true
        activatePage(page)
    }

    IpcHandler {
        target: "activity"
        function notifications(): void { root.toggle(0) }
        function clipboard(): void { root.toggle(1) }
        function updates(): void { root.toggle(2) }
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
            width: 430
            height: 540
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 54
            anchors.rightMargin: 10

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingLg
                spacing: Theme.spacingMd

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm

                    Repeater {
                        model: [
                            { icon: "󰂚", label: "Avisos", page: 0, accent: Theme.cyan },
                            { icon: "󰅇", label: "Portapapeles", page: 1, accent: Theme.pink },
                            { icon: "󰏔", label: "Actualizaciones", page: 2, accent: Theme.orange }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: Theme.cardRadius
                            color: root.tab === modelData.page ? Theme.current : Theme.surface
                            border.width: 1
                            border.color: root.tab === modelData.page ? modelData.accent : Theme.border

                            Row {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: modelData.icon; color: modelData.accent; font.family: Theme.iconFamily }
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
                    onCopied: root.open = false
                }

                UpdatesView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.tab === 2
                }
            }
        }

        Shortcut { sequence: "Esc"; onActivated: root.open = false }
    }
}
