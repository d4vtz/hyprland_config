import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    property bool compact: false
    property int officialUpdates: 0
    property int aurUpdates: 0
    property int failedServices: 0
    property bool upstreamAvailable: false

    readonly property string helper: Quickshell.env("HOME") + "/.config/hypr/scripts/system-maintenance.sh"
    readonly property int totalUpdates: officialUpdates + aurUpdates

    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.extraExtraLarge
    implicitHeight: content.implicitHeight + Tokens.padding.large * 2

    function refresh(): void {
        if (!status.running)
            status.running = true;
    }

    function run(action: string): void {
        command.command = [root.helper, action];
        command.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: status
        command: [root.helper, "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|");
                if (fields.length !== 4)
                    return;
                root.officialUpdates = Number(fields[0]) || 0;
                root.aurUpdates = Number(fields[1]) || 0;
                root.failedServices = Number(fields[2]) || 0;
                root.upstreamAvailable = fields[3] === "1";
            }
        }
    }

    Process {
        id: command
        onExited: root.refresh()
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.medium

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            MaterialIcon {
                text: root.totalUpdates > 0 || root.failedServices > 0 || root.upstreamAvailable
                    ? "system_update_alt" : "verified"
                fill: 1
                color: root.failedServices > 0
                    ? Colours.palette.m3error : Colours.palette.m3primary
                fontStyle: Tokens.font.icon.large
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    text: Tr.tr("Maintenance")
                    font: Tokens.font.title.medium
                }

                StyledText {
                    text: root.failedServices > 0
                        ? Tr.tr("%1 failed services").arg(root.failedServices)
                        : root.totalUpdates > 0
                            ? Tr.tr("%1 updates available").arg(root.totalUpdates)
                            : root.upstreamAvailable
                                ? Tr.tr("Caelestia update available")
                                : Tr.tr("System up to date")
                    font: Tokens.font.body.small
                    color: Colours.palette.m3onSurfaceVariant
                }
            }

            IconButton {
                icon: "refresh"
                onClicked: root.refresh()
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: root.compact ? 2 : 4
            rowSpacing: Tokens.spacing.small
            columnSpacing: Tokens.spacing.small

            IconTextButton {
                Layout.fillWidth: true
                icon: "upgrade"
                text: root.compact ? Tr.tr("Packages") : Tr.tr("Update system and AUR")
                onClicked: root.run("update")
            }
            IconTextButton {
                Layout.fillWidth: true
                icon: "cleaning_services"
                text: root.compact ? Tr.tr("Cache") : Tr.tr("Clean package cache")
                onClicked: root.run("cache")
            }
            IconTextButton {
                Layout.fillWidth: true
                icon: "monitor_heart"
                text: root.compact ? Tr.tr("Services") : Tr.tr("Review failed services")
                onClicked: root.run("services")
            }
            IconTextButton {
                Layout.fillWidth: true
                icon: "sync"
                text: root.compact ? "Caelestia" : Tr.tr("Update Caelestia")
                onClicked: root.run("upstream-update")
            }
        }
    }
}
