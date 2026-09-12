import QtQuick
import QtQuick.Layouts
import ".."

RowLayout {
    id: root

    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property string iconName: ""
    property string iconCategory: ""
    property color accent: Theme.purple

    spacing: Theme.spacingSm

    OrionIcon {
        visible: root.icon.length > 0 || root.iconName.length > 0
        name: root.iconName
        category: root.iconCategory
        fallback: root.icon
        fallbackColor: root.accent
        size: 18
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
