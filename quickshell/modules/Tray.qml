import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import ".."
import "../components"

Pill {
    id: root

    RowLayout {
        spacing: 8

        Repeater {
            model: SystemTray.items
            delegate: Image {
                required property var modelData
                source: modelData.icon
                sourceSize.width: 18
                sourceSize.height: 18
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.activate()
                }
            }
        }
    }
}
