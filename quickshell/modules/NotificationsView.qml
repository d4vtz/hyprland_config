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
            font.family: Theme.iconFamily
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
            font.family: Theme.iconFamily
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
            property bool expanded: false
            readonly property var notificationActions: modelData.actions || []
            width: ListView.view.width
            height: notificationActions.length > 0 ? (expanded ? 142 : 108) : (expanded ? 116 : 82)
            radius: 8
            color: Theme.surface
            Behavior on height { NumberAnimation { duration: Theme.animationFast } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5
                RowLayout {
                    Layout.fillWidth: true
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
                    }
                    Text {
                        visible: String(modelData.body || "").length > 80
                        text: expanded ? "󰅃" : "󰅀"
                        color: Theme.muted
                        font.family: Theme.iconFamily
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: expanded = !expanded }
                    }
                    Text {
                        text: "󰅖"
                        color: Theme.muted
                        font.family: Theme.iconFamily
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.dismiss() }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: modelData.body || ""
                    color: Theme.muted
                    textFormat: Text.PlainText
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    maximumLineCount: expanded ? 5 : 2
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: notificationActions.length > 0
                    spacing: 6
                    Repeater {
                        model: notificationActions
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 25
                            radius: 6
                            color: actionArea.containsMouse ? Theme.current : Theme.elevated
                            border.color: Theme.borderActive
                            Text {
                                anchors.centerIn: parent
                                text: modelData.text || "Abrir"
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                elide: Text.ElideRight
                            }
                            MouseArea {
                                id: actionArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.invoke()
                            }
                        }
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
