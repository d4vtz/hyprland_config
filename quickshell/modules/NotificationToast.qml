import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."
import "../services"

PanelWindow {
    id: root

    property bool showing: false
    visible: showing && NotificationService.latest !== null && !NotificationService.doNotDisturb
    anchors { top: true; right: true }
    margins { top: 8; right: 8 }
    implicitWidth: 350
    implicitHeight: 112
    exclusiveZone: 0
    color: "transparent"

    Connections {
        target: NotificationService
        function onNotificationArrived() {
            root.showing = !NotificationService.doNotDisturb
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: root.showing = false
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: Theme.radius + 2
        color: Theme.background
        border.color: "#66557d"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 11

            Rectangle {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: 10
                color: Theme.surface
                Image {
                    anchors.fill: parent
                    anchors.margins: 7
                    source: NotificationService.latest ? NotificationService.latest.appIcon : ""
                    fillMode: Image.PreserveAspectFit
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: NotificationService.latest ? (NotificationService.latest.appName || "Notificación") : ""
                    color: Theme.purple
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: NotificationService.latest ? NotificationService.latest.summary : ""
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: NotificationService.latest ? NotificationService.latest.body : ""
                    color: Theme.muted
                    textFormat: Text.PlainText
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                }
            }

            Text {
                text: "󰅖"
                color: Theme.muted
                font.family: Theme.fontFamily
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.showing = false
                }
            }
        }
    }
}
