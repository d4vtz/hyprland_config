import QtQuick
import QtQuick.Layouts
import "../.."

RowLayout {
    id: root
    required property var controller
    Layout.fillWidth: true; spacing: Theme.spacingSm
    FooterButton { icon: "󰍹"; label: "Pantalla"; accent: Theme.cyan; command: ["systemsettings", "kcm_kscreen"] }
    FooterButton { icon: "󰒓"; label: "Ajustes"; accent: Theme.purple; command: ["systemsettings"] }
    component FooterButton: Rectangle {
        required property string icon; required property string label; required property color accent; required property var command
        Layout.fillWidth: true; Layout.preferredHeight: 38; radius: Theme.cardRadius; color: Theme.surface
        Row { anchors.centerIn: parent; spacing: 7; Text { text: icon; color: accent; font.family: Theme.iconFamily } Text { text: label; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall } }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: controller.launchExternal(command) }
    }
}
