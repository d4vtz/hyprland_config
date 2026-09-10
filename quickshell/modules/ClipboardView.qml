import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../services"

ColumnLayout {
    id: root

    signal copied()

    property string query: ""
    property var entries: []
    property int selectedIndex: -1
    readonly property var filteredEntries: entries.filter(entry =>
        entry.preview.toLowerCase().includes(query.toLowerCase()))

    spacing: 9
    focus: visible

    function normalizeSelection() {
        if (filteredEntries.length === 0) {
            selectedIndex = -1
            return
        }
        selectedIndex = Math.max(0, Math.min(selectedIndex < 0 ? 0 : selectedIndex, filteredEntries.length - 1))
        clipboardList.currentIndex = selectedIndex
    }

    function moveSelection(delta) {
        if (filteredEntries.length === 0)
            return
        if (selectedIndex < 0)
            selectedIndex = 0
        else
            selectedIndex = Math.max(0, Math.min(filteredEntries.length - 1, selectedIndex + delta))
        clipboardList.currentIndex = selectedIndex
        clipboardList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function activateSelected() {
        normalizeSelection()
        if (selectedIndex >= 0 && selectedIndex < filteredEntries.length)
            copyEntry(filteredEntries[selectedIndex])
    }

    function takeFocus() {
        normalizeSelection()
        clipboardList.forceActiveFocus()
    }

    function refresh() {
        listProcess.running = true
    }

    function copyEntry(entry) {
        if (!entry || !entry.raw)
            return

        // cliphist decode recibe la línea completa producida por `cliphist list`,
        // no solamente el id. El registro se pasa como argumento posicional para
        // evitar problemas de comillas, saltos o caracteres especiales.
        copyProcess.command = [
            "sh", "-c",
            "printf '%s\\n' \"$1\" | cliphist decode | wl-copy",
            "orion-clipboard",
            entry.raw
        ]
        copyProcess.running = true
    }

    Component.onCompleted: refresh()

    Keys.onDownPressed: event => {
        moveSelection(1)
        event.accepted = true
    }
    Keys.onUpPressed: event => {
        moveSelection(-1)
        event.accepted = true
    }
    Keys.onReturnPressed: event => {
        activateSelected()
        event.accepted = true
    }
    Keys.onEnterPressed: event => {
        activateSelected()
        event.accepted = true
    }

    Process {
        id: listProcess
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = text.split("\n").filter(line => line.length > 0).map(line => {
                    const separator = line.indexOf("\t")
                    return {
                        raw: line,
                        id: separator >= 0 ? line.slice(0, separator) : "",
                        preview: separator >= 0 ? line.slice(separator + 1) : line
                    }
                })
                ClipboardStatus.count = root.entries.length
                root.selectedIndex = root.entries.length > 0 ? 0 : -1
                Qt.callLater(root.normalizeSelection)
            }
        }
    }

    Process {
        id: copyProcess
        onExited: {
            if (exitCode === 0) {
                ClipboardStatus.refresh()
                root.copied()
            }
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
            font.family: Theme.iconFamily

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
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
        border.width: 1
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
                Qt.callLater(root.normalizeSelection)
            }

            Keys.onDownPressed: event => {
                root.moveSelection(1)
                clipboardList.forceActiveFocus()
                event.accepted = true
            }
            Keys.onUpPressed: event => {
                root.moveSelection(-1)
                clipboardList.forceActiveFocus()
                event.accepted = true
            }
            Keys.onReturnPressed: event => {
                root.activateSelected()
                event.accepted = true
            }
            Keys.onEnterPressed: event => {
                root.activateSelected()
                event.accepted = true
            }
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
        keyNavigationEnabled: false
        highlightMoveDuration: 100
        focus: root.visible

        Keys.onDownPressed: event => {
            root.moveSelection(1)
            event.accepted = true
        }
        Keys.onUpPressed: event => {
            root.moveSelection(-1)
            event.accepted = true
        }
        Keys.onReturnPressed: event => {
            root.activateSelected()
            event.accepted = true
        }
        Keys.onEnterPressed: event => {
            root.activateSelected()
            event.accepted = true
        }

        delegate: Rectangle {
            id: entryDelegate
            required property var modelData
            required property int index

            width: ListView.view.width
            height: 40
            radius: 8
            color: index === root.selectedIndex || rowArea.containsMouse ? Theme.current : Theme.surface
            border.width: index === root.selectedIndex ? 1 : 0
            border.color: Theme.purple

            MouseArea {
                id: rowArea
                anchors.fill: parent
                anchors.rightMargin: 34
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: {
                    root.selectedIndex = index
                    clipboardList.currentIndex = index
                    clipboardList.forceActiveFocus()
                }
                onClicked: root.copyEntry(modelData)
            }

            Text {
                anchors.left: parent.left
                anchors.right: deleteButton.left
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.preview
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 9
                elide: Text.ElideRight
            }

            Item {
                id: deleteButton
                width: 30
                height: parent.height
                anchors.right: parent.right

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: deleteArea.containsMouse ? Theme.red : Theme.muted
                    font.family: Theme.iconFamily
                }

                MouseArea {
                    id: deleteArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        deleteProcess.command = [
                            "sh", "-c",
                            "printf '%s\\n' \"$1\" | cliphist delete",
                            "orion-clipboard",
                            modelData.raw
                        ]
                        deleteProcess.running = true
                    }
                }
            }
        }
    }
}
