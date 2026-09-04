import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."
import "../components"

Pill {
    id: root
    readonly property var window: Hyprland.activeToplevel
    visible: window !== null
    implicitWidth: Math.min(260, contentRow.implicitWidth + 20)

    RowLayout {
        id: contentRow
        spacing: 8

        Text {
            text: "󰣆"
            color: Theme.cyan
            font.family: Theme.iconFamily
            font.pixelSize: 15
        }
        Text {
            Layout.maximumWidth: 205
            text: root.window ? (root.window.lastIpcObject["class"] || root.window.title || "Ventana") : ""
            color: Theme.muted
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }
    }
}
