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
        const values = String(frame).trim().split(";")
            .map(value => Number(value))
            .filter(value => isFinite(value))
            .slice(0, 8)
            .map(value => Math.max(0.06, Math.min(1, value / 100)))
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
        id: cavaProcess
        running: true
        command: ["cava", "-p", Quickshell.shellDir + "/cava.conf"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: frame => root.updateSpectrum(frame)
        }
        stderr: SplitParser {
            onRead: message => console.warn("cava:", message)
        }
        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0)
                console.warn("cava exited with code", exitCode)
            restartTimer.restart()
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: if (!cavaProcess.running) cavaProcess.running = true
    }

    MouseArea {
        parent: root
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.expanded) {
                root.expanded = false
                PanelCoordinator.close("media")
            } else {
                PanelCoordinator.request("media")
                root.expanded = true
            }
        }
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
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { anchors.fill: parent; onClicked: { root.expanded = false; PanelCoordinator.close("media") } }

        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Theme.barPanelTopMargin
            anchors.rightMargin: 304
            width: 420
            height: 204
            radius: Theme.panelRadius
            color: Theme.background
            border.color: "transparent"

            MouseArea { anchors.fill: parent }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14

                Rectangle {
                    Layout.preferredWidth: 132
                    Layout.preferredHeight: 132
                    radius: Theme.radius
                    color: Theme.surfaceContainer
                    clip: true

                    OrionIcon {
                        anchors.centerIn: parent
                        materialName: "album"
                        fallbackColor: Theme.current
                        size: 38
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

                    Text { Layout.fillWidth: true; text: root.player ? (root.player.trackTitle || "Sin título") : "Nada reproduciéndose"; color: Theme.foreground; elide: Text.ElideRight; font.family: Theme.fontFamily; font.pixelSize: 13; font.bold: true }
                    Text { Layout.fillWidth: true; text: root.player ? (root.player.trackArtist || root.player.identity || "Artista desconocido") : "Abre tu reproductor multimedia"; color: Theme.muted; elide: Text.ElideRight; font.family: Theme.fontFamily; font.pixelSize: 11 }
                    Item { Layout.fillHeight: true }

                    Rectangle {
                        id: progressTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5
                        radius: 3
                        color: Theme.current
                        Rectangle { width: root.player && root.player.lengthSupported && root.player.length > 0 ? parent.width * Math.min(1, root.player.position / root.player.length) : 0; height: parent.height; radius: parent.radius; color: Theme.purple }
                        MouseArea { anchors.fill: parent; enabled: root.player && root.player.canSeek && root.player.positionSupported; cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor; onClicked: mouse => root.player.position = root.player.length * mouse.x / width }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: root.player ? root.formatTime(root.player.position) : "0:00"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                        Item { Layout.fillWidth: true }
                        Text { text: root.player && root.player.lengthSupported ? root.formatTime(root.player.length) : "--:--"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16
                        OrionIcon { materialName: "skip_previous"; fallbackColor: Theme.foreground; size: 18; opacity: root.player && root.player.canGoPrevious ? 1 : 0.3; MouseArea { anchors.fill: parent; onClicked: if (root.player && root.player.canGoPrevious) root.player.previous() } }
                        OrionIcon { materialName: root.player && root.player.isPlaying ? "pause" : "play_arrow"; fallbackColor: Theme.background; size: 22; Rectangle { anchors.fill: parent; anchors.margins: -7; z: -1; radius: 20; color: Theme.purple }; MouseArea { anchors.fill: parent; onClicked: if (root.player) root.player.togglePlaying() } }
                        OrionIcon { materialName: "skip_next"; fallbackColor: Theme.foreground; size: 18; opacity: root.player && root.player.canGoNext ? 1 : 0.3; MouseArea { anchors.fill: parent; onClicked: if (root.player && root.player.canGoNext) root.player.next() } }
                    }
                }
            }
        }

        Shortcut { sequence: "Esc"; onActivated: { root.expanded = false; PanelCoordinator.close("media") } }
    }

    Connections { target: PanelCoordinator; function onActivePanelChanged() { if (root.expanded && PanelCoordinator.activePanel !== "media") root.expanded = false } }
}
