import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

Item {
    id: root
    property bool open: false
    property var targetScreen: null
    function closePanel() { open = false; PanelCoordinator.close("settings") }
    function showPanel(screen) { if (screen) targetScreen = screen; PanelCoordinator.request("settings"); open = true }
    function toggle(screen) { if (open) closePanel(); else showPanel(screen) }
    IpcHandler { target: "settings"; function toggle(): void { root.toggle() }; function show(): void { root.showPanel(null) }; function hide(): void { root.closePanel() } }
    Process { id: command }
    PanelWindow {
        screen: root.targetScreen; visible: root.open
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0; color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        MouseArea { anchors.fill: parent; onClicked: root.closePanel() }
        Surface {
            id: panelSurface; focus: root.open
            Keys.onEscapePressed: event => { root.closePanel(); event.accepted = true }
            width: 440; height: 470; anchors.top: parent.top; anchors.right: parent.right; anchors.topMargin: Theme.barPanelTopMargin; anchors.rightMargin: 10
            MouseArea { anchors.fill: parent }
            ColumnLayout {
                anchors.fill: parent; anchors.margins: Theme.spacingXl; spacing: Theme.spacingMd
                SectionTitle { Layout.fillWidth: true; iconName: "settings"; iconCategory: "apps"; title: "Orion Shell"; subtitle: "Personalización y herramientas"; accent: Theme.purple }
                GridLayout {
                    Layout.fillWidth: true; columns: 2; columnSpacing: Theme.spacingSm; rowSpacing: Theme.spacingSm
                    ActionTile { iconName: "palette"; title: "Tema"; subtitle: "Dracula"; accent: Theme.purple; commandLine: "notify-send Orion 'Dracula es el tema activo'" }
                    ActionTile { iconName: "wallpaper"; title: "Fondo"; subtitle: "Cambiar imagen"; accent: Theme.pink; commandLine: "bash ~/.config/hypr/scripts/wallpaper-menu.sh" }
                    ActionTile { iconName: "desktop_windows"; title: "Pantallas"; subtitle: "KScreen"; accent: Theme.cyan; commandLine: "systemsettings kcm_kscreen" }
                    ActionTile { iconName: "wifi"; title: "Red"; subtitle: "NetworkManager"; accent: Theme.green; commandLine: "nm-connection-editor" }
                    ActionTile { iconName: "bluetooth"; title: "Bluetooth"; subtitle: "Blueman"; accent: Theme.cyan; commandLine: "blueman-manager" }
                    ActionTile { iconName: "volume_up"; title: "Audio"; subtitle: "PipeWire"; accent: Theme.orange; commandLine: "pavucontrol" }
                    ActionTile { iconName: "settings"; title: "Sistema"; subtitle: "Plasma Settings"; accent: Theme.purple; commandLine: "systemsettings" }
                    ActionTile { iconName: "refresh"; title: "Recargar"; subtitle: "Orion Shell"; accent: Theme.green; commandLine: "~/.config/hypr/scripts/orionctl reload" }
                }
                Card {
                    Layout.fillWidth: true; Layout.preferredHeight: 92
                    ColumnLayout { anchors.fill: parent; spacing: Theme.spacingSm
                        Text { text: "Diseño actual"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeBody; font.weight: Font.DemiBold }
                        Text { Layout.fillWidth: true; text: "Dracula · paneles 22 px · tarjetas 12 px · animaciones 140–320 ms"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; wrapMode: Text.Wrap }
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }
    }
    Connections { target: PanelCoordinator; function onActivePanelChanged() { if (root.open && PanelCoordinator.activePanel !== "settings") root.closePanel() } }
    component ActionTile: Rectangle {
        id: tile
        property string iconName: "settings"
        property string title: ""
        property string subtitle: ""
        property color accent: Theme.purple
        property string commandLine: ""
        Layout.fillWidth: true; Layout.preferredHeight: 68; radius: Theme.cardRadius
        color: area.containsMouse ? Theme.current : Theme.surface
        border.width: 0
        RowLayout {
            anchors.fill: parent; anchors.margins: Theme.spacingMd; spacing: Theme.spacingSm
            OrionIcon { materialName: tile.iconName; fallbackColor: tile.accent; size: 20 }
            ColumnLayout { Layout.fillWidth: true; spacing: 1; Text { text: tile.title; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeBody; font.weight: Font.Medium }; Text { text: tile.subtitle; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall } }
        }
        MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { command.command = ["bash", "-lc", tile.commandLine]; command.running = true; root.closePanel() } }
    }
}
