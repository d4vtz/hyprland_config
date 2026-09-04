import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"

Pill {
    id: root

    property bool expanded: false
    property date shownMonth: new Date(clock.date.getFullYear(), clock.date.getMonth(), 1)
    property date selectedDate: clock.date

    active: expanded

    function changeMonth(offset) {
        shownMonth = new Date(shownMonth.getFullYear(), shownMonth.getMonth() + offset, 1)
    }

    function returnToToday() {
        selectedDate = clock.date
        shownMonth = new Date(clock.date.getFullYear(), clock.date.getMonth(), 1)
    }

    Text {
        text: clock.date.toLocaleTimeString(Qt.locale(), "HH:mm")
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.bold: true
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    MouseArea {
        parent: root
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    PanelWindow {
        visible: root.expanded
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { anchors.fill: parent; onClicked: root.expanded = false }

        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.barHeight + 12
            width: 334
            height: 326
            radius: Theme.radius + 2
            color: Theme.background
            border.color: Theme.border

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: 8
                        color: previousArea.containsMouse ? Theme.current : "transparent"
                        Text { anchors.centerIn: parent; text: "󰅁"; color: Theme.purple; font.family: Theme.iconFamily }
                        MouseArea {
                            id: previousArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.changeMonth(-1)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.shownMonth.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                        font.capitalization: Font.Capitalize
                    }

                    Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: 8
                        color: nextArea.containsMouse ? Theme.current : "transparent"
                        Text { anchors.centerIn: parent; text: "󰅂"; color: Theme.purple; font.family: Theme.iconFamily }
                        MouseArea {
                            id: nextArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.changeMonth(1)
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    columnSpacing: 4
                    rowSpacing: 4

                    Repeater {
                        model: ["lu", "ma", "mi", "ju", "vi", "sá", "do"]
                        delegate: Text {
                            required property string modelData
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 22
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: modelData
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    Repeater {
                        model: 42
                        delegate: Rectangle {
                            id: dayCell
                            required property int index

                            readonly property date firstDay: new Date(root.shownMonth.getFullYear(), root.shownMonth.getMonth(), 1)
                            readonly property int mondayOffset: (firstDay.getDay() + 6) % 7
                            readonly property date cellDate: new Date(root.shownMonth.getFullYear(), root.shownMonth.getMonth(), index - mondayOffset + 1)
                            readonly property bool inCurrentMonth: cellDate.getMonth() === root.shownMonth.getMonth()
                            readonly property bool isToday: cellDate.getFullYear() === clock.date.getFullYear()
                                && cellDate.getMonth() === clock.date.getMonth()
                                && cellDate.getDate() === clock.date.getDate()
                            readonly property bool selected: cellDate.getFullYear() === root.selectedDate.getFullYear()
                                && cellDate.getMonth() === root.selectedDate.getMonth()
                                && cellDate.getDate() === root.selectedDate.getDate()
                            readonly property bool weekend: index % 7 > 4

                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 30
                            radius: 8
                            color: isToday ? Theme.purple
                                : selected ? Theme.current
                                : dayArea.containsMouse ? Theme.surfaceHover
                                : "transparent"
                            border.color: selected && !isToday ? Theme.purple : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: Theme.animationFast }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: dayCell.cellDate.getDate()
                                color: dayCell.isToday ? Theme.background
                                    : !dayCell.inCurrentMonth ? Theme.subtle
                                    : dayCell.weekend ? Theme.pink
                                    : Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: dayCell.isToday
                            }

                            MouseArea {
                                id: dayArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedDate = dayCell.cellDate
                                    if (!dayCell.inCurrentMonth)
                                        root.shownMonth = new Date(dayCell.cellDate.getFullYear(), dayCell.cellDate.getMonth(), 1)
                                    else
                                        root.expanded = false
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: todayLabel.implicitWidth + 22
                    implicitHeight: 28
                    radius: 8
                    color: todayArea.containsMouse ? Theme.current : Theme.surface

                    Text {
                        id: todayLabel
                        anchors.centerIn: parent
                        text: "Hoy · " + clock.date.toLocaleDateString(Qt.locale(), "d MMM")
                        color: Theme.cyan
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: todayArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.returnToToday()
                    }
                }
            }
        }

        Shortcut {
            sequence: "Esc"
            onActivated: root.expanded = false
        }
    }
}
