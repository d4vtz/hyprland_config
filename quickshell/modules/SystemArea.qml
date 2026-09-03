import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import ".."
import "../components"

Pill {
    id: root
    property bool expanded: false
    active: expanded

    RowLayout {
        spacing: 10
        Repeater {
            model: SystemTray.items
            delegate: Image {
                required property var modelData
                source: modelData.icon
                sourceSize.width: 16
                sourceSize.height: 16
                width: 16
                height: 16
                MouseArea { anchors.fill: parent; onClicked: modelData.activate() }
            }
        }
        Text { text: "󰂚"; color: Theme.purple; font.family: Theme.fontFamily }
        Text { text: "󰐥"; color: Theme.pink; font.family: Theme.fontFamily }
    }

    MouseArea {
        parent: root
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) powerMenu.running = true
            else root.expanded = !root.expanded
        }
    }

    Process { id: powerMenu; command: [Qt.resolvedUrl("../../scripts/powermenu.sh").toString().replace("file://", "")] }

    PanelWindow {
        visible: root.expanded
        anchors { top: true; right: true; bottom: true }
        margins { top: 2; right: 8; bottom: 8 }
        implicitWidth: 320
        exclusiveZone: 0
        color: "transparent"
        Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.background
        border.color: "#66557d"
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            Text { text: "Sistema y sesión"; color: Theme.foreground; font.family: Theme.fontFamily; font.bold: true }
            Text { text: "Centro de notificaciones"; color: Theme.purple; font.family: Theme.fontFamily }
            Text { text: "Clic derecho: menú de energía"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 11 }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: notifications.running = true
        }
        Process { id: notifications; command: ["swaync-client", "-t", "-sw"] }
        }
    }
}
