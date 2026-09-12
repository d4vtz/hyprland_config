import QtQuick
import QtQuick.Layouts
import ".."

RowLayout {
    id: root

    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property color accent: Theme.purple

    spacing: Theme.spacingSm

    Text {
        visible: root.icon.length > 0
        text: root.icon
        color: root.accent
        font.family: Theme.iconFamily
        font.pixelSize: 17
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 1

        Text {
            text: root.title
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTitle
            font.weight: Font.DemiBold
        }

        Text {
            visible: root.subtitle.length > 0
            text: root.subtitle
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
