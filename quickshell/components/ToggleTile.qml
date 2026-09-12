import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root

    property string icon: ""
    property string iconName: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property bool interactive: true
    property string actionIcon: ""
    property string actionIconName: ""
    property color accent: Theme.purple
    signal clicked()
    signal actionClicked()

    implicitHeight: 64
    radius: Theme.cardRadius
    color: checked ? Qt.rgba(accent.r, accent.g, accent.b, 0.18) : Theme.surface
    border.width: 1
    border.color: checked ? accent : Theme.border

    Behavior on color { ColorAnimation { duration: Theme.animationFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.animationFast } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 11
            color: checked ? accent : Theme.elevated

            OrionIcon {
                anchors.centerIn: parent
                name: root.iconName
                fallback: root.icon
                fallbackColor: checked ? Theme.background : root.accent
                size: 20
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.title
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBody
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Text {
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.rightMargin: root.actionIcon.length > 0 || root.actionIconName.length > 0 ? 34 : 0
        enabled: root.interactive
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }

    Rectangle {
        visible: root.actionIcon.length > 0 || root.actionIconName.length > 0
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
        radius: 9
        color: actionArea.containsMouse ? Theme.current : "transparent"

        OrionIcon {
            anchors.centerIn: parent
            name: root.actionIconName
            fallback: root.actionIcon
            fallbackColor: root.accent
            size: 16
        }
        MouseArea {
            id: actionArea
            anchors.fill: parent
            enabled: root.interactive
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.actionClicked()
        }
    }
}
