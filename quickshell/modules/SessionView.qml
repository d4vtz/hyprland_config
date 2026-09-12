import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../services"

ColumnLayout {
    id: root

    signal closeRequested()
    signal panelCloseRequested()

    property int selectedIndex: 0
    property int pendingIndex: -1
    property int confirmationChoice: 0 // 0 cancelar, 1 confirmar
    property var actions: [
        { icon: "󰌾", color: Theme.cyan, command: "loginctl lock-session", label: "Bloquear", destructive: false },
        { icon: "󰒲", color: Theme.green, command: "systemctl suspend", label: "Suspender", destructive: false },
        { icon: "󰍃", color: Theme.purple, command: "uwsm stop", label: "Salir", destructive: true },
        { icon: "󰑐", color: Theme.orange, command: "systemctl reboot", label: "Reiniciar", destructive: true },
        { icon: "󰐥", color: Theme.red, command: "systemctl poweroff", label: "Apagar", destructive: true }
    ]
    readonly property var pendingAction: pendingIndex >= 0 && pendingIndex < actions.length
                                         ? actions[pendingIndex]
                                         : null

    spacing: Theme.spacingMd
    focus: visible

    function takeFocus() {
        forceActiveFocus()
    }

    function moveSelection(delta) {
        if (pendingIndex >= 0)
            return
        selectedIndex = (selectedIndex + delta + actions.length) % actions.length
    }

    function moveConfirmation(delta) {
        if (pendingIndex < 0)
            return
        confirmationChoice = Math.max(0, Math.min(1, confirmationChoice + delta))
    }

    function triggerAction(index) {
        if (index < 0 || index >= actions.length)
            return

        selectedIndex = index
        if (actions[index].destructive) {
            pendingIndex = index
            confirmationChoice = 0
            forceActiveFocus()
            return
        }

        executeAction(index)
    }

    function activateCurrent() {
        if (pendingIndex >= 0) {
            if (confirmationChoice === 0)
                cancelConfirmation()
            else
                executeAction(pendingIndex)
            return
        }
        triggerAction(selectedIndex)
    }

    function executeAction(index) {
        if (index < 0 || index >= actions.length)
            return

        const action = actions[index]
        sessionCommand.command = ["bash", "-lc", action.command]
        sessionCommand.running = true
        pendingIndex = -1
        confirmationChoice = 0
        root.closeRequested()
    }

    function cancelConfirmation() {
        pendingIndex = -1
        confirmationChoice = 0
        forceActiveFocus()
    }

    function handleEscape() {
        if (pendingIndex >= 0) {
            cancelConfirmation()
            return true
        }
        return false
    }

    Process { id: sessionCommand }

    Keys.onLeftPressed: event => {
        if (root.pendingIndex >= 0)
            root.moveConfirmation(-1)
        else
            root.moveSelection(-1)
        event.accepted = true
    }
    Keys.onRightPressed: event => {
        if (root.pendingIndex >= 0)
            root.moveConfirmation(1)
        else
            root.moveSelection(1)
        event.accepted = true
    }
    Keys.onReturnPressed: event => {
        root.activateCurrent()
        event.accepted = true
    }
    Keys.onEnterPressed: event => {
        root.activateCurrent()
        event.accepted = true
    }
    Keys.onEscapePressed: event => {
        if (!root.handleEscape())
            root.panelCloseRequested()
        event.accepted = true
    }
    Keys.onPressed: event => {
        if (event.key >= Qt.Key_1 && event.key <= Qt.Key_5 && root.pendingIndex < 0) {
            root.triggerAction(event.key - Qt.Key_1)
            event.accepted = true
        }
    }

    Text {
        visible: root.pendingIndex < 0
        text: "Acciones de sesión"
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    GridLayout {
        visible: root.pendingIndex < 0
        Layout.fillWidth: true
        columns: 5
        columnSpacing: Theme.spacingSm

        Repeater {
            model: root.actions

            delegate: Rectangle {
                id: actionTile
                required property var modelData
                required property int index

                Layout.fillWidth: true
                Layout.preferredHeight: 78
                radius: Theme.cardRadius
                color: index === root.selectedIndex || actionArea.containsMouse ? Theme.current : Theme.surface
                border.width: 1
                border.color: index === root.selectedIndex ? modelData.color : Theme.border

                Column {
                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.icon
                        color: modelData.color
                        font.family: Theme.iconFamily
                        font.pixelSize: 21
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.label
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 8
                    }
                }

                MouseArea {
                    id: actionArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: root.selectedIndex = index
                    onClicked: root.triggerAction(index)
                }
            }
        }
    }

    Rectangle {
        visible: root.pendingIndex < 0
        Layout.fillWidth: true
        Layout.preferredHeight: 62
        radius: Theme.cardRadius
        color: CaffeineService.active ? Qt.rgba(Theme.yellow.r, Theme.yellow.g, Theme.yellow.b, 0.14) : Theme.surface
        border.width: 1
        border.color: CaffeineService.active ? Theme.yellow : Theme.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingMd
            anchors.rightMargin: Theme.spacingMd
            spacing: Theme.spacingMd

            Text {
                text: "󰅶"
                color: CaffeineService.active ? Theme.yellow : Theme.muted
                font.family: Theme.iconFamily
                font.pixelSize: 20
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: "Cafeína"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }

                Text {
                    text: CaffeineService.active ? "Mantener despierto" : "Suspensión automática disponible"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                }
            }

            Rectangle {
                Layout.preferredWidth: 46
                Layout.preferredHeight: 24
                radius: 12
                color: CaffeineService.active ? Theme.yellow : Theme.elevated

                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    anchors.verticalCenter: parent.verticalCenter
                    x: CaffeineService.active ? parent.width - width - 3 : 3
                    color: CaffeineService.active ? Theme.canvas : Theme.muted

                    Behavior on x {
                        NumberAnimation { duration: Theme.animationFast; easing.type: Easing.OutCubic }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: CaffeineService.toggle()
        }
    }

    Rectangle {
        visible: root.pendingIndex >= 0
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Theme.cardRadius
        color: Theme.surface
        border.width: 1
        border.color: root.pendingAction ? root.pendingAction.color : Theme.border

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - Theme.spacingXl * 2
            spacing: Theme.spacingLg

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.pendingAction ? root.pendingAction.icon : ""
                color: root.pendingAction ? root.pendingAction.color : Theme.foreground
                font.family: Theme.iconFamily
                font.pixelSize: 34
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.pendingAction ? root.pendingAction.label + " el equipo" : ""
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTitle
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: "Esta acción cerrará tu sesión o interrumpirá el trabajo actual."
                wrapMode: Text.WordWrap
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: Theme.cardRadius
                    color: root.confirmationChoice === 0 || cancelArea.containsMouse ? Theme.current : Theme.elevated
                    border.width: 1
                    border.color: root.confirmationChoice === 0 ? Theme.purple : Theme.border

                    Text {
                        anchors.centerIn: parent
                        text: "Cancelar"
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: root.confirmationChoice === 0
                    }

                    MouseArea {
                        id: cancelArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.confirmationChoice = 0
                        onClicked: root.cancelConfirmation()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: Theme.cardRadius
                    color: (root.confirmationChoice === 1 || confirmArea.containsMouse) && root.pendingAction
                           ? root.pendingAction.color
                           : Theme.elevated
                    border.width: 1
                    border.color: root.confirmationChoice === 1 && root.pendingAction
                                  ? root.pendingAction.color
                                  : Theme.border

                    Text {
                        anchors.centerIn: parent
                        text: root.pendingAction ? root.pendingAction.label : "Confirmar"
                        color: root.confirmationChoice === 1 || confirmArea.containsMouse ? Theme.canvas : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                    }

                    MouseArea {
                        id: confirmArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.confirmationChoice = 1
                        onClicked: {
                            const index = root.pendingIndex
                            if (index >= 0)
                                root.executeAction(index)
                        }
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "←  → elegir  ·  Enter ejecutar  ·  Esc cancelar"
                color: Theme.subtle
                font.family: Theme.fontFamily
                font.pixelSize: 8
            }
        }
    }

    Text {
        visible: root.pendingIndex < 0
        Layout.alignment: Qt.AlignHCenter
        text: "←  → seleccionar  ·  Enter ejecutar  ·  1–5 acceso directo"
        color: Theme.subtle
        font.family: Theme.fontFamily
        font.pixelSize: 8
    }
}
