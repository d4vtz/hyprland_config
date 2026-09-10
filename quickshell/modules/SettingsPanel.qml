import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../components"

Item {
    id: root

    property bool open: false

    function toggle() { open = !open }

    IpcHandler {
        target: "settings"
        function toggle(): void { root.toggle() }
        function show(): void { root.open = true }
        function hide(): void { root.open = false }
    }

    Process { id: command }

    PanelWindow {
        visible: root.open
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { anchors.fill: parent; onClicked: root.open = false }

        Surface {
            width: 440
            height: 470
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 54
            anchors.rightMargin: 10

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingLg
                spacing: Theme.spacingMd

                SectionTitle {
                    Layout.fillWidth: true
                    icon: "󰒓"
                    title: "Orion Shell"
                    subtitle: "Personalización y herramientas"
                    accent: Theme.purple
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Theme.spacingSm
                    rowSpacing: Theme.spacingSm

                    ActionTile { icon: "󰏘"; title: "Tema"; subtitle: "Dracula"; accent: Theme.purple; commandLine: "bash ~/.config/hypr/scripts/theme-switch.sh dracula" }
                    ActionTile { icon: "󰸉"; title: "Fondo"; subtitle: "Cambiar imagen"; accent: Theme.pink; commandLine: "bash ~/.config/hypr/scripts/wallpaper-menu.sh" }
                    ActionTile { icon: "󰍹"; title: "Pantallas"; subtitle: "KScreen"; accent: Theme.cyan; commandLine: "systemsettings kcm_kscreen" }
                    ActionTile { icon: "󰖩"; title: "Red"; subtitle: "NetworkManager"; accent: Theme.green; commandLine: "nm-connection-editor" }
                    ActionTile { icon: "󰂯"; title: "Bluetooth"; subtitle: "Blueman"; accent: Theme.cyan; commandLine: "blueman-manager" }
                    ActionTile { icon: "󰓃"; title: "Audio"; subtitle: "PipeWire"; accent: Theme.orange; commandLine: "pavucontrol" }
                    ActionTile { icon: "󰒓"; title: "Sistema"; subtitle: "Plasma Settings"; accent: Theme.purple; commandLine: "systemsettings" }
                    ActionTile { icon: "󰑐"; title: "Recargar"; subtitle: "Orion Shell"; accent: Theme.green; commandLine: "qs kill; uwsm app -- qs" }
                }

                Card {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 92
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Theme.spacingSm
                        Text {
                            text: "Diseño actual"
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            font.weight: Font.DemiBold
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "Dracula · paneles 22 px · tarjetas 12 px · animaciones 140–320 ms"
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.Wrap
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        Shortcut { sequence: "Esc"; onActivated: root.open = false }
    }

    component ActionTile: Rectangle {
        id: tile
        property string icon: ""
        property string title: ""
        property string subtitle: ""
        property color accent: Theme.purple
        property string commandLine: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 68
        radius: Theme.cardRadius
        color: area.containsMouse ? Theme.current : Theme.surface
        border.width: 1
        border.color: area.containsMouse ? tile.accent : Theme.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingMd
            spacing: Theme.spacingSm
            Text { text: tile.icon; color: tile.accent; font.family: Theme.iconFamily; font.pixelSize: 18 }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text { text: tile.title; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeBody; font.weight: Font.Medium }
                Text { text: tile.subtitle; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                command.command = ["bash", "-lc", tile.commandLine]
                command.running = true
                root.open = false
            }
        }
    }
}
