import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."
import "../components"

Pill {
    id: root
    property bool expanded: false
    active: expanded

    Text {
        text: clock.date.toLocaleTimeString(Qt.locale(), "HH:mm")
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.bold: true
    }
    SystemClock { id: clock; precision: SystemClock.Minutes }
    MouseArea { anchors.fill: parent; onClicked: root.expanded = !root.expanded }

    PanelWindow {
        visible: root.expanded
        anchors { top: true }
        margins.top: 48
        implicitWidth: 320
        implicitHeight: 250
        exclusiveZone: 0
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: Theme.radius
            color: Theme.background
            border.color: "#66557d"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                Text { text: clock.date.toLocaleDateString(Qt.locale(), "dddd, d MMMM"); color: Theme.purple; font.family: Theme.fontFamily; font.bold: true }
                Text { Layout.fillWidth: true; text: calendar.output; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 14 }
            }
        }
        Process {
            id: calendar
            property string output: ""
            running: root.expanded
            command: ["cal", "-m"]
            stdout: StdioCollector { onStreamFinished: calendar.output = text }
        }
    }
}
