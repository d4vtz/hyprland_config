import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."

PanelWindow {
    id: root
    property string icon: "󰕾"
    property string label: "Volumen"
    property real value: 0
    property bool muted: false
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    visible: hideTimer.running
    anchors { bottom: true }
    margins { bottom: 72 }
    implicitWidth: 310
    implicitHeight: 64
    exclusiveZone: 0
    color: "transparent"

    PwObjectTracker { objects: [root.sink, root.source] }

    function reveal(newIcon, newLabel, newValue, isMuted) {
        icon = newIcon
        label = newLabel
        value = Math.max(0, Math.min(1, newValue))
        muted = isMuted
        hideTimer.restart()
    }

    function showVolume() {
        const isMuted = !sink || sink.audio.muted
        reveal(isMuted ? "󰝟" : "󰕾", isMuted ? "Silenciado" : "Volumen",
               sink ? sink.audio.volume : 0, isMuted)
    }

    function showMicrophone() {
        const isMuted = !source || source.audio.muted
        reveal(isMuted ? "󰍭" : "󰍬", isMuted ? "Micrófono silenciado" : "Micrófono",
               source ? source.audio.volume : 0, isMuted)
    }

    IpcHandler {
        target: "osd"
        function volume(): void { root.showVolume() }
        function microphone(): void { root.showMicrophone() }
        function brightness(): void { brightnessQuery.running = true }
    }

    Process {
        id: brightnessQuery
        command: ["sh", "-c", "brightnessctl -m | awk -F, '{gsub(/%/, \"\", $4); print $4; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: root.reveal("󰃠", "Brillo", (Number(text.trim()) || 0) / 100, false)
        }
    }

    Timer { id: hideTimer; interval: 1400 }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Theme.background
        border.color: Theme.borderActive

        RowLayout {
            anchors.fill: parent
            anchors.margins: 13
            spacing: 12
            Text {
                text: root.icon
                color: root.muted ? Theme.muted : Theme.purple
                font.family: Theme.iconFamily
                font.pixelSize: 22
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: root.label; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                    Item { Layout.fillWidth: true }
                    Text { text: Math.round(root.value * 100) + "%"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10 }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    radius: 3
                    color: Theme.current
                    Rectangle {
                        width: parent.width * root.value
                        height: parent.height
                        radius: 3
                        color: root.muted ? Theme.muted : Theme.purple
                    }
                }
            }
        }
    }
}
