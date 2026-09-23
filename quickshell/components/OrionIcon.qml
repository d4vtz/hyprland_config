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
            "audio-volume-high": "volume_up",
            "audio-volume-medium": "volume_down",
            "audio-volume-low": "volume_mute",
            "notifications-disabled": "notifications_off",
            "preferences-system-notifications": "notifications",
            "edit-paste": "content_paste",
            "system-software-update": "system_update",
            "caffeine": "coffee",
            "system-shutdown": "power_settings_new",
            "preferences-system": "settings",
            "search": "search",
            "application-x-executable": "apps",
            "content-loading": "progress_activity",
            "dialog-error": "error",
            "dialog-ok": "check_circle",
            "image-missing": "image",
            "network-wired": "lan",
            "bluetooth": "bluetooth",
            "brightness-high": "brightness_high",
            "brightness-low": "brightness_low",
            "lock": "lock",
            "system-lock-screen": "lock",
            "system-suspend": "bedtime",
            "system-reboot": "restart_alt",
            "media-playback-start": "play_arrow",
            "media-playback-pause": "pause",
            "media-skip-backward": "skip_previous",
            "media-skip-forward": "skip_next",
            "audio-volume-muted": "volume_off",
            "preferences-desktop-display": "desktop_windows",
            "folder": "folder",
            "document-open": "folder_open",
            "document-save": "save",
            "view-refresh": "refresh",
            "help-about": "info",
            "system-run": "terminal",
            "camera-photo": "photo_camera",
            "application-exit": "logout",
            "system-log-out": "logout",
            "dialog-information": "info",
            "dialog-warning": "warning",
            "user": "person",
            "computer": "computer"
        }
        return map[name] || name || "image"
    }

    implicitWidth: size
    implicitHeight: size

    Text {
        id: materialIcon
        anchors.fill: parent
        text: root.resolvedMaterialName
        color: root.fallbackColor
        font.family: Theme.materialIconFamily
        font.pixelSize: root.size
        font.weight: Font.Normal
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        renderType: Text.NativeRendering
        visible: text.length > 0
    }
}
