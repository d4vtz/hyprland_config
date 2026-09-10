import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../services"

ColumnLayout {
    id: root

    property string query: ""
    property var entries: []
    readonly property var filteredEntries: entries.filter(entry =>
        entry.preview.toLowerCase().includes(query.toLowerCase()))
    property int selectedIndex: filteredEntries.length > 0 ? 0 : -1

    function activateSelected() {
        if (selectedIndex >= 0 && selectedIndex < filteredEntries.length)
            copyEntry(filteredEntries[selectedIndex])
    }

    function refresh() {
        listProcess.running = true
    }

    function copyEntry(entry) {
        const id = Number(entry.id)
        if (!Number.isFinite(id))
            return
        copyProcess.command = ["bash", "-lc", "printf '%s\\n' " + id + " | cliphist decode | wl-copy"]
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
                ClipboardStatus.count = root.entries.length
            }
        }
    }
    Process {
        id: copyProcess
        onExited: {
            if (exitCode === 0)
                ClipboardStatus.refresh()
        }
    }
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
            onTextChanged: {
                root.query = text
                root.selectedIndex = root.filteredEntries.length > 0 ? 0 : -1
            }
            Keys.onDownPressed: {
                if (root.filteredEntries.length > 0)
                    root.selectedIndex = Math.min(root.filteredEntries.length - 1, root.selectedIndex + 1)
            }
            Keys.onUpPressed: {
                if (root.filteredEntries.length > 0)
                    root.selectedIndex = Math.max(0, root.selectedIndex - 1)
            }
            Keys.onReturnPressed: root.activateSelected()
            Keys.onEnterPressed: root.activateSelected()
        }
    }

    ListView {
        id: clipboardList
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 6
        clip: true
        model: root.filteredEntries
        currentIndex: root.selectedIndex
        keyNavigationEnabled: true
        focus: visible

        onCurrentIndexChanged: {
            if (currentIndex >= 0)
                root.selectedIndex = currentIndex
        }

        Keys.onReturnPressed: root.activateSelected()
        Keys.onEnterPressed: root.activateSelected()

        delegate: Rectangle {
            id: entryDelegate
            required property var modelData
            required property int index

            width: ListView.view.width
            height: 38
            radius: 7
            color: index === root.selectedIndex || entryArea.containsMouse ? Theme.current : Theme.surface
            border.width: index === root.selectedIndex ? 1 : 0
            border.color: Theme.purple

            MouseArea {
                id: entryArea
                anchors.fill: parent
                z: 1
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.selectedIndex = index
                    root.copyEntry(modelData)
                }
            }

            RowLayout {
                z: 2
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: modelData.preview
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    elide: Text.ElideRight

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedIndex = index
                            root.copyEntry(modelData)
                        }
                    }
                }

                Text {
                    id: deleteIcon
                    text: "󰅖"
                    color: Theme.muted
                    font.family: Theme.iconFamily

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            deleteProcess.command = ["cliphist", "delete-query", modelData.preview]
                            deleteProcess.running = true
                        }
                    }
                }
            }
        }
    }
}
