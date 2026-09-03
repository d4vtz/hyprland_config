import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import ".."
import "../components"
import "../services"

Pill {
    id: root
    property bool expanded: false
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    active: expanded

    PwObjectTracker { objects: [root.sink, root.source] }

    RowLayout {
        spacing: 9
        Text { text: "󰖩"; color: Theme.cyan; font.family: Theme.fontFamily }
        Text { text: root.sink ? Math.round(root.sink.audio.volume * 100) + "%" : "--"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 11 }
        Text { text: root.source && root.source.audio.muted ? "󰍭" : "󰍬"; color: root.source && root.source.audio.muted ? Theme.red : Theme.green; font.family: Theme.fontFamily }
        Text { text: "󰁹 " + SystemStatus.battery + (SystemStatus.battery === "CA" ? "" : "%"); color: Theme.orange; font.family: Theme.fontFamily; font.pixelSize: 11 }
    }

    MouseArea {
        parent: root
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
        onWheel: wheel => {
            if (!root.sink) return
            root.sink.audio.volume = Math.max(0, Math.min(1.5, root.sink.audio.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)))
        }
    }

    PanelWindow {
        visible: root.expanded
        anchors { top: true; right: true }
        margins { top: 43; right: 110 }
        implicitWidth: 300
        implicitHeight: 104
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
            Text { text: "Red  " + SystemStatus.network; color: Theme.foreground; font.family: Theme.fontFamily }
            Text { text: "Volumen  " + (root.sink ? Math.round(root.sink.audio.volume * 100) + "%" : "--"); color: Theme.foreground; font.family: Theme.fontFamily }
            Text { text: "Micrófono  " + (root.source && root.source.audio.muted ? "silenciado" : "activo"); color: Theme.foreground; font.family: Theme.fontFamily }
        }
        }
    }
}
