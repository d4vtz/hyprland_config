import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    default property alias content: content.data
    property bool active: false

    implicitWidth: content.implicitWidth + 20
    implicitHeight: 32
    radius: Theme.radius
    color: active ? Theme.current : Theme.surface
    border.color: active ? Theme.purple : "#66557d"
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animationFast } }
    Behavior on implicitWidth { NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutCubic } }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 8
    }
}

