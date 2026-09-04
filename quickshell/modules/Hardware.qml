import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

Pill {
    id: root
    property bool expanded: false
    property int page: 0
    property int deviceMenu: 0 // 0 cerrado, 1 salidas, 2 entradas
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.audio !== null && n.isSink && !n.isStream)
    readonly property var sources: Pipewire.nodes.values.filter(n => n.audio !== null && !n.isSink && !n.isStream)
    readonly property int batteryValue: Number(SystemStatus.battery)

    function deviceName(node, input) {
        if (!node) return input ? "Sin entrada" : "Sin salida"
        const raw = String(node.description || node.nickname || node.name || "")
        const lower = raw.toLowerCase()
        if (lower.indexOf("bluetooth") >= 0 || lower.indexOf("bluez") >= 0)
            return raw.replace(/^.*[-:] /, "") || "Bluetooth"
        if (lower.indexOf("hdmi") >= 0 || lower.indexOf("displayport") >= 0)
            return "HDMI / DisplayPort"
        if (lower.indexOf("speaker") >= 0 || lower.indexOf("analog stereo") >= 0)
            return "Altavoces integrados"
        if (lower.indexOf("microphone") >= 0 || lower.indexOf("mic") >= 0)
            return "Micrófono integrado"
        return raw.replace(/Raptor Lake-P\/U\/H cAVS/gi, "").trim() || (input ? "Entrada de audio" : "Salida de audio")
    }

    function batteryIcon() {
        if (SystemStatus.battery === "CA") return "󰚥"
        if (SystemStatus.batteryState === "Cargando") return "󰂄"
        if (batteryValue < 15) return "󰁺"
        if (batteryValue < 40) return "󰁼"
        if (batteryValue < 70) return "󰁾"
        return "󰁹"
    }

    active: expanded
    PwObjectTracker { objects: [root.sink, root.source].concat(root.sinks).concat(root.sources) }

    RowLayout {
        spacing: 11
        Text {
            text: root.batteryIcon() + " " + SystemStatus.battery +
                  (SystemStatus.battery === "CA" ? "" : "%") +
                  (SystemStatus.acConnected && SystemStatus.batteryState !== "Cargando" ? " 󰚥" : "")
            color: root.batteryValue > 0 && root.batteryValue < 15 ? Theme.red :
                   SystemStatus.batteryState === "Cargando" ? Theme.green :
                   SystemStatus.acConnected ? Theme.yellow : Theme.orange
            font.family: Theme.iconFamily
            font.pixelSize: 14
        }
        Text {
            text: (root.sink && root.sink.audio.muted ? "󰝟 " : "󰕾 ") +
                  (root.sink ? Math.round(root.sink.audio.volume * 100) + "%" : "--")
            color: root.sink && root.sink.audio.muted ? Theme.muted : Theme.cyan
            font.family: Theme.iconFamily
            font.pixelSize: 14
        }
        Text {
            visible: root.source && !root.source.audio.muted
            text: "󰍬"
            color: Theme.red
            font.family: Theme.iconFamily
            font.pixelSize: 16
        }
        Text {
            visible: SystemStatus.bluetoothEnabled
            text: SystemStatus.bluetoothAudioActive ? "󰋋" : "󰂯"
            color: SystemStatus.bluetoothAudioActive ? Theme.green : Theme.cyan
            font.family: Theme.iconFamily
            font.pixelSize: 16
        }
    }

    MouseArea {
        parent: root
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
        onWheel: wheel => {
            if (root.sink)
                root.sink.audio.volume = Math.max(0, Math.min(1.5, root.sink.audio.volume + (wheel.angleDelta.y > 0 ? .05 : -.05)))
        }
    }

    Process { id: command; onExited: SystemStatus.refresh() }
    Process { id: settingsLauncher }
    Process {
        id: profileSetter
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim())
                    SystemStatus.powerProfile = text.trim()
                SystemStatus.refresh()
            }
        }
    }
    Process { id: brightnessSetter; onExited: SystemStatus.refresh() }

    PanelWindow {
        visible: root.expanded
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea {
            anchors.fill: parent
            onClicked: { root.deviceMenu = 0; root.expanded = false }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 2
            anchors.rightMargin: 102
            width: 390
            height: root.page === 0 ? (root.deviceMenu ? 540 : 445) : 545
            radius: Theme.radius + 2
            color: Theme.background
            border.color: Theme.border
            Behavior on height { NumberAnimation { duration: Theme.animationFast } }
            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Hardware"; color: Theme.foreground; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 15 }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        Layout.preferredWidth: 105; Layout.preferredHeight: 30; radius: 7
                        color: root.page === 0 ? Theme.elevated : "transparent"
                        Text { anchors.centerIn: parent; text: "Controles"; color: root.page === 0 ? Theme.purple : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 11 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.page = 0; root.deviceMenu = 0 } }
                    }
                    Rectangle {
                        Layout.preferredWidth: 105; Layout.preferredHeight: 30; radius: 7
                        color: root.page === 1 ? Theme.elevated : "transparent"
                        Text { anchors.centerIn: parent; text: "Sensores"; color: root.page === 1 ? Theme.purple : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 11 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.page = 1; root.deviceMenu = 0 } }
                    }
                }

                ColumnLayout {
                    visible: root.page === 0
                    Layout.fillWidth: true
                    spacing: 8

                    ControlRow {
                        icon: "󰃠"; value: SystemStatus.brightness; percent: Math.round(SystemStatus.brightness * 100) + "%"
                        accent: Theme.yellow
                        onValueRequested: value => {
                            SystemStatus.brightness = value
                            brightnessSetter.command = ["brightnessctl", "set", Math.round(value * 100) + "%"]
                            brightnessSetter.running = true
                        }
                    }
                    ControlRow {
                        icon: root.sink && root.sink.audio.muted ? "󰝟" : "󰕾"
                        value: root.sink ? Math.min(1, root.sink.audio.volume) : 0
                        percent: root.sink ? Math.round(root.sink.audio.volume * 100) + "%" : "--"
                        accent: Theme.cyan
                        onValueRequested: value => { if (root.sink) { root.sink.audio.muted = false; root.sink.audio.volume = value } }
                    }
                    DeviceSelector {
                        title: "Salida"; icon: "󰓃"; label: root.deviceName(root.sink, false)
                        accent: Theme.cyan
                        expanded: root.deviceMenu === 1; nodes: root.sinks; current: root.sink
                        onToggle: root.deviceMenu = root.deviceMenu === 1 ? 0 : 1
                        onSelected: node => { Pipewire.preferredDefaultAudioSink = node; root.deviceMenu = 0 }
                    }
                    ControlRow {
                        icon: root.source && root.source.audio.muted ? "󰍭" : "󰍬"
                        value: root.source ? Math.min(1, root.source.audio.volume) : 0
                        percent: root.source ? Math.round(root.source.audio.volume * 100) + "%" : "--"
                        alert: root.source && !root.source.audio.muted
                        onIconClicked: { if (root.source) root.source.audio.muted = !root.source.audio.muted }
                        onValueRequested: value => { if (root.source) root.source.audio.volume = value }
                    }
                    DeviceSelector {
                        title: "Entrada"; icon: "󰍬"; label: root.deviceName(root.source, true)
                        accent: Theme.pink
                        expanded: root.deviceMenu === 2; nodes: root.sources; current: root.source
                        onToggle: root.deviceMenu = root.deviceMenu === 2 ? 0 : 2
                        onSelected: node => { Pipewire.preferredDefaultAudioSource = node; root.deviceMenu = 0 }
                    }

                    Text { text: "Perfil de energía"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10 }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 6
                        Repeater {
                            model: [{id:"performance", label:"Rendimiento"}, {id:"balanced", label:"Equilibrado"}, {id:"power-saver", label:"Ahorro"}]
                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool available: SystemStatus.powerProfiles.indexOf(modelData.id) >= 0
                                Layout.fillWidth: true; Layout.preferredHeight: 34; radius: 8
                                color: SystemStatus.powerProfile === modelData.id ? Theme.purple : Theme.surface
                                opacity: available ? 1 : 0.38
                                Text { anchors.centerIn: parent; text: modelData.label; color: SystemStatus.powerProfile === modelData.id ? Theme.background : Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10 }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    enabled: parent.available
                                    onClicked: {
                                        profileSetter.command = ["bash", "-c", "powerprofilesctl set " + modelData.id + " && powerprofilesctl get"]
                                        profileSetter.running = true
                                    }
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    visible: root.page === 1
                    Layout.fillWidth: true
                    spacing: 8
                    SensorCard {
                        icon: "󰍛"; title: "CPU"
                        detail: Math.round(SystemStatus.cpuUsage) + "%  ·  " +
                                (SystemStatus.cpuTemperature > 0 ? Math.round(SystemStatus.cpuTemperature) + "°C  ·  " : "") +
                                SystemStatus.cpuFrequency.toFixed(1) + " GHz"
                        value: SystemStatus.cpuUsage / 100
                        critical: SystemStatus.cpuTemperature > 75
                    }
                    SensorCard {
                        icon: "󰢮"; title: "GPU Intel"
                        detail: Math.round(SystemStatus.gpuUsage) + "%  ·  " +
                                (SystemStatus.gpuTemperature > 0 ? Math.round(SystemStatus.gpuTemperature) + "°C  ·  " : "") +
                                (SystemStatus.gpuFrequency > 0 ? Math.round(SystemStatus.gpuFrequency) + " MHz" :
                                 SystemStatus.gpuUsage === 0 ? "En reposo" : "Frecuencia no disponible")
                        value: SystemStatus.gpuUsage / 100
                        critical: SystemStatus.gpuTemperature > 85
                    }
                    SensorCard {
                        icon: "󰘚"; title: "Memoria RAM"
                        detail: Math.round(SystemStatus.memoryUsage * 100) + "%  ·  " + SystemStatus.memoryText
                        value: SystemStatus.memoryUsage
                    }
                    SensorCard {
                        icon: "󰋊"; title: "Almacenamiento /"
                        detail: Math.round(SystemStatus.diskUsage * 100) + "%  ·  " + SystemStatus.diskText
                        value: SystemStatus.diskUsage
                    }
                    SensorCard {
                        icon: root.batteryIcon(); title: "Batería"
                        detail: SystemStatus.battery + (SystemStatus.battery === "CA" ? "" : "%") + "  ·  " + SystemStatus.batteryState + "  ·  " + SystemStatus.batteryTime
                        value: SystemStatus.battery === "CA" ? 0 : root.batteryValue / 100
                        critical: root.batteryValue > 0 && root.batteryValue < 15
                    }
                }

                Item { Layout.fillHeight: true }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.border }
                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    QuickToggle {
                        text: "Wi-Fi"; icon: "󰖩"; checked: SystemStatus.wifiEnabled; accent: Theme.cyan
                        onClicked: { settingsLauncher.command = ["nm-connection-editor"]; settingsLauncher.running = true; root.expanded = false }
                    }
                    QuickToggle {
                        text: "Bluetooth"; icon: "󰂯"; checked: SystemStatus.bluetoothEnabled; accent: Theme.purple
                        onClicked: { settingsLauncher.command = ["blueman-manager"]; settingsLauncher.running = true; root.expanded = false }
                    }
                    QuickToggle {
                        text: "Luz nocturna"; icon: "󰖔"; checked: SystemStatus.nightLightEnabled; accent: Theme.orange
                        onClicked: {
                            settingsLauncher.command = ["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/night-light-menu.sh"]
                            settingsLauncher.running = true
                            root.expanded = false
                        }
                    }
                }
            }
        }

        Shortcut { sequence: "Esc"; onActivated: { root.deviceMenu = 0; root.expanded = false } }
    }

    component ControlRow: Rectangle {
        id: controlRow
        property string icon: ""
        property real value: 0
        property string percent: "--"
        property bool alert: false
        property color accent: Theme.purple
        signal valueRequested(real value)
        signal iconClicked()
        Layout.fillWidth: true; Layout.preferredHeight: 52; radius: 8; color: Theme.surface
        RowLayout {
            anchors.fill: parent; anchors.margins: 11; spacing: 10
            Text {
                Layout.preferredWidth: 22; horizontalAlignment: Text.AlignHCenter
                text: controlRow.icon; color: controlRow.alert ? Theme.red : controlRow.accent
                font.family: Theme.iconFamily; font.pixelSize: 18
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: controlRow.iconClicked() }
            }
            Rectangle {
                id: track
                Layout.fillWidth: true; Layout.preferredHeight: 6; radius: 3; color: Theme.current
                Rectangle { width: parent.width * Math.max(0, Math.min(1, controlRow.value)); height: parent.height; radius: 3; color: controlRow.alert ? Theme.red : controlRow.accent }
                Rectangle { x: Math.max(0, Math.min(parent.width-width, parent.width*controlRow.value-width/2)); anchors.verticalCenter: parent.verticalCenter; width: 12; height: 12; radius: 6; color: Theme.foreground }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onPressed: mouse => controlRow.valueRequested(Math.max(0, Math.min(1, mouse.x/width)))
                    onPositionChanged: mouse => { if (pressed) controlRow.valueRequested(Math.max(0, Math.min(1, mouse.x/width))) }
                }
            }
            Text { Layout.preferredWidth: 39; horizontalAlignment: Text.AlignRight; text: controlRow.percent; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 11 }
        }
    }

    component DeviceSelector: ColumnLayout {
        id: selector
        property string title: ""
        property string icon: ""
        property string label: ""
        property bool expanded: false
        property var nodes: []
        property var current: null
        property color accent: Theme.purple
        signal toggle()
        signal selected(var node)
        Layout.fillWidth: true; spacing: 3
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 34; radius: 8; color: Theme.surface
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                Text { text: selector.icon; color: selector.accent; font.family: Theme.iconFamily; font.pixelSize: 16 }
                Text { text: selector.title; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10 }
                Text { Layout.fillWidth: true; text: selector.label; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10; horizontalAlignment: Text.AlignRight; elide: Text.ElideRight }
                Text { text: selector.expanded ? "󰅃" : "󰅀"; color: Theme.muted; font.family: Theme.iconFamily }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: selector.toggle() }
        }
        ColumnLayout {
            visible: selector.expanded; Layout.fillWidth: true; spacing: 3
            Repeater {
                model: selector.nodes
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true; Layout.preferredHeight: 28; radius: 6
                    color: modelData === selector.current ? Theme.elevated : "transparent"
                    Text { anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; verticalAlignment: Text.AlignVCenter; text: root.deviceName(modelData, selector.title === "Entrada"); color: modelData === selector.current ? Theme.purple : Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10; elide: Text.ElideRight }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: selector.selected(modelData) }
                }
            }
        }
    }

    component SensorCard: Rectangle {
        id: sensor
        property string icon: ""
        property string title: ""
        property string detail: ""
        property real value: 0
        property bool critical: false
        Layout.fillWidth: true; Layout.preferredHeight: 72; radius: 8; color: Theme.surface
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 11; spacing: 7
            RowLayout {
                Text { text: sensor.icon; color: sensor.critical ? Theme.red : Theme.purple; font.family: Theme.iconFamily; font.pixelSize: 15 }
                Text { text: sensor.title; color: Theme.foreground; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                Text { text: sensor.detail; color: sensor.critical ? Theme.red : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10 }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 5; radius: 3; color: Theme.current
                Rectangle { width: parent.width*Math.max(0,Math.min(1,sensor.value)); height: parent.height; radius: 3; color: sensor.critical ? Theme.red : Theme.purple }
            }
        }
    }

    component QuickToggle: Rectangle {
        id: toggle
        property string text: ""
        property string icon: ""
        property bool checked: false
        property color accent: Theme.purple
        signal clicked()
        Layout.fillWidth: true; Layout.preferredHeight: 38; radius: 8
        color: checked ? accent : Theme.surface
        RowLayout {
            anchors.centerIn: parent; spacing: 5
            Text { text: toggle.icon; color: toggle.checked ? Theme.background : toggle.accent; font.family: Theme.iconFamily; font.pixelSize: 16 }
            Text { text: toggle.text; color: toggle.checked ? Theme.background : Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 9 }
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: toggle.clicked() }
    }
}
