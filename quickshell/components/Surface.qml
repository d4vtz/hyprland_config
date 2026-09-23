import QtQuick
import ".."

Rectangle {
    id: root

    property bool elevated: false
    property bool outlined: false
    property int padding: Theme.spacingLg

    radius: Theme.panelRadius
    color: elevated ? Theme.elevated : Theme.background
    border.color: outlined ? Theme.border : "transparent"
    border.width: outlined ? 1 : 0

    Behavior on color {
        ColorAnimation { duration: Theme.animationNormal }
    }
}
