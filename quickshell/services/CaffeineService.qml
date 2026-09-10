pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool active: false

    function toggle() {
        setActive(!active)
    }

    function setActive(value) {
        if (active === value)
            return

        active = value
        inhibitor.running = value
    }

    IpcHandler {
        target: "caffeine"
        function toggle(): void { root.toggle() }
        function enable(): void { root.setActive(true) }
        function disable(): void { root.setActive(false) }
    }

    property Process inhibitor: Process {
        command: [
            "systemd-inhibit",
            "--what=idle",
            "--mode=block",
            "--who=Orion Shell",
            "--why=Cafeína activa",
            "sleep",
            "infinity"
        ]

        onExited: function(exitCode, exitStatus) {
            if (root.active)
                root.active = false
        }
    }
}
