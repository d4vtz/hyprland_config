import QtQuick
import QtQuick.Layouts
import "../.."
import "../../components"
import "../../services"

Card {
    id: root
    required property var controller
    Layout.fillWidth: true; Layout.preferredHeight: 92
    ColumnLayout {
        anchors.fill: parent; spacing: Theme.spacingSm
        Text { text: "Perfil de energía"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
        RowLayout {
            Layout.fillWidth: true; spacing: Theme.spacingSm
            Repeater {
                model: [{ id: "performance", label: "Rendimiento" }, { id: "balanced", label: "Equilibrado" }, { id: "power-saver", label: "Ahorro" }]
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool available: SystemStatus.powerProfiles.split(",").indexOf(modelData.id) >= 0
                    Layout.fillWidth: true; Layout.preferredHeight: 36; radius: Theme.cardRadius
                    color: SystemStatus.powerProfile === modelData.id ? Theme.purple : Theme.elevated
                    opacity: available ? 1 : 0.35
                    Text { anchors.centerIn: parent; text: modelData.label; color: SystemStatus.powerProfile === modelData.id ? Theme.canvas : Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                    MouseArea { anchors.fill: parent; enabled: parent.available && !controller.busy; cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor; onClicked: controller.setPowerProfile(modelData.id) }
                }
            }
        }
    }
}
