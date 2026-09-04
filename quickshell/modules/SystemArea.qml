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
    property int openPanel: 0 // 0 cerrado, 1 centro, 2 notificaciones, 3 portapapeles
    property int currentTab: 0
    readonly property bool expanded: openPanel !== 0
    active: expanded

    function openCenter(tab) {
        currentTab = tab
        openPanel = 1
        if (tab === 1)
            pacmanView.refresh()
        else if (tab === 2)
            maintenanceView.refresh()
    }
    function openNotifications() { openPanel = openPanel === 2 ? 0 : 2 }
    function openClipboard() {
        openPanel = openPanel === 3 ? 0 : 3
        if (openPanel === 3)
            clipboardView.refresh()
    }

    IpcHandler {
        target: "system"
        function toggle(): void { root.openPanel = root.openPanel === 1 ? 0 : 1 }
        function notifications(): void { root.openNotifications() }
        function clipboard(): void { root.openClipboard() }
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
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (mouse.button === Qt.MiddleButton)
                            modelData.secondaryActivate()
                        else
                            modelData.activate()
                    }
                    onWheel: wheel => modelData.scroll(wheel.angleDelta.y, false)
                }
            }
        }
        Text {
            text: "󰅇"
            color: Theme.pink
            font.family: Theme.iconFamily
            font.pixelSize: 18
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openClipboard() }
        }
        Item {
            implicitWidth: 23
            implicitHeight: 21
            Text {
                anchors.centerIn: parent
                text: NotificationService.doNotDisturb ? "󰂛" : "󰂚"
                color: NotificationService.doNotDisturb ? Theme.red : Theme.cyan
                font.family: Theme.iconFamily
                font.pixelSize: 18
            }
            Rectangle {
                visible: NotificationService.count > 0
                anchors.right: parent.right
                anchors.top: parent.top
                width: 12
                height: 12
                radius: 6
                color: Theme.purple
                Text {
                    anchors.centerIn: parent
                    text: Math.min(99, NotificationService.count)
                    color: Theme.background
                    font.family: Theme.fontFamily
                    font.pixelSize: 7
                    font.bold: true
                }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openNotifications() }
        }
        Text {
            text: "󰒓"
            color: Theme.green
            font.family: Theme.iconFamily
            font.pixelSize: 19
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openCenter(0) }
        }
    }

    PanelWindow {
        visible: root.openPanel === 1
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { anchors.fill: parent; onClicked: root.openPanel = 0 }

        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Theme.barHeight + 12
            anchors.rightMargin: 8
            width: 440
            height: 475
            radius: 12
            color: Theme.background
            border.color: Theme.border
            Behavior on width { NumberAnimation { duration: Theme.animationFast } }
            Behavior on height { NumberAnimation { duration: Theme.animationFast } }
            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 11

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: [
                            { icon: "󰀄", label: "Sesión", tab: 0, accent: Theme.purple },
                            { icon: "󰏖", label: "Pacman", tab: 1, accent: Theme.cyan },
                            { icon: "󰒓", label: "Mantenimiento", tab: 2, accent: Theme.green }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: 9
                            color: root.currentTab === modelData.tab ? Theme.current : Theme.surface
                            border.color: root.currentTab === modelData.tab ? modelData.accent : Theme.border
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: modelData.icon; color: modelData.accent; font.family: Theme.iconFamily; font.pixelSize: 16 }
                                Text { text: modelData.label; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 9 }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.openCenter(modelData.tab)
                            }
                        }
                    }
                }

                SessionView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.currentTab === 0
                }
                PacmanView {
                    id: pacmanView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.currentTab === 1
                }
                MaintenanceView {
                    id: maintenanceView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.currentTab === 2
                }
            }
        }

        Shortcut { sequence: "Esc"; onActivated: root.openPanel = 0 }
    }

    PanelWindow {
        visible: root.openPanel === 2
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { anchors.fill: parent; onClicked: root.openPanel = 0 }
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Theme.barHeight + 12
            anchors.rightMargin: 8
            width: 360
            height: 430
            radius: 12
            color: Theme.background
            border.color: Theme.border
            MouseArea { anchors.fill: parent }
            NotificationsView { anchors.fill: parent; anchors.margins: 14 }
        }
        Shortcut { sequence: "Esc"; onActivated: root.openPanel = 0 }
    }

    PanelWindow {
        visible: root.openPanel === 3
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { anchors.fill: parent; onClicked: root.openPanel = 0 }
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Theme.barHeight + 12
            anchors.rightMargin: 8
            width: 360
            height: 430
            radius: 12
            color: Theme.background
            border.color: Theme.border
            MouseArea { anchors.fill: parent }
            ClipboardView {
                id: clipboardView
                anchors.fill: parent
                anchors.margins: 14
                onEntryCopied: root.openPanel = 0
            }
        }
        Shortcut { sequence: "Esc"; onActivated: root.openPanel = 0 }
    }
}
