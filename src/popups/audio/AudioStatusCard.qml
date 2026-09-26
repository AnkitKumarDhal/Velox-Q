import QtQuick
import QtQuick.Layouts

import qs.src.theme
import qs.src.services

Item {
    id: root

    required property string mode
    property bool expanded: false
    signal clicked

    implicitHeight: 84

    readonly property bool isOutput: root.mode === "output"
    readonly property var capability: root.isOutput ? VolumeService.outputCapability : VolumeService.inputCapability
    readonly property bool hardwareAvailable: root.capability.hardwareAvailable
    readonly property bool backendAvailable: root.capability.backendAvailable
    readonly property bool available: root.capability.operational
    readonly property bool backendFailure: root.capability.backendFailure
    readonly property real volume: root.isOutput ? VolumeService.volume : VolumeService.inputVolume
    readonly property bool muted: root.isOutput ? VolumeService.muted : VolumeService.inputMuted
    readonly property string deviceName: {
        if (root.available) {
            if (root.isOutput) {
                return VolumeService.sink?.description || VolumeService.sink?.name || "Unknown";
            }
            return VolumeService.source?.description || VolumeService.source?.name || "Unknown";
        }
        if (root.backendFailure) {
            return root.capability.errorMessage || "Audio backend unavailable";
        }
        if (!root.hardwareAvailable) {
            return root.isOutput ? "No output device" : "No input device";
        }
        return root.isOutput ? "Waiting for audio backend" : "Waiting for audio backend";
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.expanded ? Colors.primaryContainer : cardHov.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh
        border.width: root.expanded ? 1 : 0
        border.color: root.backendFailure ? Colors.error : Colors.primary
        Behavior on color {
            ColorAnimation {
                duration: Theme.motionHover
            }
        }
        Behavior on border.width {
            NumberAnimation {
                duration: Theme.motionHover
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.motionHover
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: root.isOutput ? "󰕾" : "󰍬"
                    color: {
                        if (root.expanded)
                            return Colors.surface;
                        if (root.backendFailure)
                            return Colors.error;
                        if (root.available)
                            return Colors.primary;
                        return Colors.outline;
                    }
                    font.family: Fonts.font
                    font.pixelSize: 16
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motionHover
                        }
                    }
                }

                Text {
                    text: root.isOutput ? "Output" : "Input"
                    color: root.expanded ? Colors.surface : Colors.on_Surface
                    font.family: Fonts.font
                    font.pixelSize: 11
                    font.bold: true
                    Layout.fillWidth: true
                }

                Text {
                    text: root.available ? Math.round(root.volume * 100) + "%" : "-"
                    color: {
                        if (root.expanded)
                            return Colors.surface;
                        if (root.backendFailure)
                            return Colors.error;
                        if (root.muted)
                            return Colors.error;
                        return Colors.on_SurfaceVariant;
                    }

                    font.family: Fonts.font
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Text {
                text: root.deviceName
                color: root.expanded ? Colors.surface : root.backendFailure ? Colors.error : Colors.on_SurfaceVariant
                font.family: Fonts.font
                font.pixelSize: 10
                elide: Text.ElideRight
                Layout.fillWidth: true
                Behavior on color {
                    ColorAnimation {
                        duration: Theme.motionHover
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 4
                radius: 2
                color: Colors.surfaceContainerHighest
                Rectangle {
                    width: root.available ? parent.width * root.volume : 0
                    height: parent.height
                    radius: parent.radius
                    color: root.backendFailure ? Colors.error : root.muted ? Colors.error : Colors.primary
                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.motionQuick
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motionHover
                        }
                    }
                }
            }
        }

        MouseArea {
            id: cardHov
            anchors.fill: parent
            hoverEnabled: true
            enabled: root.available
            cursorShape: root.available ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.clicked()
        }
    }
}
