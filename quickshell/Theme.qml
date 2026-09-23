pragma Singleton

import QtQuick

QtObject {
    // Orion: estética Material 3 / DankMaterialShell, identidad cromática Dracula.
    // Este archivo es la única fuente de verdad visual del shell.
    readonly property color barBackground: "#d9191a24"

    readonly property color canvas: "#0b0a0f"
    readonly property color background: "#17161d"
    readonly property color surface: "#211f29"
    readonly property color surfaceContainer: "#272530"
    readonly property color elevated: "#2e2b38"
    readonly property color current: "#393544"
    readonly property color surfaceHover: "#433e4f"

    readonly property color border: "#4a4557"
    readonly property color borderActive: "#a98bd6"

    readonly property color foreground: "#f7f2fb"
    readonly property color muted: "#c2bacb"
    readonly property color subtle: "#918999"

    readonly property color primary: "#bd93f9"
    readonly property color onPrimary: "#25152f"
    readonly property color primaryContainer: "#4a3760"
    readonly property color onPrimaryContainer: "#f0dcff"
    readonly property color secondary: "#ff79c6"
    readonly property color secondaryContainer: "#583146"
    readonly property color tertiary: "#8be9fd"
    readonly property color tertiaryContainer: "#234b55"

    readonly property color purple: primary
    readonly property color pink: secondary
    readonly property color cyan: tertiary
    readonly property color green: "#50fa7b"
    readonly property color yellow: "#f1fa8c"
    readonly property color orange: "#ffb86c"
    readonly property color red: "#ff5555"

    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 24
    readonly property int spacing2xl: 32

    readonly property int barHeight: 48
    readonly property int pillHeight: 36
    readonly property int controlHeight: 48

    readonly property int radiusSm: 10
    readonly property int radius: 14
    readonly property int cardRadius: 18
    readonly property int panelRadius: 28
    readonly property int pillRadius: 18

    readonly property int fontSizeSmall: 11
    readonly property int fontSizeBody: 13
    readonly property int fontSizeTitle: 16
    readonly property int fontSizeHeading: 22
    readonly property int fontSizeDisplay: 36

    readonly property int animationFast: 140
    readonly property int animationNormal: 220
    readonly property int animationSlow: 320

    readonly property string fontFamily: "Inter"
    readonly property string iconFamily: "Material Symbols Rounded"
}
