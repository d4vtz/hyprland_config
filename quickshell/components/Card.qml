import QtQuick
import ".."

Rectangle {
    id: root

    default property alias content: content.data
    property bool interactive: false
    property bool active: false
    property color accent: Theme.primary
    signal clicked()

    implicitHeight: content.implicitHeight + Theme.spacingLg * 2
    radius: Theme.cardRadius
    color: active
        ? Theme.primaryContainer
        : mouse.containsMouse && interactive ? Theme.surfaceHover : Theme.surfaceContainer
    border.width: 0

    Behavior on color {
        ColorAnimation { duration: Theme.animationFast }
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacingLg
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
