import QtQuick
import Quickshell
import ".."

Item {
    id: root

    property string name: ""
    property string category: ""
    property string fallback: ""
    property string fallbackName: "image-missing"
    property string materialName: ""
    property real size: 18
    property color fallbackColor: Theme.foreground
    property bool smooth: true

    readonly property string resolvedMaterialName: {
        if (materialName.length)
            return materialName

        const map = {
            "application-menu": "apps",
            "dashboard-show": "dashboard",
            "utilities-system-monitor": "monitor_heart",
            "ac-adapter": "power",
            "battery": "battery_full",
            "battery-charging": "battery_charging_full",
            "network-wireless": "wifi",
            "network-wireless-offline": "wifi_off",
            "network-wireless-configure": "wifi_settings",
            "network-wired": "lan",
            "audio-volume-high": "volume_up",
            "audio-volume-medium": "volume_down",
            "audio-volume-low": "volume_mute",
            "audio-volume-muted": "volume_off",
            "audio-speakers": "speaker",
            "audio-input-microphone": "mic",
            "microphone-sensitivity-muted": "mic_off",
            "display-brightness": "brightness_6",
            "notifications-disabled": "notifications_off",
            "preferences-system-notifications": "notifications",
            "edit-paste": "content_paste",
            "system-software-update": "system_update",
            "caffeine": "coffee",
            "system-shutdown": "power_settings_new",
            "preferences-system": "settings",
            "preferences-desktop-display": "desktop_windows",
            "search": "search",
            "application-x-executable": "apps",
            "content-loading": "progress_activity",
            "dialog-error": "error",
            "dialog-ok": "check_circle",
            "dialog-information": "info",
            "dialog-warning": "warning",
            "image-missing": "image",
            "bluetooth": "bluetooth",
            "brightness-high": "brightness_high",
            "brightness-low": "brightness_low",
            "lock": "lock",
            "system-lock-screen": "lock",
            "system-suspend": "bedtime",
            "system-reboot": "restart_alt",
            "system-log-out": "logout",
            "application-exit": "logout",
            "media-playback-start": "play_arrow",
            "media-playback-pause": "pause",
            "media-skip-backward": "skip_previous",
            "media-skip-forward": "skip_next",
            "folder": "folder",
            "folder-open": "folder_open",
            "document-open": "folder_open",
            "document-save": "save",
            "view-refresh": "refresh",
            "help-about": "help",
            "system-run": "terminal",
            "camera-photo": "photo_camera",
            "user": "person",
            "computer": "computer",
            "pan-up": "expand_less",
            "pan-down": "expand_more",
            "chevron-left": "chevron_left",
            "chevron-right": "chevron_right",
            "airplane-mode": "flight",
            "redshift-status-on": "dark_mode"
        }
        return map[name] || name || "image"
    }

    implicitWidth: size
    implicitHeight: size

    FontLoader {
        id: materialFont
        source: "file:///usr/share/fonts/TTF/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf"
    }

    Text {
        id: materialIcon
        anchors.fill: parent
        text: materialFont.status === FontLoader.Ready ? root.resolvedMaterialName : root.fallback
        color: root.fallbackColor
        font.family: materialFont.status === FontLoader.Ready ? materialFont.name : Theme.iconFamily
        font.pixelSize: root.size
        font.weight: Font.Normal
        font.features: materialFont.status === FontLoader.Ready ? { "liga": 1 } : {}
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        renderType: Text.NativeRendering
        visible: text.length > 0
    }
}
