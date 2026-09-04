import QtQuick
import QtQuick.Layouts
import ".."

RowLayout {
    id: root

    property string icon: ""
    property real value: 0
    property color accent: Theme.purple
    signal valueRequested(real value)

    spacing: 10

    Text {
        Layout.preferredWidth: 20
        horizontalAlignment: Text.AlignHCenter
        text: root.icon
        color: root.accent
        font.family: Theme.iconFamily
        font.pixelSize: 15
    }

    Rectangle {
        id: track
        Layout.fillWidth: true
        Layout.preferredHeight: 6
        radius: 3
        color: Theme.current

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: parent.radius
            color: root.accent
        }

        Rectangle {
            x: Math.max(0, Math.min(parent.width - width, parent.width * root.value - width / 2))
            anchors.verticalCenter: parent.verticalCenter
            width: 12
            height: 12
            radius: 6
            color: Theme.foreground
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => root.valueRequested(Math.max(0, Math.min(1, mouse.x / width)))
            onPositionChanged: mouse => {
                if (pressed)
                    root.valueRequested(Math.max(0, Math.min(1, mouse.x / width)))
            }
        }
    }
}
