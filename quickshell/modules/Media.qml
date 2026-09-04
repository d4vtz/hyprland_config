import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris
import ".."
import "../components"

Pill {
    id: root

    property bool expanded: false
    property var spectrum: [0, 0, 0, 0, 0, 0, 0, 0]
    readonly property var players: Mpris.players.values
    readonly property var player: {
        for (let candidate of players) {
            if (candidate.playbackState === MprisPlaybackState.Playing)
                return candidate
        }
        return players.length > 0 ? players[0] : null
    }

    active: expanded

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00"
        const minutes = Math.floor(seconds / 60)
        const remainder = Math.floor(seconds % 60)
        return minutes + ":" + (remainder < 10 ? "0" : "") + remainder
    }

    function updateSpectrum(frame) {
        const values = frame.trim().split(";")
            .filter(value => value.length > 0)
            .slice(0, 8)
            .map(value => Math.max(0.06, Math.min(1, Number(value) / 100)))
        if (values.length === 8)
            spectrum = values
    }

    Item {
        Layout.preferredWidth: 42
        Layout.preferredHeight: 18

        Row {
            anchors.fill: parent
            spacing: 2

            Repeater {
                model: 8
                delegate: Item {
                    required property int index
                    width: 3
                    height: parent.height

                    Rectangle {
                        width: parent.width
                        height: Math.max(2, parent.height * root.spectrum[index])
                        anchors.bottom: parent.bottom
                        radius: 2
                        color: index < 3 ? Theme.purple : index < 6 ? Theme.pink : Theme.cyan

                        Behavior on height {
                            NumberAnimation { duration: 65; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }
    }

    Process {
        running: root.player !== null && root.player.isPlaying
        command: [
            "cava",
            "-p",
            Qt.resolvedUrl("../cava.conf").toString().replace("file://", "")
        ]
        stdout: SplitParser {
            onRead: frame => root.updateSpectrum(frame)
        }
    }

    MouseArea {
        parent: root
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.expanded && root.player && root.player.isPlaying
        onTriggered: root.player.positionChanged()
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
            anchors.topMargin: Theme.barHeight + 12
            anchors.rightMargin: 304
            width: 390
            height: 188
            radius: Theme.radius + 2
            color: Theme.background
            border.color: Theme.border

            MouseArea { anchors.fill: parent }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14

                Rectangle {
                    Layout.preferredWidth: 132
                    Layout.preferredHeight: 132
                    radius: Theme.radius
                    color: Theme.surface
                    clip: true

                    Text {
                        anchors.centerIn: parent
                        text: "󰎆"
                        color: Theme.current
                        font.family: Theme.iconFamily
                        font.pixelSize: 38
                    }

                    Image {
                        anchors.fill: parent
                        source: root.player ? root.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: status === Image.Ready
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5

                    Text {
                        Layout.fillWidth: true
                        text: root.player ? (root.player.trackTitle || "Sin título") : "Nada reproduciéndose"
                        color: Theme.foreground
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.player ? (root.player.trackArtist || root.player.identity || "Artista desconocido") : "Abre tu reproductor multimedia"
                        color: Theme.muted
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle {
                        id: progressTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5
                        radius: 3
                        color: Theme.current

                        Rectangle {
                            width: root.player && root.player.lengthSupported && root.player.length > 0
                                ? parent.width * Math.min(1, root.player.position / root.player.length)
                                : 0
                            height: parent.height
                            radius: parent.radius
                            color: Theme.purple

                            Behavior on width {
                                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: root.player && root.player.canSeek && root.player.positionSupported
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: mouse => root.player.position = root.player.length * mouse.x / width
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: root.player ? root.formatTime(root.player.position) : "0:00"
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.player && root.player.lengthSupported ? root.formatTime(root.player.length) : "--:--"
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16

                        Text {
                            text: "󰒮"
                            color: Theme.foreground
                            opacity: root.player && root.player.canGoPrevious ? 1 : 0.3
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            MouseArea {
                                anchors.fill: parent
                                enabled: root.player && root.player.canGoPrevious
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.player.previous()
                            }
                        }

                        Rectangle {
                            implicitWidth: 38
                            implicitHeight: 38
                            radius: 19
                            color: playArea.containsMouse ? Theme.pink : Theme.purple
                            opacity: root.player && root.player.canTogglePlaying ? 1 : 0.4

                            Behavior on color { ColorAnimation { duration: Theme.animationFast } }

                            Text {
                                anchors.centerIn: parent
                                text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
                                color: Theme.background
                                font.family: Theme.iconFamily
                                font.pixelSize: 17
                            }
                            MouseArea {
                                id: playArea
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: root.player && root.player.canTogglePlaying
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.player.togglePlaying()
                            }
                        }

                        Text {
                            text: "󰒭"
                            color: Theme.foreground
                            opacity: root.player && root.player.canGoNext ? 1 : 0.3
                            font.family: Theme.iconFamily
                            font.pixelSize: 18
                            MouseArea {
                                anchors.fill: parent
                                enabled: root.player && root.player.canGoNext
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.player.next()
                            }
                        }
                    }
                }
            }
        }

        Shortcut {
            sequence: "Esc"
            onActivated: root.expanded = false
        }
    }
}
