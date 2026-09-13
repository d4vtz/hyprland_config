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
    property var packageUpdates: []

    readonly property string helper: Quickshell.env("HOME") + "/.config/hypr/scripts/system-maintenance.sh"
    readonly property int totalUpdates: officialUpdates + aurUpdates

    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.extraExtraLarge
    implicitHeight: content.implicitHeight + Tokens.padding.large * 2

    function refresh(): void {
        if (!status.running)
            status.running = true;
        if (!packageList.running)
            packageList.running = true;
    }

    function run(action: string): void {
        command.command = ["bash", root.helper, action];
        command.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: status
        command: ["bash", root.helper, "status"]
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
        id: packageList
        command: ["bash", root.helper, "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim();
                root.packageUpdates = output.length === 0 ? [] : output.split("\n").map(line => {
                    const fields = line.split("|");
                    return {
                        source: fields[0] || "",
                        name: fields[1] || "",
                        current: fields[2] || "",
                        next: fields[3] || ""
                    };
                });
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


        ColumnLayout {
            Layout.fillWidth: true
            visible: !root.compact
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    Layout.fillWidth: true
                    text: Tr.tr("Pending packages")
                    font: Tokens.font.title.small
                }

                StyledText {
                    text: root.packageUpdates.length.toString()
                    font: Tokens.font.label.medium
                    color: Colours.palette.m3primary
                }
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.packageUpdates.length === 0
                text: Tr.tr("No pending package updates")
                font: Tokens.font.body.small
                color: Colours.palette.m3onSurfaceVariant
            }

            ListView {
                id: updatesList

                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, 240)
                visible: root.packageUpdates.length > 0
                model: root.packageUpdates
                spacing: Tokens.spacing.extraSmall
                clip: true
                interactive: contentHeight > height

                delegate: RowLayout {
                    required property var modelData
                    width: updatesList.width
                    spacing: Tokens.spacing.medium

                    StyledRect {
                        implicitWidth: sourceLabel.implicitWidth + Tokens.padding.medium * 2
                        implicitHeight: sourceLabel.implicitHeight + Tokens.padding.extraSmall
                        radius: Tokens.rounding.full
                        color: modelData.source === "AUR"
                            ? Colours.palette.m3tertiaryContainer
                            : Colours.palette.m3secondaryContainer

                        StyledText {
                            id: sourceLabel
                            anchors.centerIn: parent
                            text: modelData.source
                            font: Tokens.font.label.small
                            color: modelData.source === "AUR"
                                ? Colours.palette.m3onTertiaryContainer
                                : Colours.palette.m3onSecondaryContainer
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: modelData.name
                        elide: Text.ElideRight
                        font: Tokens.font.body.medium
                    }

                    StyledText {
                        text: modelData.current + "  →  " + modelData.next
                        font: Tokens.font.body.small
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
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
