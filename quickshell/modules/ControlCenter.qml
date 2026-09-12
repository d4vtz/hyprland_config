import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

Item {
    id: root

    property bool open: false
    property var targetScreen: null
    property int audioMenu: 0 // 0 ninguno, 1 salida, 2 entrada
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.audio !== null && n.isSink && !n.isStream)
    readonly property var sources: Pipewire.nodes.values.filter(n => n.audio !== null && !n.isSink && !n.isStream)

    function showPanel(screen) {
        if (screen) targetScreen = screen
        PanelCoordinator.request("controlcenter")
        open = true
        SystemStatus.refresh()
    }

    function toggle(screen) {
        if (!open && screen) targetScreen = screen
        if (!open) PanelCoordinator.request("controlcenter")
        open = !open
        if (open)
            SystemStatus.refresh()
        else
            audioMenu = 0
    }

    function adjustVolume(delta) {
        if (sink)
            sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + delta))
    }

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

    IpcHandler {
        target: "controlcenter"
        function toggle(): void { root.toggle() }
        function show(): void { root.showPanel(null) }
        function hide(): void { root.open = false; root.audioMenu = 0; PanelCoordinator.close("controlcenter") }
    }

    PwObjectTracker {
        objects: [root.sink, root.source].concat(root.sinks).concat(root.sources)
    }

    Process { id: command; onExited: SystemStatus.refresh() }
    Process { id: brightnessSetter; onExited: SystemStatus.refresh() }
    Process { id: profileSetter; onExited: SystemStatus.refresh() }

    PanelWindow {
        screen: root.targetScreen
        visible: root.open
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.audioMenu = 0
                root.open = false
            }
        }

        Surface {
            id: panelSurface
            focus: root.open
            Keys.onEscapePressed: event => {
                if (root.audioMenu !== 0) root.audioMenu = 0
                else { root.open = false; PanelCoordinator.close("controlcenter") }
                event.accepted = true
            }
            width: 430
            height: root.audioMenu === 0 ? 565 : 650
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 54
            anchors.rightMargin: 10

            Behavior on height {
                NumberAnimation { duration: Theme.animationFast; easing.type: Easing.OutCubic }
            }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingLg
                spacing: Theme.spacingMd

                SectionTitle {
                    Layout.fillWidth: true
                    icon: "󰒓"
                    title: "Centro de control"
                    subtitle: SystemStatus.userName + "@" + SystemStatus.hostName
                    accent: Theme.purple
                }

                Card {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 126

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Theme.spacingMd

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingMd
                            Text {
                                text: root.sink && root.sink.audio.muted ? "󰝟" : "󰕾"
                                color: root.sink && root.sink.audio.muted ? Theme.muted : Theme.cyan
                                font.family: Theme.iconFamily
                                font.pixelSize: 18
                            }
                            ValueSlider {
                                Layout.fillWidth: true
                                icon: ""
                                value: root.sink ? Math.min(1, root.sink.audio.volume) : 0
                                accent: Theme.cyan
                                onValueRequested: value => {
                                    if (root.sink) {
                                        root.sink.audio.muted = false
                                        root.sink.audio.volume = value
                                    }
                                }
                            }
                            Text {
                                Layout.preferredWidth: 38
                                horizontalAlignment: Text.AlignRight
                                text: root.sink ? Math.round(root.sink.audio.volume * 100) + "%" : "--"
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingMd
                            Text {
                                text: "󰃠"
                                color: Theme.yellow
                                font.family: Theme.iconFamily
                                font.pixelSize: 18
                            }
                            ValueSlider {
                                Layout.fillWidth: true
                                icon: ""
                                value: SystemStatus.brightness
                                accent: Theme.yellow
                                onValueRequested: value => {
                                    SystemStatus.brightness = value
                                    brightnessSetter.command = ["brightnessctl", "set", Math.round(value * 100) + "%"]
                                    brightnessSetter.running = true
                                }
                            }
                            Text {
                                Layout.preferredWidth: 38
                                horizontalAlignment: Text.AlignRight
                                text: Math.round(SystemStatus.brightness * 100) + "%"
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Theme.spacingSm
                    rowSpacing: Theme.spacingSm

                    ToggleTile {
                        Layout.fillWidth: true
                        icon: "󰖩"
                        title: "Wi-Fi"
                        subtitle: SystemStatus.wifiEnabled ? SystemStatus.network : "Desactivado"
                        checked: SystemStatus.wifiEnabled
                        accent: Theme.cyan
                        onClicked: {
                            command.command = ["nmcli", "radio", "wifi", SystemStatus.wifiEnabled ? "off" : "on"]
                            command.running = true
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        icon: "󰂯"
                        title: "Bluetooth"
                        subtitle: SystemStatus.bluetoothEnabled ? (SystemStatus.bluetoothAudioActive ? "Audio conectado" : "Activado") : "Desactivado"
                        checked: SystemStatus.bluetoothEnabled
                        accent: Theme.purple
                        onClicked: {
                            command.command = ["bluetoothctl", "power", SystemStatus.bluetoothEnabled ? "off" : "on"]
                            command.running = true
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        icon: "󰖔"
                        title: "Luz nocturna"
                        subtitle: SystemStatus.nightLightEnabled ? "Activa" : "Desactivada"
                        checked: SystemStatus.nightLightEnabled
                        accent: Theme.orange
                        onClicked: {
                            command.command = ["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/night-light-menu.sh"]
                            command.running = true
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        icon: "󰁹"
                        title: "Batería"
                        subtitle: SystemStatus.battery === "CA"
                                  ? "Alimentación externa"
                                  : SystemStatus.battery + "% · " + SystemStatus.batteryState
                        checked: SystemStatus.acConnected
                        accent: Theme.green
                        onClicked: {}
                    }
                }

                Card {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 92

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Theme.spacingSm

                        Text {
                            text: "Perfil de energía"
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingSm

                            Repeater {
                                model: [
                                    { id: "performance", label: "Rendimiento" },
                                    { id: "balanced", label: "Equilibrado" },
                                    { id: "power-saver", label: "Ahorro" }
                                ]

                                delegate: Rectangle {
                                    required property var modelData
                                    readonly property bool available: SystemStatus.powerProfiles.indexOf(modelData.id) >= 0

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    radius: Theme.cardRadius
                                    color: SystemStatus.powerProfile === modelData.id ? Theme.purple : Theme.elevated
                                    opacity: available ? 1 : 0.35

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        color: SystemStatus.powerProfile === modelData.id ? Theme.canvas : Theme.foreground
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: parent.available
                                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            profileSetter.command = ["powerprofilesctl", "set", modelData.id]
                                            profileSetter.running = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Card {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 104

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Theme.spacingSm

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "󰓃"
                                color: Theme.cyan
                                font.family: Theme.iconFamily
                                font.pixelSize: 16
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Salida · " + root.deviceName(root.sink, false)
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                            }
                            Text {
                                text: root.audioMenu === 1 ? "󰅃" : "󰅀"
                                color: Theme.muted
                                font.family: Theme.iconFamily
                            }
                            TapHandler {
                                cursorShape: Qt.PointingHandCursor
                                onTapped: root.audioMenu = root.audioMenu === 1 ? 0 : 1
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: root.source && root.source.audio.muted ? "󰍭" : "󰍬"
                                color: root.source && root.source.audio.muted ? Theme.muted : Theme.pink
                                font.family: Theme.iconFamily
                                font.pixelSize: 16
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Entrada · " + root.deviceName(root.source, true)
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                            }
                            Text {
                                text: root.audioMenu === 2 ? "󰅃" : "󰅀"
                                color: Theme.muted
                                font.family: Theme.iconFamily
                            }
                            TapHandler {
                                cursorShape: Qt.PointingHandCursor
                                onTapped: root.audioMenu = root.audioMenu === 2 ? 0 : 2
                            }
                        }
                    }
                }

                ColumnLayout {
                    visible: root.audioMenu !== 0
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: root.audioMenu === 1 ? root.sinks : root.sources

                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool selected: root.audioMenu === 1
                                                           ? modelData === root.sink
                                                           : modelData === root.source

                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 8
                            color: selected ? Theme.elevated : "transparent"

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingMd
                                anchors.rightMargin: Theme.spacingMd
                                verticalAlignment: Text.AlignVCenter
                                text: root.deviceName(modelData, root.audioMenu === 2)
                                color: selected ? Theme.purple : Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.audioMenu === 1)
                                        Pipewire.preferredDefaultAudioSink = modelData
                                    else
                                        Pipewire.preferredDefaultAudioSource = modelData
                                    root.audioMenu = 0
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: Theme.cardRadius
                        color: Theme.surface

                        Row {
                            anchors.centerIn: parent
                            spacing: 7
                            Text { text: "󰍹"; color: Theme.cyan; font.family: Theme.iconFamily }
                            Text { text: "Pantalla"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                command.command = ["systemsettings", "kcm_kscreen"]
                                command.running = true
                                root.open = false
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: Theme.cardRadius
                        color: Theme.surface

                        Row {
                            anchors.centerIn: parent
                            spacing: 7
                            Text { text: "󰒓"; color: Theme.purple; font.family: Theme.iconFamily }
                            Text { text: "Ajustes"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                command.command = ["systemsettings"]
                                command.running = true
                                root.open = false
                            }
                        }
                    }
                }
            }
        }

    }
    Connections { target: PanelCoordinator; function onActivePanelChanged() { if (root.open && PanelCoordinator.activePanel !== "controlcenter") root.open = false } }
}
