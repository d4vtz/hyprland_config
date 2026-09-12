import QtQuick
import ".."

Rectangle {
    id: root

    default property alias content: content.data
    property bool interactive: false
    property bool active: false
    property color accent: Theme.purple
    signal clicked()

    implicitHeight: content.implicitHeight + Theme.spacingMd * 2
    radius: Theme.cardRadius
    color: active ? Theme.current : mouse.containsMouse && interactive ? Theme.surfaceHover : Theme.surface
    border.width: 1
    border.color: active ? accent : Theme.border

    Behavior on color {
        ColorAnimation { duration: Theme.animationFast }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.animationFast }
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: root.interactive
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
