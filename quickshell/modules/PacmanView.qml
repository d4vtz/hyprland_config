import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

ColumnLayout {
    id: root
    property var updates: []
    property var news: []
    spacing: 10

    function refresh() {
        updatesProcess.running = true
        newsProcess.running = true
    }

    Component.onCompleted: refresh()

    Process {
        id: updatesProcess
        command: ["bash", "-c", "{ checkupdates 2>/dev/null || true; paru -Qua 2>/dev/null || true; } | sort -u"]
        stdout: StdioCollector {
            onStreamFinished: root.updates = text.trim() ? text.trim().split("\n") : []
        }
    }
    Process {
        id: newsProcess
        command: ["bash", "-c", "curl -m 6 -fsSL https://archlinux.org/feeds/news/ 2>/dev/null | sed -n 's:.*<title>\\(.*\\)</title>.*:\\1:p' | sed '1d' | head -n 3"]
        stdout: StdioCollector {
            onStreamFinished: root.news = text.trim() ? text.trim().split("\n") : []
        }
    }
    Process { id: terminalProcess }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 92
        radius: 10
        color: Theme.surface
        border.color: root.updates.length > 0 ? Theme.orange : Theme.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 13
            Rectangle {
                width: 50
                height: 50
                radius: 25
                color: root.updates.length > 0 ? Theme.orange : Theme.green
                Text {
                    anchors.centerIn: parent
                    text: root.updates.length
                    color: Theme.background
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Text {
                    text: root.updates.length > 0 ? "Actualizaciones disponibles" : "Sistema actualizado"
                    color: root.updates.length > 0 ? Theme.orange : Theme.green
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                }
                Text {
                    text: root.updates.length + (root.updates.length === 1 ? " paquete pendiente" : " paquetes pendientes")
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }
            }
            Text {
                text: "󰑐"
                color: Theme.cyan
                font.family: Theme.iconFamily
                font.pixelSize: 18
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.refresh() }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        ActionButton {
            Layout.fillWidth: true
            label: "Actualizar sistema"
            icon: "󰚰"
            accent: Theme.purple
            onClicked: {
                terminalProcess.command = ["kitty", "--title", "Actualización del sistema", "-e", "bash", "-lc",
                    "paru; printf '\\nPulsa Enter para cerrar...'; read -r"]
                terminalProcess.running = true
            }
        }
        ActionButton {
            Layout.preferredWidth: 120
            label: "Ver lista"
            icon: "󰈙"
            accent: Theme.cyan
            onClicked: {
                terminalProcess.command = ["kitty", "--title", "Paquetes pendientes", "-e", "bash", "-lc",
                    "{ checkupdates 2>/dev/null || true; paru -Qua 2>/dev/null || true; } | sort -u; printf '\\nPulsa Enter para cerrar...'; read -r"]
                terminalProcess.running = true
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Text { text: "Noticias de Arch Linux"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }
        Item { Layout.fillWidth: true }
        Text { text: "archlinux.org"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 8 }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6
        Repeater {
            model: root.news
            delegate: Rectangle {
                required property string modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: 8
                color: Theme.surface
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "󰋼"; color: Theme.orange; font.family: Theme.iconFamily; font.pixelSize: 15 }
                    Text {
                        Layout.fillWidth: true
                        text: modelData.replace(/&amp;/g, "&").replace(/&#8217;/g, "’")
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }
            }
        }
        Text {
            visible: root.news.length === 0
            text: "No se pudieron consultar las noticias."
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 10
        }
    }

    Item { Layout.fillHeight: true }

    component ActionButton: Rectangle {
        id: button
        property string label: ""
        property string icon: ""
        property color accent: Theme.purple
        signal clicked()
        Layout.preferredHeight: 42
        radius: 9
        color: area.containsMouse ? Theme.current : Theme.elevated
        border.color: button.accent
        RowLayout {
            anchors.centerIn: parent
            spacing: 7
            Text { text: button.icon; color: button.accent; font.family: Theme.iconFamily; font.pixelSize: 16 }
            Text { text: button.label; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true }
        }
        MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: button.clicked() }
    }
}
