import QtQuick
import QtQuick.Layouts
import "../.."
import "../../components"
import "../../services"

GridLayout {
    id: root
    required property var controller
    Layout.fillWidth: true
    columns: 2
    columnSpacing: Theme.spacingSm
    rowSpacing: Theme.spacingSm

    ToggleTile { Layout.fillWidth: true; iconName: SystemStatus.wifiEnabled ? "network-wireless" : "network-wireless-offline"; iconCategory: "devices"; icon: "󰖩"; title: "Wi-Fi"; subtitle: SystemStatus.wifiEnabled ? SystemStatus.network : "Desactivado"; checked: SystemStatus.wifiEnabled; interactive: !controller.busy; actionIconName: "network-wireless-configure"; actionIconCategory: "actions"; actionIcon: "󰍹"; accent: Theme.cyan; onClicked: controller.runCommand(["nmcli", "radio", "wifi", SystemStatus.wifiEnabled ? "off" : "on"], "Cambiando Wi-Fi…"); onActionClicked: controller.launchExternal(["nm-connection-editor"]) }
    ToggleTile { Layout.fillWidth: true; iconName: "bluetooth"; iconCategory: "devices"; icon: "󰂯"; title: "Bluetooth"; subtitle: SystemStatus.bluetoothEnabled ? (SystemStatus.bluetoothAudioActive ? "Audio conectado" : "Activado") : "Desactivado"; checked: SystemStatus.bluetoothEnabled; interactive: !controller.busy; rightClickAction: true; accent: Theme.purple; onClicked: controller.runCommand(["bash", "-c", SystemStatus.bluetoothEnabled ? "bluetoothctl power off" : "rfkill unblock bluetooth && for i in {1..20}; do bluetoothctl show >/dev/null 2>&1 && break; sleep 0.1; done; bluetoothctl power on"], "Cambiando Bluetooth…"); onActionClicked: controller.launchExternal(["blueman-manager"]) }
    ToggleTile { Layout.fillWidth: true; iconName: "redshift-status-on"; iconCategory: "status"; icon: "󰖔"; title: "Luz nocturna"; subtitle: SystemStatus.nightLightEnabled ? "Activa" : "Desactivada"; checked: SystemStatus.nightLightEnabled; accent: Theme.orange; onClicked: controller.runCommand(["bash", controller.homePath + "/.config/hypr/scripts/night-light-menu.sh"], "Configurando luz nocturna…") }
    ToggleTile { Layout.fillWidth: true; iconName: SystemStatus.batteryState === "Cargando" ? "battery-charging" : "battery"; iconCategory: "devices"; icon: "󰁹"; title: "Batería"; subtitle: SystemStatus.battery === "CA" ? "Alimentación externa" : SystemStatus.battery + "% · salud " + SystemStatus.batteryHealth + "% · " + SystemStatus.batteryTime; checked: SystemStatus.acConnected; interactive: false; accent: Theme.green; onClicked: {} }
}
