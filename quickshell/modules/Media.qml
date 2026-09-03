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
    readonly property var player: players.length > 0 ? players[0] : null
    active: expanded

    Text {
        text: root.player && root.player.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰎆"
        color: Theme.purple
        font.family: Theme.fontFamily
        font.pixelSize: 16
    }

    MouseArea {
        parent: root
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    PanelWindow {
        visible: root.expanded
        anchors { top: true; right: true }
        margins { top: 48; right: 350 }
        implicitWidth: 340
        implicitHeight: 112
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
            Text {
                Layout.fillWidth: true
                text: root.player ? (root.player.trackTitle || "Sin título") : "No hay reproducción"
                color: Theme.foreground
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.bold: true
            }
            Text {
                Layout.fillWidth: true
                text: root.player ? (root.player.trackArtist || "") : ""
                color: Theme.muted
                elide: Text.ElideRight
                font.family: Theme.fontFamily
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 24
                Repeater {
                    model: ["󰒮", "󰐎", "󰒭"]
                    Text {
                        required property string modelData
                        text: modelData
                        color: Theme.purple
                        font.family: Theme.fontFamily
                        font.pixelSize: 19
                    }
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: mouse => {
                if (!root.player) return
                if (mouse.x < width / 3) root.player.previous()
                else if (mouse.x < width * 2 / 3) root.player.togglePlaying()
                else root.player.next()
            }
        }
        }
    }
}
