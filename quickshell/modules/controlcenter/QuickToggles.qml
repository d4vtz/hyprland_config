import QtQuick
import QtQuick.Layouts
import "../.."
import "../../components"
import "../../services"

Card {
    id: root
    required property var controller
    Layout.fillWidth: true; Layout.preferredHeight: 54
    RowLayout {
        anchors.fill: parent; spacing: Theme.spacingSm
        Action { icon: "󰅶"; label: "Cafeína"; active: CaffeineService.active; accent: Theme.yellow; onClicked: CaffeineService.toggle() }
        Action { icon: "󰂛"; label: "No molestar"; active: NotificationService.doNotDisturb; accent: Theme.red; onClicked: NotificationService.doNotDisturb = !NotificationService.doNotDisturb }
        Action { icon: "󰌾"; label: "Bloquear"; accent: Theme.cyan; onClicked: { controller.runCommand(["loginctl", "lock-session"], "Bloqueando…"); controller.closePanel() } }
        Action { icon: "󰀝"; label: "Avión"; active: !SystemStatus.wifiEnabled && !SystemStatus.bluetoothEnabled; accent: Theme.purple; onClicked: controller.runCommand(["bash", "-c", active ? "nmcli radio wifi on; bluetoothctl power on" : "nmcli radio wifi off; bluetoothctl power off"], "Cambiando modo avión…") }
    }
    component Action: Rectangle {
        id: action
        property string icon: ""; property string label: ""; property bool active: false; property color accent: Theme.purple
        signal clicked()
        Layout.fillWidth: true; Layout.fillHeight: true; radius: Theme.cardRadius
        color: active ? Qt.rgba(accent.r, accent.g, accent.b, 0.18) : Theme.surface
        Row { anchors.centerIn: parent; spacing: 5; Text { text: action.icon; color: action.accent; font.family: Theme.iconFamily; font.pixelSize: 14 } Text { text: action.label; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 9 } }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: action.clicked() }
    }
}
