import QtQuick
import ".."

Rectangle {
    id: root

    property bool elevated: false
    property int padding: Theme.spacingLg

    radius: Theme.panelRadius
    color: elevated ? Theme.elevated : Theme.background
    border.color: Theme.border
    border.width: 1
}
