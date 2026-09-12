pragma Singleton

import QtQuick

QtObject {
    property string activePanel: ""

    function request(name) {
        activePanel = name
    }

    function close(name) {
        if (activePanel === name)
            activePanel = ""
    }
}
