import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

Pill {
    id: root

    property bool expanded: false
    property int currentTab: 0
    active: expanded

    function openTab(tab) {
        currentTab = tab
        expanded = true
        if (tab === 2)
            clipboardView.refresh()
    }

    IpcHandler {
        target: "system"
        function toggle(): void { root.expanded = !root.expanded }
        function notifications(): void { root.openTab(1) }
        function clipboard(): void { root.openTab(2) }
    }

    RowLayout {
        spacing: 11

        Repeater {
            model: SystemTray.items
            delegate: Image {
                required property var modelData
                source: modelData.icon
                sourceSize.width: 19
                sourceSize.height: 19
                width: 19
                height: 19
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.activate() }
            }
        }

        Text {
            text: "󰅇"
            color: Theme.pink
            font.family: Theme.iconFamily
            font.pixelSize: 17
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openTab(2) }
        }

        Item {
            implicitWidth: 22
            implicitHeight: 20
            Text {
                anchors.centerIn: parent
                text: NotificationService.doNotDisturb ? "󰂛" : "󰂚"
                color: NotificationService.doNotDisturb ? Theme.red : Theme.purple
                font.family: Theme.iconFamily
                font.pixelSize: 17
            }
            Rectangle {
                visible: NotificationService.count > 0
                anchors.right: parent.right
                anchors.top: parent.top
                width: 12
                height: 12
                radius: 6
                color: Theme.pink
                Text {
                    anchors.centerIn: parent
                    text: Math.min(99, NotificationService.count)
                    color: Theme.background
                    font.family: Theme.iconFamily
                    font.pixelSize: 7
                    font.bold: true
                }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openTab(1) }
        }

        Text {
            text: "󰐥"
            color: Theme.red
            font.family: Theme.iconFamily
            font.pixelSize: 17
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openTab(0) }
        }
    }

    PanelWindow {
        visible: root.expanded
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { anchors.fill: parent; onClicked: root.expanded = false }

        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 2
            anchors.rightMargin: 8
            width: 350
            height: 430
            radius: Theme.radius + 2
            color: Theme.background
            border.color: Theme.border

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 11

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8
                    Repeater {
                        model: [
                            { icon: "󰐥", tab: 0, tip: "Sistema" },
                            { icon: "󰂚", tab: 1, tip: "Notificaciones" },
                            { icon: "󰅇", tab: 2, tip: "Portapapeles" }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            implicitWidth: 72
                            implicitHeight: 34
                            radius: 8
                            color: root.currentTab === modelData.tab ? Theme.current : Theme.surface
                            border.color: root.currentTab === modelData.tab ? Theme.purple : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: root.currentTab === modelData.tab ? Theme.purple : Theme.muted
                                font.family: Theme.iconFamily
                                font.pixelSize: 16
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.openTab(modelData.tab)
                            }
                        }
                    }
                }

                SessionView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.currentTab === 0
                }
                NotificationsView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.currentTab === 1
                }
                ClipboardView {
                    id: clipboardView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.currentTab === 2
                }
            }
        }

        Shortcut {
            sequence: "Esc"
            onActivated: root.expanded = false
        }
    }
}
