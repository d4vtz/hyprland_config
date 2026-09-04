pragma Singleton

import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: root

    property bool doNotDisturb: false
    property var latest: null
    readonly property var notifications: server.trackedNotifications
    readonly property int count: server.trackedNotifications.values.length
    signal notificationArrived()

    function clearAll() {
        const entries = server.trackedNotifications.values.slice()
        for (let notification of entries)
            notification.dismiss()
    }

    property NotificationServer server: NotificationServer {
        keepOnReload: true
        persistenceSupported: true
        actionsSupported: true
        imageSupported: true
        bodyMarkupSupported: false

        onNotification: notification => {
            notification.tracked = true
            root.latest = notification
            root.notificationArrived()
        }
    }
}
