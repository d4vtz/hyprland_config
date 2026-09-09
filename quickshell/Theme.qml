pragma Singleton

import QtQuick

QtObject {
    // Orion Shell design system: Dracula como identidad, Material como gramática visual.
    readonly property color barBackground: "transparent"

    readonly property color canvas: "#0d0c12"
    readonly property color background: "#191a22"
    readonly property color surface: "#22242f"
    readonly property color elevated: "#2a2c38"
    readonly property color current: "#343746"
    readonly property color surfaceHover: "#3c4051"

    readonly property color border: "#393c4d"
    readonly property color borderActive: "#715c91"

    readonly property color foreground: "#f4f4ef"
    readonly property color muted: "#a6accd"
    readonly property color subtle: "#707795"

    readonly property color purple: "#bd93f9"
    readonly property color pink: "#ff79c6"
    readonly property color cyan: "#8be9fd"
    readonly property color green: "#50fa7b"
    readonly property color yellow: "#f1fa8c"
    readonly property color orange: "#ffb86c"
    readonly property color red: "#ff5555"

    // Espaciado unificado. Evita que cada módulo invente su propia geometría.
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 22

    readonly property int barHeight: 38
    readonly property int controlHeight: 40

    readonly property int radius: 10
    readonly property int cardRadius: 12
    readonly property int panelRadius: 22

    readonly property int fontSizeSmall: 10
    readonly property int fontSizeBody: 12
    readonly property int fontSizeTitle: 15
    readonly property int fontSizeHeading: 20

    readonly property int animationFast: 140
    readonly property int animationNormal: 220
    readonly property int animationSlow: 320

    readonly property string fontFamily: "Inter"
    readonly property string iconFamily: "JetBrainsMono Nerd Font"
}
