import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

ColumnLayout {
    id: root

    property string query: ""
    property var entries: []
    readonly property var filteredEntries: entries.filter(entry =>
        entry.preview.toLowerCase().includes(query.toLowerCase()))

    function refresh() {
        listProcess.running = true
    }

    function copyEntry(entry) {
        copyProcess.command = ["sh", "-c", "cliphist decode " + Number(entry.id) + " | wl-copy"]
        copyProcess.running = true
    }

    spacing: 9
    Component.onCompleted: refresh()

    Process {
        id: listProcess
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = text.split("\n").filter(line => line.length > 0).map(line => {
                    const separator = line.indexOf("\t")
                    return {
                        id: separator >= 0 ? line.slice(0, separator) : "0",
                        preview: separator >= 0 ? line.slice(separator + 1) : line
                    }
                })
            }
        }
    }
    Process { id: copyProcess }
    Process {
        id: deleteProcess
        onExited: root.refresh()
    }
    Process {
        id: wipeProcess
        command: ["cliphist", "wipe"]
        onExited: root.refresh()
    }

    RowLayout {
        Layout.fillWidth: true
        Text {
            text: root.filteredEntries.length + (root.filteredEntries.length === 1 ? " elemento" : " elementos")
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.bold: true
        }
        Item { Layout.fillWidth: true }
        Text {
            text: "󰆴"
            color: Theme.muted
            font.family: Theme.fontFamily
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: wipeProcess.running = true
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 34
        radius: 8
        color: Theme.surface
        border.color: search.activeFocus ? Theme.purple : Theme.border
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "󰍉"
            color: Theme.muted
            font.family: Theme.iconFamily
        }
        TextInput {
            id: search
            anchors.fill: parent
            anchors.leftMargin: 32
            anchors.rightMargin: 8
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.foreground
            selectionColor: Theme.purple
            font.family: Theme.fontFamily
            font.pixelSize: 10
            onTextChanged: root.query = text
        }
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 6
        clip: true
        model: root.filteredEntries

        delegate: Rectangle {
            required property var modelData
            width: ListView.view.width
            height: 38
            radius: 7
            color: entryArea.containsMouse ? Theme.current : Theme.surface

            RowLayout {
                z: 1
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                Text {
                    Layout.fillWidth: true
                    text: modelData.preview
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }
                Text {
                    text: "󰅖"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            deleteProcess.command = ["cliphist", "delete-query", modelData.preview]
                            deleteProcess.running = true
                        }
                    }
                }
            }

            MouseArea {
                id: entryArea
                anchors.fill: parent
                z: 0
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.copyEntry(modelData)
            }
        }
    }
}
