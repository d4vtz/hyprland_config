import QtQuick
import QtQuick.Layouts
import ".."
import "../components"
import "../services"

ColumnLayout {
    id: root
    spacing: Theme.spacingMd

    SectionTitle {
        Layout.fillWidth: true
        icon: "󰚰"
        title: UpdateService.hasUpdates ? "Actualizaciones disponibles" : "Sistema actualizado"
        subtitle: "Última consulta " + UpdateService.lastChecked
        accent: UpdateService.hasUpdates ? Theme.orange : Theme.green
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: Theme.spacingSm
        rowSpacing: Theme.spacingSm

        UpdateTile { title: "Arch"; count: UpdateService.archCount; icon: "󰣇"; accent: Theme.purple }
        UpdateTile { title: "AUR"; count: UpdateService.aurCount; icon: "󰏖"; accent: Theme.orange }
        UpdateTile { title: "Flatpak"; count: UpdateService.flatpakCount; icon: "󰏓"; accent: Theme.cyan }
        UpdateTile { title: "Firmware"; count: UpdateService.firmwareCount; icon: "󰋊"; accent: Theme.green }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingSm

        ActionButton {
            Layout.fillWidth: true
            label: UpdateService.refreshing ? "Consultando…" : "Comprobar"
            icon: "󰑐"
            accent: Theme.cyan
            enabled: !UpdateService.refreshing
            onClicked: UpdateService.refresh()
        }

        ActionButton {
            Layout.fillWidth: true
            label: "Actualizar"
            icon: "󰚰"
            accent: Theme.purple
            enabled: !UpdateService.refreshing
            onClicked: UpdateService.runFullUpgrade()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: UpdateService.flatpakCount > 0 || UpdateService.firmwareCount > 0
        spacing: Theme.spacingSm

        ActionButton {
            Layout.fillWidth: true
            visible: UpdateService.flatpakCount > 0
            label: "Flatpak"
            icon: "󰏓"
            accent: Theme.cyan
            onClicked: UpdateService.runFlatpakUpgrade()
        }

        ActionButton {
            Layout.fillWidth: true
            visible: UpdateService.firmwareCount > 0
            label: "Firmware"
            icon: "󰋊"
            accent: Theme.green
            onClicked: UpdateService.runFirmwareUpgrade()
        }
    }

    Text {
        text: "Pendientes"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBody
        font.weight: Font.DemiBold
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 5
        clip: true
        model: UpdateService.archUpdates.concat(UpdateService.aurUpdates)

        delegate: Rectangle {
            required property string modelData
            width: ListView.view.width
            height: 34
            radius: 8
            color: Theme.surface
            Text {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingMd
                anchors.rightMargin: Theme.spacingMd
                verticalAlignment: Text.AlignVCenter
                text: modelData
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
            }
        }
    }

    component UpdateTile: Rectangle {
        id: tile
        property string title: ""
        property int count: 0
        property string icon: ""
        property color accent: Theme.purple

        Layout.fillWidth: true
        Layout.preferredHeight: 62
        radius: Theme.cardRadius
        color: Theme.surface
        border.width: 1
        border.color: tile.count > 0 ? tile.accent : Theme.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingMd
            Text { text: tile.icon; color: tile.accent; font.family: Theme.iconFamily; font.pixelSize: 18 }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text { text: tile.title; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeBody }
                Text { text: tile.count + (tile.count === 1 ? " pendiente" : " pendientes"); color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            }
            Text { text: tile.count; color: tile.count > 0 ? tile.accent : Theme.subtle; font.family: Theme.fontFamily; font.pixelSize: 20; font.weight: Font.DemiBold }
        }
    }

    component ActionButton: Rectangle {
        id: button
        property string label: ""
        property string icon: ""
        property color accent: Theme.purple
        property bool enabled: true
        signal clicked()

        Layout.preferredHeight: 40
        radius: Theme.cardRadius
        color: area.containsMouse && button.enabled ? Theme.current : Theme.elevated
        opacity: button.enabled ? 1 : 0.45
        border.width: 1
        border.color: button.accent

        Row {
            anchors.centerIn: parent
            spacing: 7
            Text { text: button.icon; color: button.accent; font.family: Theme.iconFamily }
            Text { text: button.label; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            enabled: button.enabled
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: button.clicked()
        }
    }
}
