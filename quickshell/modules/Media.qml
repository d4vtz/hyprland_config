import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import ".."
import "../components"

Pill {
    id: root

    property bool expanded: false
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

    Text {
        text: root.player && root.player.isPlaying ? "󰏤" : "󰎆"
        color: root.player ? Theme.purple : Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: 16
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
        anchors { top: true; right: true }
        margins { top: 48; right: 304 }
        implicitWidth: 390
        implicitHeight: 188
        exclusiveZone: 0
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: Theme.radius + 2
            color: Theme.background
            border.color: "#66557d"

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
                        font.family: Theme.fontFamily
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
                                font.family: Theme.fontFamily
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
                            font.family: Theme.fontFamily
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
