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
    property int candidateIndex: 0
    readonly property string iconHome: "file://" + Quickshell.env("HOME") + "/.local/share/icons/Papirus-Dark/"
    readonly property bool directSource: name.startsWith("/") || name.startsWith("file:")
    readonly property string themedName: directSource ? name : name.replace(/\.(svg|png|xpm)$/i, "")
    readonly property var candidates: {
        if (!name.length)
            return []
        if (directSource)
            return [name.startsWith("file:") ? name : "file://" + name]

        const result = []
        const categories = category.length
            ? [category]
            : ["apps", "actions", "devices", "status", "places", "mimetypes"]
        const sizes = ["24x24", "22x22", "16x16", "32x32", "48x48", "64x64", "scalable"]
        for (let s = 0; s < sizes.length; ++s) {
            for (let c = 0; c < categories.length; ++c) {
                if (categories.indexOf(categories[c]) !== c)
                    continue
                result.push(iconHome + sizes[s] + "/" + categories[c] + "/" + themedName + ".svg")
                result.push(iconHome + sizes[s] + "/" + categories[c] + "/" + themedName + ".png")
            }
        }
        const themed = Quickshell.iconPath(themedName, true)
        if (themed && themed.length)
            result.push(themed)
        return result
    }

    implicitWidth: size
    implicitHeight: size

    Image {
        id: themedIcon
        anchors.fill: parent
        visible: status === Image.Ready
        source: root.candidateIndex < root.candidates.length ? root.candidates[root.candidateIndex] : ""
        sourceSize.width: Math.ceil(root.size)
        sourceSize.height: Math.ceil(root.size)
        fillMode: Image.PreserveAspectFit
        smooth: root.smooth
        asynchronous: true
        onStatusChanged: {
            if (status === Image.Error && root.candidateIndex + 1 < root.candidates.length)
                root.candidateIndex++
        }
    }

    onNameChanged: candidateIndex = 0
    onCategoryChanged: candidateIndex = 0

    Image {
        anchors.centerIn: parent
        width: root.size
        height: root.size
        visible: !themedIcon.visible
        source: root.iconHome + "24x24/actions/application-menu.svg"
        sourceSize.width: Math.ceil(root.size)
        sourceSize.height: Math.ceil(root.size)
        fillMode: Image.PreserveAspectFit
        smooth: root.smooth
    }
}
