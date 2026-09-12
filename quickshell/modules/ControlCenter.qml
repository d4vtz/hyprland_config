import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import ".."
import "../components"
import "../services"
import "controlcenter"

Item {
    id: root
    property bool open: false
    property var targetScreen: null
    property int audioMenu: 0
    property bool busy: false
    property string statusMessage: ""
    property bool statusError: false
    property real pendingBrightness: SystemStatus.brightness
    readonly property real brightness: SystemStatus.brightness
    readonly property string homePath: Quickshell.env("HOME")
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.audio !== null && n.isSink && !n.isStream)
    readonly property var sources: Pipewire.nodes.values.filter(n => n.audio !== null && !n.isSink && !n.isStream)

    function closePanel() { audioMenu = 0; open = false; PanelCoordinator.close("controlcenter") }
    function showPanel(screen) { if (screen) targetScreen = screen; PanelCoordinator.request("controlcenter"); open = true; SystemStatus.refresh() }
    function toggle(screen) { if (!open && screen) targetScreen = screen; if (!open) PanelCoordinator.request("controlcenter"); open = !open; if (open) SystemStatus.refresh(); else audioMenu = 0 }
    function adjustVolume(delta) { if (sink) sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + delta)) }
    function runCommand(args, label) { if (busy) return; busy = true; statusError = false; statusMessage = label; command.command = args; command.running = true }
    function launchExternal(args) { externalLauncher.command = args; externalLauncher.running = true; closePanel() }
    function requestBrightness(value) { pendingBrightness = Math.max(0.02, value); SystemStatus.brightness = pendingBrightness; brightnessDelay.restart() }
    function setPowerProfile(profile) {
        const tunedProfiles = { "performance": "throughput-performance", "balanced": "balanced", "power-saver": "powersave" }
        profileSetter.command = SystemStatus.powerBackend === "tuned" ? ["pkexec", "tuned-adm", "profile", tunedProfiles[profile]] : ["powerprofilesctl", "set", profile]
        busy = true; statusError = false; statusMessage = "Cambiando perfil…"; profileSetter.running = true
    }
    function deviceName(node, input) {
        if (!node) return input ? "Sin entrada" : "Sin salida"
        const raw = String(node.description || node.nickname || node.name || "")
        const lower = raw.toLowerCase()
        if (lower.indexOf("bluetooth") >= 0 || lower.indexOf("bluez") >= 0) return raw.replace(/^.*[-:] /, "") || "Bluetooth"
        if (lower.indexOf("hdmi") >= 0 || lower.indexOf("displayport") >= 0) return "HDMI / DisplayPort"
        if (lower.indexOf("speaker") >= 0 || lower.indexOf("analog stereo") >= 0) return "Altavoces integrados"
        if (lower.indexOf("microphone") >= 0 || lower.indexOf("mic") >= 0) return "Micrófono integrado"
        return raw.replace(/Raptor Lake-P\/U\/H cAVS/gi, "").trim() || (input ? "Entrada de audio" : "Salida de audio")
    }

    IpcHandler { target: "controlcenter"; function toggle(): void { root.toggle() } function show(): void { root.showPanel(null) } function hide(): void { root.closePanel() } }
    PwObjectTracker { objects: [root.sink, root.source].concat(root.sinks).concat(root.sources) }
    Process {
        id: command
        onExited: function(exitCode, exitStatus) { root.busy = false; root.statusError = exitCode !== 0; root.statusMessage = exitCode === 0 ? "Cambio aplicado" : "No se pudo aplicar el cambio"; statusTimer.restart(); SystemStatus.refresh() }
    }
    Process { id: brightnessSetter; onExited: SystemStatus.refresh() }
    Process { id: externalLauncher }
    Process {
        id: profileSetter
        onExited: function(exitCode, exitStatus) { root.busy = false; root.statusError = exitCode !== 0; root.statusMessage = exitCode === 0 ? "Perfil aplicado" : "No se pudo cambiar el perfil"; statusTimer.restart(); SystemStatus.refresh() }
    }
    Timer { id: statusTimer; interval: 2500; onTriggered: root.statusMessage = "" }
    Timer { id: brightnessDelay; interval: 90; onTriggered: { brightnessSetter.command = ["brightnessctl", "set", Math.max(2, Math.round(root.pendingBrightness * 100)) + "%"]; brightnessSetter.running = true } }

    PanelWindow {
        screen: root.targetScreen
        visible: root.open
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0; color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        MouseArea { anchors.fill: parent; onClicked: root.closePanel() }
        Surface {
            focus: root.open
            Keys.onEscapePressed: event => { if (root.audioMenu !== 0) root.audioMenu = 0; else root.closePanel(); event.accepted = true }
            width: 430; height: Math.min(680, parent.height - 64)
            anchors.top: parent.top; anchors.right: parent.right; anchors.topMargin: 54; anchors.rightMargin: 10
            Behavior on height { NumberAnimation { duration: Theme.animationFast; easing.type: Easing.OutCubic } }
            MouseArea { anchors.fill: parent }
            Flickable {
                anchors.fill: parent; clip: true; contentWidth: width
                contentHeight: contentColumn.implicitHeight + Theme.spacingLg * 2
                boundsBehavior: Flickable.StopAtBounds
                ColumnLayout {
                    id: contentColumn
                    x: Theme.spacingLg; y: Theme.spacingLg; width: parent.width - Theme.spacingLg * 2; spacing: Theme.spacingMd
                    SectionTitle { Layout.fillWidth: true; iconName: "preferences-system"; iconCategory: "apps"; icon: "󰒓"; title: "Centro de control"; subtitle: SystemStatus.userName + "@" + SystemStatus.hostName; accent: Theme.purple }
                    Rectangle {
                        visible: root.statusMessage.length > 0
                        Layout.fillWidth: true; Layout.preferredHeight: visible ? 30 : 0; radius: Theme.cardRadius
                        color: root.statusError ? Qt.rgba(1, 0.33, 0.33, 0.14) : Qt.rgba(0.31, 0.98, 0.48, 0.12)
                        Text { anchors.centerIn: parent; text: (root.busy ? "󰔟  " : root.statusError ? "󰅙  " : "󰄬  ") + root.statusMessage; color: root.statusError ? Theme.red : Theme.green; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                    }
                    AudioSection { controller: root }
                    ConnectivitySection { controller: root }
                    QuickToggles { controller: root }
                    PowerProfiles { controller: root }
                    FooterActions { controller: root }
                }
            }
        }
    }
    Connections { target: PanelCoordinator; function onActivePanelChanged() { if (root.open && PanelCoordinator.activePanel !== "controlcenter") root.closePanel() } }
}
