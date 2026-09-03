import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

Pill {
    id: root

    property bool expanded: false
    property bool outputsExpanded: false
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var outputNodes: Pipewire.nodes.values.filter(node =>
        node.audio !== null && node.isSink && !node.isStream)

    active: expanded

    PwObjectTracker { objects: [root.sink, root.source].concat(root.outputNodes) }

    RowLayout {
        spacing: 9
        Text { text: "󰖩"; color: Theme.cyan; font.family: Theme.iconFamily }
        Text {
            text: root.sink ? Math.round(root.sink.audio.volume * 100) + "%" : "--"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
        Text {
            text: root.source && root.source.audio.muted ? "󰍭" : "󰍬"
            color: root.source && root.source.audio.muted ? Theme.red : Theme.green
            font.family: Theme.fontFamily
        }
        Text {
            text: "󰁹 " + SystemStatus.battery + (SystemStatus.battery === "CA" ? "" : "%")
            color: Theme.orange
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }

    MouseArea {
        parent: root
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
        onWheel: wheel => {
            if (root.sink)
                root.sink.audio.volume = Math.max(0, Math.min(1.5,
                    root.sink.audio.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)))
        }
    }

    Process {
        id: brightnessSetter
        onExited: SystemStatus.refresh()
    }

    PanelWindow {
        visible: root.expanded
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.outputsExpanded = false
                root.expanded = false
            }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 2
            anchors.rightMargin: 102
            width: 330
            height: root.outputsExpanded ? 436 : 350
            radius: Theme.radius + 2
            color: Theme.background
            border.color: Theme.border

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Hardware"; color: Theme.foreground; font.family: Theme.fontFamily; font.bold: true }
                    Item { Layout.fillWidth: true }
                    Text { text: SystemStatus.network; color: Theme.cyan; font.family: Theme.fontFamily; font.pixelSize: 10; elide: Text.ElideRight; Layout.maximumWidth: 145 }
                    Text { text: SystemStatus.battery + (SystemStatus.battery === "CA" ? "" : "%"); color: Theme.orange; font.family: Theme.fontFamily; font.pixelSize: 10 }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58
                    radius: 8
                    color: Theme.surface
                    ValueSlider {
                        anchors.fill: parent
                        anchors.margins: 12
                        icon: "󰃠"
                        value: SystemStatus.brightness
                        accent: Theme.yellow
                        onValueRequested: value => {
                            SystemStatus.brightness = value
                            brightnessSetter.command = ["brightnessctl", "set", Math.round(value * 100) + "%"]
                            brightnessSetter.running = true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.outputsExpanded ? 150 : 78
                    radius: 8
                    color: Theme.surface

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        ValueSlider {
                            Layout.fillWidth: true
                            icon: root.sink && root.sink.audio.muted ? "󰝟" : "󰕾"
                            value: root.sink ? Math.min(1, root.sink.audio.volume) : 0
                            accent: Theme.purple
                            onValueRequested: value => {
                                if (root.sink) {
                                    root.sink.audio.muted = false
                                    root.sink.audio.volume = value
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            radius: 7
                            color: outputArea.containsMouse || root.outputsExpanded ? Theme.surfaceHover : Theme.current
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 9
                                anchors.rightMargin: 9
                                Text {
                                    Layout.fillWidth: true
                                    text: root.sink ? (root.sink.description || root.sink.nickname || root.sink.name) : "Sin salida"
                                    color: Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                }
                                Text { text: root.outputsExpanded ? "󰅃" : "󰅀"; color: Theme.pink; font.family: Theme.iconFamily }
                            }
                            MouseArea {
                                id: outputArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.outputsExpanded = !root.outputsExpanded
                            }
                        }

                        ColumnLayout {
                            visible: root.outputsExpanded
                            Layout.fillWidth: true
                            spacing: 3
                            Repeater {
                                model: root.outputNodes
                                delegate: Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 27
                                    radius: 6
                                    color: modelData === root.sink ? Theme.pink : deviceArea.containsMouse ? Theme.current : "transparent"
                                    Text {
                                        anchors.fill: parent
                                        anchors.leftMargin: 9
                                        anchors.rightMargin: 9
                                        verticalAlignment: Text.AlignVCenter
                                        text: modelData.description || modelData.nickname || modelData.name
                                        color: modelData === root.sink ? Theme.background : Theme.foreground
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 9
                                        elide: Text.ElideRight
                                    }
                                    MouseArea {
                                        id: deviceArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Pipewire.preferredDefaultAudioSink = modelData
                                            root.outputsExpanded = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58
                    radius: 8
                    color: Theme.surface
                    ValueSlider {
                        anchors.fill: parent
                        anchors.margins: 12
                        icon: root.source && root.source.audio.muted ? "󰍭" : "󰍬"
                        value: root.source ? root.source.audio.volume : 0
                        accent: root.source && root.source.audio.muted ? Theme.red : Theme.cyan
                        onValueRequested: value => {
                            if (root.source) {
                                root.source.audio.muted = false
                                root.source.audio.volume = value
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        radius: 8
                        color: Theme.surface
                        Text { anchors.centerIn: parent; text: "󰖩  " + SystemStatus.network; color: Theme.cyan; font.family: Theme.fontFamily; font.pixelSize: 10 }
                    }
                    Rectangle {
                        Layout.preferredWidth: 82
                        Layout.preferredHeight: 42
                        radius: 8
                        color: Theme.surface
                        Text { anchors.centerIn: parent; text: "󰁹  " + SystemStatus.battery + (SystemStatus.battery === "CA" ? "" : "%"); color: Theme.orange; font.family: Theme.fontFamily; font.pixelSize: 10 }
                    }
                }
            }
        }

        Shortcut {
            sequence: "Esc"
            onActivated: {
                root.outputsExpanded = false
                root.expanded = false
            }
        }
    }
}
