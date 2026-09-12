pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    property string activePanel: ""

    function request(name) {
        activePanel = name
    }

    function close(name) {
        if (activePanel === name)
            activePanel = ""
    }

    property IpcHandler ipc: IpcHandler {
        target: "panels"
        function closeAll(): void { activePanel = "" }
    }
}
