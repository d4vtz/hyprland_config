import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property color accent: Theme.purple
    signal clicked()

    implicitHeight: 64
    radius: Theme.cardRadius
    color: checked ? Qt.alpha(accent, 0.18) : Theme.surface
    border.width: 1
    border.color: checked ? accent : Theme.border

    Behavior on color { ColorAnimation { duration: Theme.animationFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.animationFast } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 11
            color: checked ? accent : Theme.elevated

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: checked ? Theme.background : root.accent
                font.family: Theme.iconFamily
                font.pixelSize: 18
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.title
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBody
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Text {
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
