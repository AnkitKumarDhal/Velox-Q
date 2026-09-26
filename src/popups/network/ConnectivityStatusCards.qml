import QtQuick
import QtQuick.Layouts

import qs.src.services
import qs.src.theme

RowLayout {
    id: root

    property string activeTab: ""

    signal wifiClicked
    signal bluetoothClicked

    readonly property var wifiCapability: NetworkService.wifiCapability
    readonly property var bluetoothCapability: NetworkService.bluetooth.capability

    Layout.fillWidth: true
    spacing: 8

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 66
        radius: 12
        color: {
            if (root.wifiCapability.backendFailure)
                return wifiCardClick.containsMouse ? Colors.error : Colors.errorContainer;
            if (!root.wifiCapability.hardwareAvailable)
                return Colors.surfaceContainerHigh;
            if (wifiCardClick.containsMouse)
                return Colors.surfaceContainerHighest;
            return NetworkService.wifiConnected ? Colors.primaryContainer : Colors.surfaceContainerHigh;
        }

        border.width: root.activeTab === "wifi" ? 2 : root.wifiCapability.backendFailure ? 1 : 0
        border.color: root.wifiCapability.backendFailure ? Colors.error : Colors.primary
        opacity: root.wifiCapability.hardwareAvailable ? 1 : 0.65

        Behavior on color {
            ColorAnimation {
                duration: Theme.hoverFadeDuration
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: Theme.hoverFadeDuration
            }
        }

        MouseArea {
            id: wifiCardClick
            anchors.fill: parent
            enabled: root.wifiCapability.hardwareAvailable
            hoverEnabled: root.wifiCapability.hardwareAvailable
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.wifiClicked()
        }

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 12
                rightMargin: 12
            }
            z: 1
            spacing: 10

            Text {
                text: {
                    if (!root.wifiCapability.hardwareAvailable)
                        return "󰤭";
                    if (root.wifiCapability.backendFailure)
                        return "󰅙";
                    if (!NetworkService.wifiEnabled)
                        return "󰤭";
                    if (!NetworkService.wifiConnected)
                        return "󰤭";

                    const s = NetworkService.signalStrength;

                    if (s < 0.25)
                        return "󰤟";
                    if (s < 0.50)
                        return "󰤢";
                    if (s < 0.75)
                        return "󰤥";

                    return "󰤨";
                }

                font.family: Fonts.fontM
                font.pixelSize: 20

                color: {
                    if (!root.wifiCapability.hardwareAvailable)
                        return Colors.outline;
                    if (root.wifiCapability.backendFailure)
                        return Colors.on_ErrorContainer;
                    return NetworkService.wifiConnected ? Colors.on_PrimaryContainer : Colors.outline;
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: "Wi-Fi"
                    font.family: Fonts.font
                    font.pixelSize: 10
                    font.bold: true
                    color: {
                        if (root.wifiCapability.backendFailure)
                            return Colors.on_ErrorContainer;
                        if (NetworkService.wifiConnected)
                            return Colors.on_PrimaryContainer;
                        return Colors.on_SurfaceVariant;
                    }
                }

                Text {
                    text: {
                        if (!root.wifiCapability.hardwareAvailable)
                            return "Hardware unavailable";
                        if (root.wifiCapability.backendFailure)
                            return root.wifiCapability.errorMessage || "Backend unavailable";
                        if (!NetworkService.wifiEnabled)
                            return "Disabled";
                        if (NetworkService.wifiConnected)
                            return NetworkService.ssid || "Connected";
                        return "Not connected";
                    }

                    font.family: Fonts.font
                    font.pixelSize: 11
                    font.bold: true

                    color: {
                        if (root.wifiCapability.backendFailure)
                            return Colors.on_ErrorContainer;
                        if (NetworkService.wifiConnected)
                            return Colors.on_PrimaryContainer;
                        return Colors.on_Surface;
                    }

                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 28
                radius: 1
                color: root.wifiCapability.backendFailure ? Colors.on_ErrorContainer : Colors.outline
                opacity: 0.7
            }

            Rectangle {
                width: 38
                height: 22
                radius: 11
                color: {
                    if (!root.wifiCapability.operational)
                        return Colors.surfaceContainerHighest;
                    return NetworkService.wifiEnabled ? Colors.primary : Colors.surfaceContainerHighest;
                }

                border.width: {
                    if (root.wifiCapability.backendFailure)
                        return 1;
                    return NetworkService.wifiEnabled ? 0 : 1;
                }

                border.color: root.wifiCapability.backendFailure ? Colors.error : Colors.outlineVariant
                opacity: root.wifiCapability.hardwareAvailable ? 1 : 0.45

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    anchors.verticalCenter: parent.verticalCenter
                    x: NetworkService.wifiEnabled && root.wifiCapability.operational ? 19 : 3
                    color: NetworkService.wifiEnabled && root.wifiCapability.operational ? Colors.on_Primary : Colors.outline
                    Behavior on x {
                        NumberAnimation {
                            duration: Theme.hoverFadeDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.wifiCapability.operational
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (!root.wifiCapability.operational)
                            return;
                        NetworkService.setWifiEnabled(!NetworkService.wifiEnabled);
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 66
        radius: 12
        color: {
            if (root.bluetoothCapability.backendFailure)
                return bluetoothCardClick.containsMouse ? Colors.error : Colors.errorContainer;
            if (!root.bluetoothCapability.hardwareAvailable)
                return Colors.surfaceContainerHigh;
            if (bluetoothCardClick.containsMouse)
                return Colors.surfaceContainerHighest;
            return NetworkService.bluetooth.connectedDeviceCount > 0 ? Colors.primaryContainer : Colors.surfaceContainerHigh;
        }

        border.width: root.activeTab === "bluetooth" ? 2 : root.bluetoothCapability.backendFailure ? 1 : 0
        border.color: root.bluetoothCapability.backendFailure ? Colors.error : Colors.primary
        opacity: root.bluetoothCapability.hardwareAvailable ? 1 : 0.65

        Behavior on color {
            ColorAnimation {
                duration: Theme.hoverFadeDuration
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: Theme.hoverFadeDuration
            }
        }

        MouseArea {
            id: bluetoothCardClick
            anchors.fill: parent
            enabled: root.bluetoothCapability.hardwareAvailable
            hoverEnabled: root.bluetoothCapability.hardwareAvailable
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.bluetoothClicked()
        }

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 12
                rightMargin: 12
            }

            spacing: 10

            Text {
                text: {
                    if (!root.bluetoothCapability.hardwareAvailable)
                        return "󰂲";
                    if (root.bluetoothCapability.backendFailure)
                        return "󰅙";
                    return NetworkService.bluetooth.effectiveEnabled ? "󰂯" : "󰂲";
                }

                font.family: Fonts.fontM
                font.pixelSize: 20

                color: {
                    if (root.bluetoothCapability.backendFailure)
                        return Colors.on_ErrorContainer;
                    if (NetworkService.bluetooth.connectedDeviceCount > 0)
                        return Colors.on_PrimaryContainer;
                    return NetworkService.bluetooth.effectiveEnabled ? Colors.primary : Colors.outline;
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: "Bluetooth"
                    font.family: Fonts.font
                    font.pixelSize: 10
                    font.bold: true
                    color: {
                        if (root.bluetoothCapability.backendFailure)
                            return Colors.on_ErrorContainer;
                        if (NetworkService.bluetooth.connectedDeviceCount > 0)
                            return Colors.on_PrimaryContainer;
                        return Colors.on_SurfaceVariant;
                    }
                }

                Text {
                    text: {
                        if (!root.bluetoothCapability.hardwareAvailable)
                            return "Hardware unavailable";
                        if (root.bluetoothCapability.backendFailure)
                            return root.bluetoothCapability.errorMessage || "Backend unavailable";
                        return NetworkService.bluetooth.stateText;
                    }

                    font.family: Fonts.font
                    font.pixelSize: 11
                    font.bold: true

                    color: {
                        if (root.bluetoothCapability.backendFailure)
                            return Colors.on_ErrorContainer;
                        if (NetworkService.bluetooth.connectedDeviceCount > 0)
                            return Colors.on_PrimaryContainer;
                        return Colors.on_Surface;
                    }

                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 28
                radius: 1
                color: root.bluetoothCapability.backendFailure ? Colors.on_ErrorContainer : Colors.outline
                opacity: 0.7
            }

            Rectangle {
                width: 38
                height: 22
                radius: 11

                color: {
                    if (!root.bluetoothCapability.operational)
                        return Colors.surfaceContainerHighest;
                    return NetworkService.bluetooth.powerActive ? Colors.primary : Colors.surfaceContainerHighest;
                }

                border.width: {
                    if (root.bluetoothCapability.backendFailure)
                        return 1;
                    return NetworkService.bluetooth.effectiveEnabled ? 0 : 1;
                }

                border.color: root.bluetoothCapability.backendFailure ? Colors.error : Colors.outlineVariant
                opacity: root.bluetoothCapability.hardwareAvailable ? 1 : 0.45

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    anchors.verticalCenter: parent.verticalCenter
                    x: NetworkService.bluetooth.effectiveEnabled && root.bluetoothCapability.operational ? 19 : 3
                    color: NetworkService.bluetooth.effectiveEnabled && root.bluetoothCapability.operational ? Colors.on_Primary : Colors.outline

                    Behavior on x {
                        NumberAnimation {
                            duration: Theme.hoverFadeDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.bluetoothCapability.operational
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: {
                        if (!root.bluetoothCapability.operational)
                            return;
                        NetworkService.bluetooth.setEnabled(!NetworkService.bluetooth.effectiveEnabled);
                    }
                }
            }
        }
    }
}
