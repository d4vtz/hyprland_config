import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root

    default property alias content: content.data
    property bool active: false
    property bool tonal: true

    implicitWidth: content.implicitWidth + 24
    implicitHeight: Theme.pillHeight
    radius: Theme.pillRadius
    color: active
        ? Theme.primaryContainer
        : tonal ? Theme.surfaceContainer : "transparent"
    border.width: 0

    Behavior on color {
        ColorAnimation { duration: Theme.animationFast }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.animationNormal
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: Theme.spacingSm
    }
}
