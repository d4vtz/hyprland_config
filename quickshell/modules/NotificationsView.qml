import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

ColumnLayout {
    id: root
    spacing: 9

    RowLayout {
        Layout.fillWidth: true
        Text {
            text: NotificationService.count + (NotificationService.count === 1 ? " notificación" : " notificaciones")
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.bold: true
        }
        Item { Layout.fillWidth: true }
        Text {
            text: NotificationService.doNotDisturb ? "󰂛" : "󰂚"
            color: NotificationService.doNotDisturb ? Theme.red : Theme.purple
            font.family: Theme.fontFamily
            font.pixelSize: 16
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: NotificationService.doNotDisturb = !NotificationService.doNotDisturb
            }
        }
        Text {
            text: "󰆴"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 15
            opacity: NotificationService.count > 0 ? 1 : 0.35
            MouseArea {
                anchors.fill: parent
                enabled: NotificationService.count > 0
                cursorShape: Qt.PointingHandCursor
                onClicked: NotificationService.clearAll()
            }
        }
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 7
        clip: true
        model: NotificationService.notifications

        delegate: Rectangle {
            required property var modelData
            width: ListView.view.width
            height: 82
            radius: 8
            color: Theme.surface

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 9
                Image {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    source: modelData.appIcon
                    fillMode: Image.PreserveAspectFit
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        Layout.fillWidth: true
                        text: modelData.appName || "Notificación"
                        color: Theme.purple
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: modelData.summary
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: modelData.body
                        color: Theme.muted
                        textFormat: Text.PlainText
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        maximumLineCount: 2
                        elide: Text.ElideRight
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
                        onClicked: modelData.dismiss()
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: NotificationService.count === 0
            text: NotificationService.doNotDisturb ? "󰂛\nNo molestar activado" : "󰂚\nSin notificaciones"
            color: Theme.muted
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }
}

