pragma Singleton

import QtQuick

QtObject {
    readonly property color background: "#282a36"
    readonly property color surface: "#30323f"
    readonly property color current: "#44475a"
    readonly property color foreground: "#f8f8f2"
    readonly property color muted: "#8a93b8"
    readonly property color purple: "#bd93f9"
    readonly property color pink: "#ff79c6"
    readonly property color cyan: "#8be9fd"
    readonly property color green: "#50fa7b"
    readonly property color orange: "#ffb86c"
    readonly property color red: "#ff5555"

    readonly property int barHeight: 38
    readonly property int radius: 10
    readonly property int animationFast: 140
    readonly property int animationNormal: 220
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
}

