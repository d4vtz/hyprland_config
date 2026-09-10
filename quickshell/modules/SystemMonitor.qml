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
    property int tab: 0
    property var processes: []

    function toggle() {
        open = !open
        if (open) {
            SystemStatus.refresh()
            processList.running = true
        }
    }

    IpcHandler {
        target: "monitor"
        function toggle(): void { root.toggle() }
        function show(): void { root.open = true; SystemStatus.refresh(); processList.running = true }
        function hide(): void { root.open = false }
    }

    Process {
        id: processList
        command: ["bash", "-lc", "ps -eo pid=,comm=,%cpu=,%mem= --sort=-%cpu | head -n 16"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.processes = text.split("\n").filter(line => line.trim().length > 0).map(line => {
                    const m = line.trim().match(/^(\d+)\s+(\S+)\s+([0-9.]+)\s+([0-9.]+)/)
                    return m ? { pid: m[1], name: m[2], cpu: m[3], mem: m[4] } : null
                }).filter(x => x !== null)
            }
        }
    }

    Timer {
        interval: 3000
        repeat: true
        running: root.open
        onTriggered: {
            SystemStatus.refresh()
            processList.running = true
        }
    }

    PanelWindow {
        visible: root.open
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { anchors.fill: parent; onClicked: root.open = false }

        Surface {
            width: 690
            height: 520
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 70

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingXl
                spacing: Theme.spacingMd

                RowLayout {
                    Layout.fillWidth: true
                    SectionTitle {
                        Layout.fillWidth: true
                        icon: "󰍛"
                        title: "Monitor del sistema"
                        subtitle: SystemStatus.hostName
                        accent: Theme.green
                    }
                    Rectangle {
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 32
                        radius: Theme.cardRadius
                        color: root.tab === 0 ? Theme.current : Theme.surface
                        Text { anchors.centerIn: parent; text: "Rendimiento"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.tab = 0 }
                    }
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 32
                        radius: Theme.cardRadius
                        color: root.tab === 1 ? Theme.current : Theme.surface
                        Text { anchors.centerIn: parent; text: "Procesos"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.tab = 1 }
                    }
                }

                GridLayout {
                    visible: root.tab === 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 2
                    columnSpacing: Theme.spacingMd
                    rowSpacing: Theme.spacingMd

                    MetricCard {
                        title: "CPU"
                        icon: "󰍛"
                        accent: Theme.purple
                        value: Math.min(1, SystemStatus.cpuUsage / 100)
                        primary: Math.round(SystemStatus.cpuUsage) + "%"
                        detail: (SystemStatus.cpuTemperature > 0 ? Math.round(SystemStatus.cpuTemperature) + "°C · " : "") + SystemStatus.cpuFrequency.toFixed(1) + " GHz"
                    }
                    MetricCard {
                        title: "GPU Intel"
                        icon: "󰢮"
                        accent: Theme.pink
                        value: Math.min(1, SystemStatus.gpuUsage / 100)
                        primary: Math.round(SystemStatus.gpuUsage) + "%"
                        detail: (SystemStatus.gpuTemperature > 0 ? Math.round(SystemStatus.gpuTemperature) + "°C · " : "") + (SystemStatus.gpuFrequency > 0 ? Math.round(SystemStatus.gpuFrequency) + " MHz" : "reposo")
                    }
                    MetricCard {
                        title: "Memoria"
                        icon: "󰘚"
                        accent: Theme.cyan
                        value: SystemStatus.memoryUsage
                        primary: Math.round(SystemStatus.memoryUsage * 100) + "%"
                        detail: SystemStatus.memoryText
                    }
                    MetricCard {
                        title: "Disco /"
                        icon: "󰋊"
                        accent: Theme.orange
                        value: SystemStatus.diskUsage
                        primary: Math.round(SystemStatus.diskUsage * 100) + "%"
                        detail: SystemStatus.diskText
                    }
                }

                ColumnLayout {
                    visible: root.tab === 1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text { Layout.fillWidth: true; text: "Proceso"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        Text { Layout.preferredWidth: 70; text: "CPU"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; horizontalAlignment: Text.AlignRight }
                        Text { Layout.preferredWidth: 70; text: "RAM"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; horizontalAlignment: Text.AlignRight }
                        Text { Layout.preferredWidth: 60; text: "PID"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; horizontalAlignment: Text.AlignRight }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4
                        clip: true
                        model: root.processes

                        delegate: Rectangle {
                            required property var modelData
                            width: ListView.view.width
                            height: 32
                            radius: 8
                            color: index % 2 === 0 ? Theme.surface : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingSm
                                anchors.rightMargin: Theme.spacingSm
                                Text { Layout.fillWidth: true; text: modelData.name; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; elide: Text.ElideRight }
                                Text { Layout.preferredWidth: 70; text: modelData.cpu + "%"; color: Theme.purple; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; horizontalAlignment: Text.AlignRight }
                                Text { Layout.preferredWidth: 70; text: modelData.mem + "%"; color: Theme.cyan; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; horizontalAlignment: Text.AlignRight }
                                Text { Layout.preferredWidth: 60; text: modelData.pid; color: Theme.subtle; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; horizontalAlignment: Text.AlignRight }
                            }
                        }
                    }
                }
            }
        }

        Shortcut { sequence: "Esc"; onActivated: root.open = false }
    }

    component MetricCard: Card {
        id: metric
        property string title: ""
        property string icon: ""
        property color accent: Theme.purple
        property real value: 0
        property string primary: ""
        property string detail: ""

        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.spacingMd

            RowLayout {
                Layout.fillWidth: true
                Text { text: metric.icon; color: metric.accent; font.family: Theme.iconFamily; font.pixelSize: 19 }
                Text { text: metric.title; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeTitle; font.weight: Font.DemiBold }
                Item { Layout.fillWidth: true }
                Text { text: metric.primary; color: metric.accent; font.family: Theme.fontFamily; font.pixelSize: 26; font.weight: Font.DemiBold }
            }

            Item { Layout.fillHeight: true }

            Text { text: metric.detail; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeBody }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 7
                radius: 4
                color: Theme.current
                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, metric.value))
                    height: parent.height
                    radius: parent.radius
                    color: metric.accent
                    Behavior on width { NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutCubic } }
                }
            }
        }
    }
}
