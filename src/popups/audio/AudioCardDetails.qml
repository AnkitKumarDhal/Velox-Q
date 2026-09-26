import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

import qs.src.theme
import qs.src.services
import qs.src.popups

Item {
    id: root

    required property string mode
    property bool expanded: false
    property string activeMode: ""
    readonly property bool isOutput: root.activeMode === "output"
    readonly property bool isInput: root.activeMode === "input"
    readonly property var capability: root.isOutput ? VolumeService.outputCapability : VolumeService.inputCapability
    readonly property bool available: root.capability.operational
    readonly property bool backendFailure: root.capability.backendFailure
    readonly property bool hardwareAvailable: root.capability.hardwareAvailable

    onModeChanged: {
        if (root.mode !== "")
            root.activeMode = root.mode;
    }

    implicitHeight: root.expanded ? detailsColumn.implicitHeight : 0
    clip: true

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Theme.animDuration
            easing.type: Easing.OutCubic
        }
    }

    function deviceName() {
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
        return "Waiting for audio backend";
    }

    function selectOutput(node) {
        if (!root.available || !node)
            return;
        Pipewire.preferredDefaultAudioSink = node;
    }

    function selectInput(node) {
        if (!root.available || !node)
            return;
        Pipewire.preferredDefaultAudioSource = node;
    }

    ColumnLayout {
        id: detailsColumn

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        spacing: 8
        opacity: root.visible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                readonly property bool muted: root.isOutput ? VolumeService.muted : VolumeService.inputMuted
                color: !root.available ? Colors.surfaceContainerHighest : muted ? Colors.errorContainer : Colors.surfaceContainerHighest
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text: {
                        if (root.isOutput)
                            return VolumeService.muted ? "󰝟" : "󰕾";
                        return VolumeService.inputMuted ? "󰍭" : "󰍬";
                    }
                    color: !root.available ? Colors.outline : parent.muted ? Colors.on_ErrorContainer : Colors.primary
                    font.family: Fonts.font
                    font.pixelSize: 16
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.available
                    hoverEnabled: true
                    cursorShape: root.available ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (!root.available)
                            return;
                        if (root.isOutput)
                            VolumeService.toggleMute();
                        else
                            VolumeService.toggleInputMute();
                    }
                }
            }

            VolumeSlider {
                Layout.fillWidth: true
                enabled: root.available
                value: root.isOutput ? VolumeService.volume : VolumeService.inputVolume
                muted: root.isOutput ? VolumeService.muted : VolumeService.inputMuted
                onMoved: value => {
                    if (!root.available)
                        return;
                    if (root.isOutput) {
                        if (VolumeService.audio)
                            VolumeService.audio.volume = value;
                    } else {
                        if (VolumeService.inputAudio)
                            VolumeService.inputAudio.volume = value;
                    }
                }
            }

            Text {
                text: root.available ? (root.isOutput ? Math.round(VolumeService.volume * 100) : Math.round(VolumeService.inputVolume * 100)) + "%" : "-"
                color: root.available ? Colors.on_Surface : Colors.outline
                font.family: Fonts.font
                font.pixelSize: 12
                font.bold: true
                width: 38
                horizontalAlignment: Text.AlignRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 46
            radius: 10
            color: !root.available ? Colors.surfaceContainerHigh : selectorHov.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh
            border.width: root.backendFailure ? 1 : 0
            border.color: Colors.error
            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
            Behavior on border.width {
                NumberAnimation {
                    duration: 120
                }
            }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10
                Text {
                    text: root.isOutput ? "󰓃" : "󰍬"
                    color: root.backendFailure ? Colors.error : root.available ? Colors.primary : Colors.outline
                    font.family: Fonts.font
                    font.pixelSize: 15
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        text: root.isOutput ? "Output device" : "Input device"
                        color: Colors.on_SurfaceVariant
                        font.family: Fonts.font
                        font.pixelSize: 9
                    }

                    Text {
                        text: root.deviceName()
                        color: root.backendFailure ? Colors.error : Colors.on_Surface
                        font.family: Fonts.font
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Text {
                    visible: root.available
                    text: "󰅂"
                    color: Colors.on_SurfaceVariant
                    font.family: Fonts.font
                    font.pixelSize: 14
                    rotation: selector.expanded ? 90 : 0
                    Behavior on rotation {
                        NumberAnimation {
                            duration: Theme.animDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            MouseArea {
                id: selectorHov
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.available
                cursorShape: root.available ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: selector.expanded = !selector.expanded
            }
        }

        Item {
            id: selector
            property bool expanded: false
            property real animatedHeight: 0
            Layout.fillWidth: true
            implicitHeight: selector.animatedHeight
            clip: true
            onExpandedChanged: {
                selector.animatedHeight = expanded ? selectorContent.implicitHeight : 0;
            }
            Component.onCompleted: {
                selector.animatedHeight = expanded ? selectorContent.implicitHeight : 0;
            }
            Behavior on animatedHeight {
                NumberAnimation {
                    duration: Theme.animDuration
                    easing.type: Easing.OutCubic
                }
            }
            ColumnLayout {
                id: selectorContent

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                spacing: 8
                Repeater {
                    model: Pipewire.nodes.values
                    delegate: AudioDeviceOption {
                        required property var modelData
                        Layout.fillWidth: true
                        visible: root.available && modelData.audio !== null && !modelData.isStream && (root.isOutput ? modelData.isSink : !modelData.isSink)
                        deviceName: modelData.description || modelData.name || "Unknown"
                        isDefault: root.isOutput ? (VolumeService.sink && VolumeService.sink.id === modelData.id) : (VolumeService.source && VolumeService.source.id === modelData.id)
                        icon: root.isOutput ? "󰓃" : "󰍬"
                        onSelected: {
                            if (!root.available)
                                return;
                            if (root.isOutput)
                                root.selectOutput(modelData);
                            else
                                root.selectInput(modelData);
                            selector.expanded = false;
                        }
                    }
                }

                Text {
                    visible: root.available && selectorContent.children.length === 0
                    text: root.isOutput ? "No output devices" : "No input devices"
                    color: Colors.outline
                    font.family: Fonts.font
                    font.pixelSize: 10
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Text {
            visible: root.backendFailure
            text: root.capability.errorMessage || "Audio backend unavailable"
            color: Colors.error
            font.family: Fonts.font
            font.pixelSize: 9
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }
}
