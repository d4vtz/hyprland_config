import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

Item {
    id: root

    property bool open: false
    property var targetScreen: null
    property string query: ""
    property var entries: []
    readonly property var filteredEntries: entries.filter(entry =>
        entry.name.toLowerCase().includes(query.toLowerCase())
        || entry.id.toLowerCase().includes(query.toLowerCase()))

    function focusSearch() {
        Qt.callLater(function() {
            search.forceActiveFocus()
            search.cursorPosition = search.length
        })
    }

    function showPanel(screen) {
        if (screen) targetScreen = screen
        PanelCoordinator.request("launcher")
        open = true
        query = ""
        appList.running = true
        focusSearch()
    }

    function toggle(screen) {
        if (open) {
            open = false
            PanelCoordinator.close("launcher")
            return
        }
        if (screen) targetScreen = screen
        PanelCoordinator.request("launcher")
        open = !open
        if (open) {
            query = ""
            appList.running = true
            focusSearch()
        }
    }

    function launch(entry) {
        launchProcess.command = ["gtk-launch", entry.id]
        launchProcess.running = true
        open = false
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.toggle() }
        function show(): void { root.showPanel(null) }
        function hide(): void { root.open = false; PanelCoordinator.close("launcher") }
    }

    Process {
        id: appList
        command: ["bash", "-lc", "for f in /usr/share/applications/*.desktop \"$HOME\"/.local/share/applications/*.desktop; do [[ -f \"$f\" ]] || continue; grep -q '^NoDisplay=true' \"$f\" && continue; grep -q '^Hidden=true' \"$f\" && continue; n=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-); [[ -n \"$n\" ]] || continue; id=$(basename \"$f\" .desktop); i=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2-); printf '%s\\t%s\\t%s\\n' \"$n\" \"$id\" \"$i\"; done | sort -fu"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = text.split("\n").filter(line => line.length > 0).map(line => {
                    const f = line.split("\t")
                    return { name: f[0] || "", id: f[1] || "", icon: f[2] || "" }
                })
            }
        }
    }

    Process { id: launchProcess }

    PanelWindow {
        screen: root.targetScreen
        visible: root.open
        onVisibleChanged: if (visible) root.focusSearch()
        anchors { top: true; right: true; bottom: true; left: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.open = false
                PanelCoordinator.close("launcher")
            }
        }

        Surface {
            id: panelSurface
            Keys.onEscapePressed: event => { root.open = false; PanelCoordinator.close("launcher"); event.accepted = true }
            width: 620
            height: 500
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 90

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingXl
                spacing: Theme.spacingMd

                SectionTitle {
                    Layout.fillWidth: true
                    icon: "󰍉"
                    title: "Aplicaciones"
                    subtitle: "Busca y abre aplicaciones"
                    accent: Theme.purple
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: Theme.cardRadius
                    color: Theme.surface
                    border.width: 1
                    border.color: search.activeFocus ? Theme.purple : Theme.border

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingMd
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰍉"
                        color: Theme.purple
                        font.family: Theme.iconFamily
                        font.pixelSize: 17
                    }

                    TextInput {
                        id: search
                        anchors.fill: parent
                        anchors.leftMargin: 42
                        anchors.rightMargin: Theme.spacingMd
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.foreground
                        selectionColor: Theme.purple
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        text: root.query
                        onTextChanged: root.query = text
                        Keys.onEscapePressed: event => {
                            root.open = false
                            PanelCoordinator.close("launcher")
                            event.accepted = true
                        }
                        Keys.onReturnPressed: {
                            if (root.filteredEntries.length > 0)
                                root.launch(root.filteredEntries[0])
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    model: root.filteredEntries

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 54
                        radius: Theme.cardRadius
                        color: appArea.containsMouse ? Theme.current : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingMd
                            anchors.rightMargin: Theme.spacingMd
                            spacing: Theme.spacingMd

                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                radius: 10
                                color: Theme.elevated
                                IconImage {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    source: Quickshell.iconPath(modelData.icon || "application-x-executable", true)
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeBody
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.id
                                    color: Theme.muted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                text: "󰜴"
                                color: Theme.subtle
                                font.family: Theme.iconFamily
                            }
                        }

                        MouseArea {
                            id: appArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.launch(modelData)
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.filteredEntries.length + " aplicaciones"
                    color: Theme.subtle
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }

    }

    Connections { target: PanelCoordinator; function onActivePanelChanged() { if (root.open && PanelCoordinator.activePanel !== "launcher") root.open = false } }
}
