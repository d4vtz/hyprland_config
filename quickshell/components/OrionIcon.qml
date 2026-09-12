import QtQuick
import Quickshell
import ".."

Item {
    id: root

    property string name: ""
    property string category: ""
    property string fallback: ""
    property string fallbackName: "image-missing"
    property real size: 18
    property color fallbackColor: Theme.foreground
    property bool smooth: true
    property bool localFailed: false
    readonly property string localSource: category.length > 0 && name.length > 0
        ? "file://" + Quickshell.env("HOME") + "/.local/share/icons/Papirus-Dark/24x24/" + category + "/" + name + ".svg"
        : ""

    implicitWidth: size
    implicitHeight: size

    Image {
        id: themedIcon
        anchors.fill: parent
        visible: status === Image.Ready || status === Image.Loading
        source: !root.localFailed && root.localSource.length > 0
            ? root.localSource
            : root.name.length > 0 ? Quickshell.iconPath(root.name, true) : ""
        sourceSize.width: Math.ceil(root.size)
        sourceSize.height: Math.ceil(root.size)
        fillMode: Image.PreserveAspectFit
        smooth: root.smooth
        asynchronous: true
        onStatusChanged: {
            if (status === Image.Error && !root.localFailed && root.localSource.length > 0)
                root.localFailed = true
        }
    }

    onNameChanged: localFailed = false
    onCategoryChanged: localFailed = false

    Image {
        anchors.centerIn: parent
        width: root.size
        height: root.size
        visible: !themedIcon.visible
        source: Quickshell.iconPath(root.fallbackName, true)
        sourceSize.width: Math.ceil(root.size)
        sourceSize.height: Math.ceil(root.size)
        fillMode: Image.PreserveAspectFit
        smooth: root.smooth
    }
}
