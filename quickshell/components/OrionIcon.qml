import QtQuick
import Quickshell
import ".."

Item {
    id: root

    property string name: ""
    property string fallback: ""
    property real size: 18
    property color fallbackColor: Theme.foreground
    property bool smooth: true

    implicitWidth: size
    implicitHeight: size

    Image {
        id: themedIcon
        anchors.fill: parent
        visible: status === Image.Ready || status === Image.Loading
        source: root.name.length > 0 ? Quickshell.iconPath(root.name, true) : ""
        sourceSize.width: Math.ceil(root.size)
        sourceSize.height: Math.ceil(root.size)
        fillMode: Image.PreserveAspectFit
        smooth: root.smooth
        asynchronous: true
    }

    Text {
        anchors.centerIn: parent
        visible: !themedIcon.visible
        text: root.fallback
        color: root.fallbackColor
        font.family: Theme.iconFamily
        font.pixelSize: root.size
    }
}
