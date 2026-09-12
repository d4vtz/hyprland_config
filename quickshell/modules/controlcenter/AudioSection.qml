import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../.."
import "../../components"

ColumnLayout {
    id: root
    required property var controller
    Layout.fillWidth: true
    spacing: Theme.spacingMd

    Card {
        Layout.fillWidth: true
        Layout.preferredHeight: 126
        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.spacingMd
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMd
                OrionIcon {
                    name: controller.sink && controller.sink.audio.muted ? "audio-volume-muted" : "audio-volume-high"
                    category: "actions"
                    fallback: controller.sink && controller.sink.audio.muted ? "󰝟" : "󰕾"
                    fallbackColor: controller.sink && controller.sink.audio.muted ? Theme.muted : Theme.cyan
                    size: 20
                    MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: if (controller.sink) controller.sink.audio.muted = !controller.sink.audio.muted }
                }
                ValueSlider {
                    Layout.fillWidth: true; icon: ""
                    value: controller.sink ? Math.min(1, controller.sink.audio.volume) : 0
                    accent: Theme.cyan
                    onValueRequested: value => { if (controller.sink) { controller.sink.audio.muted = false; controller.sink.audio.volume = value } }
                }
                Text { Layout.preferredWidth: 38; horizontalAlignment: Text.AlignRight; text: controller.sink ? Math.round(controller.sink.audio.volume * 100) + "%" : "--"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: Theme.spacingMd
                OrionIcon { name: "display-brightness"; category: "actions"; fallback: "󰃠"; fallbackColor: Theme.yellow; size: 20 }
                ValueSlider {
                    Layout.fillWidth: true; icon: ""; value: controller.brightness; accent: Theme.yellow
                    onValueRequested: value => controller.requestBrightness(value)
                }
                Text { Layout.preferredWidth: 38; horizontalAlignment: Text.AlignRight; text: Math.round(controller.brightness * 100) + "%"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            }
        }
    }

    Card {
        Layout.fillWidth: true
        Layout.preferredHeight: 148
        ColumnLayout {
            anchors.fill: parent; spacing: Theme.spacingSm
            DeviceRow { input: false; title: "Salida"; node: controller.sink; menuId: 1; accent: Theme.cyan }
            RowLayout {
                Layout.fillWidth: true; spacing: Theme.spacingMd
                OrionIcon { name: controller.source && controller.source.audio.muted ? "microphone-sensitivity-muted" : "audio-input-microphone"; category: "devices"; fallback: controller.source && controller.source.audio.muted ? "󰍭" : "󰍬"; fallbackColor: controller.source && controller.source.audio.muted ? Theme.muted : Theme.pink; size: 18 }
                ValueSlider { Layout.fillWidth: true; value: controller.source ? Math.min(1, controller.source.audio.volume) : 0; accent: Theme.pink; onValueRequested: value => { if (controller.source) { controller.source.audio.muted = false; controller.source.audio.volume = value } } }
                Text { Layout.preferredWidth: 38; horizontalAlignment: Text.AlignRight; text: controller.source ? Math.round(controller.source.audio.volume * 100) + "%" : "--"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            }
            DeviceRow { input: true; title: "Entrada"; node: controller.source; menuId: 2; accent: Theme.pink }
        }
    }

    ColumnLayout {
        visible: controller.audioMenu !== 0
        Layout.fillWidth: true; spacing: 4
        Repeater {
            model: controller.audioMenu === 1 ? controller.sinks : controller.sources
            delegate: Rectangle {
                required property var modelData
                readonly property bool selected: controller.audioMenu === 1 ? modelData === controller.sink : modelData === controller.source
                Layout.fillWidth: true; Layout.preferredHeight: 32; radius: 8
                color: selected ? Theme.elevated : "transparent"
                Text { anchors.fill: parent; anchors.leftMargin: Theme.spacingMd; anchors.rightMargin: Theme.spacingMd; verticalAlignment: Text.AlignVCenter; text: controller.deviceName(modelData, controller.audioMenu === 2); color: selected ? Theme.purple : Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; elide: Text.ElideRight }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (controller.audioMenu === 1) Pipewire.preferredDefaultAudioSink = modelData; else Pipewire.preferredDefaultAudioSource = modelData; controller.audioMenu = 0 } }
            }
        }
    }

    component DeviceRow: RowLayout {
        required property bool input
        required property string title
        required property var node
        required property int menuId
        required property color accent
        Layout.fillWidth: true
        OrionIcon {
            name: input ? (node && node.audio.muted ? "microphone-sensitivity-muted" : "audio-input-microphone") : (node && node.audio.muted ? "audio-volume-muted" : "audio-speakers")
            category: input ? "devices" : (node && node.audio.muted ? "actions" : "devices")
            fallback: node && node.audio.muted ? (input ? "󰍭" : "󰝟") : (input ? "󰍬" : "󰓃")
            fallbackColor: node && node.audio.muted ? Theme.muted : accent
            size: 18
            MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: if (node) node.audio.muted = !node.audio.muted }
        }
        Text { Layout.fillWidth: true; text: title + " · " + controller.deviceName(node, input); color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; elide: Text.ElideRight }
        Text { text: controller.audioMenu === menuId ? "󰅃" : "󰅀"; color: Theme.muted; font.family: Theme.iconFamily }
        TapHandler { cursorShape: Qt.PointingHandCursor; onTapped: controller.audioMenu = controller.audioMenu === menuId ? 0 : menuId }
    }
}
