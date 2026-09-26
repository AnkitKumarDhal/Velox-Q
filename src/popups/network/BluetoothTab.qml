import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.src.services
import qs.src.theme

ColumnLayout {
    id: root

    readonly property var capability: NetworkService.bluetooth.capability
    readonly property bool hardwareAvailable: root.capability.hardwareAvailable
    readonly property bool backendFailure: root.capability.backendFailure
    readonly property bool backendOperational: root.capability.operational

    Layout.fillWidth: true
    spacing: 8

    ScriptModel {
        id: btConnectedModel
        objectProp: "address"
        values: {
            if (!root.backendOperational)
                return [];
            return NetworkService.bluetooth.connectedDevices;
        }
    }

    ScriptModel {
        id: btPairedModel
        objectProp: "address"
        values: {
            if (!root.backendOperational)
                return [];
            return NetworkService.bluetooth.pairedDevices;
        }
    }

    ScriptModel {
        id: btAvailableModel
        objectProp: "address"
        values: {
            if (!root.backendOperational)
                return [];
            return NetworkService.bluetooth.availableDevices;
        }
    }

    Rectangle {
        visible: root.backendFailure || !root.hardwareAvailable
        Layout.fillWidth: true
        implicitHeight: capabilityErrorColumn.implicitHeight + 20
        radius: 12
        color: root.backendFailure ? Colors.errorContainer : Colors.surfaceContainerHigh
        border.width: root.backendFailure ? 1 : 0
        border.color: Colors.error

        ColumnLayout {
            id: capabilityErrorColumn
            anchors {
                fill: parent
                margins: 10
            }
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.backendFailure ? "󰅙" : "󰂲"
                    font.family: Fonts.fontM
                    font.pixelSize: 17
                    color: root.backendFailure ? Colors.on_ErrorContainer : Colors.outline
                }

                Text {
                    text: {
                        if (!root.hardwareAvailable)
                            return "Bluetooth hardware unavailable";
                        return "Bluetooth backend unavailable";
                    }
                    font.family: Fonts.font
                    font.pixelSize: 11
                    font.bold: true
                    color: root.backendFailure ? Colors.on_ErrorContainer : Colors.on_SurfaceVariant
                    Layout.fillWidth: true
                }
            }

            Text {
                visible: root.backendFailure
                text: root.capability.errorMessage || "The Bluetooth backend could not be reached."
                font.family: Fonts.font
                font.pixelSize: 9
                color: Colors.on_ErrorContainer
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }
    }

    RowLayout {
        visible: root.backendOperational
        Layout.fillWidth: true

        Text {
            text: NetworkService.bluetooth.scanning ? "Scanning for devices…" : "Bluetooth devices"
            font.family: Fonts.font
            font.pixelSize: 14
            font.bold: true
            color: Colors.on_SurfaceVariant
            Layout.fillWidth: true
        }

        Rectangle {
            width: scanLabel.implicitWidth + 20
            height: 28
            radius: 14
            enabled: root.backendOperational && (NetworkService.bluetooth.operational || NetworkService.bluetooth.scanning)
            color: {
                if (!enabled)
                    return Colors.surfaceContainerHighest;
                return NetworkService.bluetooth.scanning || btScanHover.hovered ? Colors.primary : Colors.surfaceContainerHighest;
            }

            opacity: enabled ? 1 : 0.45

            Behavior on color {
                ColorAnimation {
                    duration: Theme.hoverFadeDuration
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }

            Text {
                id: scanLabel
                anchors.centerIn: parent
                text: NetworkService.bluetooth.scanning ? "Stop" : "Scan"
                font.family: Fonts.font
                font.pixelSize: 10
                font.bold: true
                color: (root.backendOperational && (NetworkService.bluetooth.scanning || btScanHover.hovered)) ? Colors.on_Primary : Colors.on_Surface
            }

            HoverHandler {
                id: btScanHover
                enabled: root.backendOperational && (NetworkService.bluetooth.operational || NetworkService.bluetooth.scanning)
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.backendOperational && (NetworkService.bluetooth.operational || NetworkService.bluetooth.scanning)
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (!root.backendOperational)
                        return;
                    if (NetworkService.bluetooth.scanning) {
                        NetworkService.bluetooth.stopScan();
                    } else if (NetworkService.bluetooth.operational) {
                        NetworkService.bluetooth.scan();
                    }
                }
            }
        }
    }

    Flickable {
        visible: root.backendOperational
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentColumn.implicitHeight, 320)
        contentHeight: contentColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: 6

            Text {
                visible: btConnectedModel.values.length > 0
                text: "Connected"
                font.family: Fonts.font
                font.pixelSize: 10
                font.bold: true
                color: Colors.on_SurfaceVariant
                topPadding: 2
            }

            Repeater {
                model: btConnectedModel
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: 10
                    color: connectedHover.hovered ? Colors.surfaceContainerHighest : Qt.rgba(Colors.primaryContainer.r, Colors.primaryContainer.g, Colors.primaryContainer.b, 0.28)

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.hoverFadeDuration
                        }
                    }
                    HoverHandler {
                        id: connectedHover
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 10
                        }
                        spacing: 9

                        Text {
                            text: modelData.icon.includes("headphones") ? "󰋋" : modelData.icon.includes("keyboard") ? "󰌌" : modelData.icon.includes("mouse") ? "󰍽" : "󰂯"
                            font.family: Fonts.fontM
                            font.pixelSize: 17
                            color: Colors.primary
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: modelData.name
                                font.family: Fonts.font
                                font.pixelSize: 11
                                font.bold: true
                                color: Colors.on_Surface
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : "Connected"
                                font.family: Fonts.font
                                font.pixelSize: 9
                                color: Colors.on_SurfaceVariant
                            }
                        }

                        Rectangle {
                            width: disconnectLabel.implicitWidth + 18
                            height: 24
                            radius: 12
                            enabled: root.backendOperational
                            color: enabled ? disconnectHover.hovered ? Colors.primary : Colors.primary : Colors.surfaceContainerHighest
                            opacity: enabled ? 1 : 0.45

                            Text {
                                id: disconnectLabel
                                anchors.centerIn: parent
                                text: "Disconnect"
                                font.family: Fonts.font
                                font.pixelSize: 9
                                font.bold: true
                                color: Colors.on_Primary
                            }

                            HoverHandler {
                                id: disconnectHover
                                enabled: root.backendOperational
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: root.backendOperational
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (!root.backendOperational)
                                        return;
                                    NetworkService.bluetooth.disconnect(modelData.address);
                                }
                            }
                        }
                    }
                }
            }

            Text {
                visible: btPairedModel.values.length > 0
                text: "Paired devices"
                font.family: Fonts.font
                font.pixelSize: 10
                font.bold: true
                color: Colors.on_SurfaceVariant
                topPadding: 6
            }

            Repeater {
                model: btPairedModel
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 10
                    color: pairedHover.hovered ? Colors.surfaceContainerHighest : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.hoverFadeDuration
                        }
                    }
                    HoverHandler {
                        id: pairedHover
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 10
                        }
                        spacing: 9

                        Text {
                            text: "󰂯"
                            font.family: Fonts.fontM
                            font.pixelSize: 16
                            color: Colors.on_SurfaceVariant
                        }

                        Text {
                            text: modelData.name
                            font.family: Fonts.font
                            font.pixelSize: 11
                            color: Colors.on_SurfaceVariant
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: connectLabel.implicitWidth + 18
                            height: 24
                            radius: 12
                            enabled: root.backendOperational && !NetworkService.bluetooth.isConnecting(modelData.address)
                            color: !enabled ? Colors.surfaceContainerHighest : pairedConnectHover.hovered ? Colors.primary : Colors.primaryContainer
                            opacity: enabled ? 1 : 0.45

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.hoverFadeDuration
                                }
                            }
                            HoverHandler {
                                id: pairedConnectHover
                                enabled: root.backendOperational && !NetworkService.bluetooth.isConnecting(modelData.address)
                            }

                            Text {
                                id: connectLabel
                                anchors.centerIn: parent
                                text: NetworkService.bluetooth.isConnecting(modelData.address) ? "Connecting..." : "Connect"
                                font.family: Fonts.font
                                font.pixelSize: 9
                                font.bold: true
                                color: !parent.enabled ? Colors.on_SurfaceVariant : pairedConnectHover.hovered ? Colors.on_Primary : Colors.on_PrimaryContainer
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: root.backendOperational && !NetworkService.bluetooth.isConnecting(modelData.address)
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (!root.backendOperational)
                                        return;
                                    NetworkService.bluetooth.connect(modelData.address);
                                }
                            }
                        }

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            enabled: root.backendOperational
                            color: enabled && removeHover.hovered ? Colors.errorContainer : "transparent"
                            opacity: enabled ? 1 : 0.45

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.hoverFadeDuration
                                }
                            }
                            HoverHandler {
                                id: removeHover
                                enabled: root.backendOperational
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰆴"
                                font.family: Fonts.fontM
                                font.pixelSize: 13
                                color: removeHover.hovered ? Colors.on_ErrorContainer : Colors.outline
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: root.backendOperational
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (!root.backendOperational)
                                        return;
                                    NetworkService.bluetooth.remove(modelData.address);
                                }
                            }
                        }
                    }
                }
            }

            Text {
                visible: btAvailableModel.values.length > 0
                text: "Nearby devices"
                font.family: Fonts.font
                font.pixelSize: 10
                font.bold: true
                color: Colors.on_SurfaceVariant
                topPadding: 6
            }

            Repeater {
                model: btAvailableModel
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 10
                    color: availableHover.hovered ? Colors.surfaceContainerHighest : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.hoverFadeDuration
                        }
                    }
                    HoverHandler {
                        id: availableHover
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 10
                        }

                        spacing: 9

                        Text {
                            text: "󰂯"
                            font.family: Fonts.fontM
                            font.pixelSize: 16
                            color: Colors.on_SurfaceVariant
                        }

                        Text {
                            text: modelData.name
                            font.family: Fonts.font
                            font.pixelSize: 11
                            color: Colors.on_SurfaceVariant
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: pairLabel.implicitWidth + 18
                            height: 24
                            radius: 12
                            enabled: root.backendOperational
                            color: !enabled ? Colors.surfaceContainerHighest : NetworkService.bluetooth.isPairing(modelData.address) ? Colors.surfaceContainerHighest : availablePairHover.hovered ? Colors.primaryContainer : Colors.primary
                            opacity: enabled ? 1 : 0.45
                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.hoverFadeDuration
                                }
                            }
                            HoverHandler {
                                id: availablePairHover
                                enabled: root.backendOperational
                            }

                            Text {
                                id: pairLabel
                                anchors.centerIn: parent
                                text: NetworkService.bluetooth.isPairing(modelData.address) ? "Cancel" : "Pair"
                                font.family: Fonts.font
                                font.pixelSize: 9
                                font.bold: true
                                color: !parent.enabled ? Colors.on_SurfaceVariant : NetworkService.bluetooth.isPairing(modelData.address) ? availablePairHover.hovered ? Colors.on_ErrorContainer : Colors.surfaceContainerHighest : availablePairHover.hovered ? Colors.on_PrimaryContainer : Colors.on_Primary
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: root.backendOperational
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (!root.backendOperational)
                                        return;
                                    if (NetworkService.bluetooth.isPairing(modelData.address)) {
                                        NetworkService.bluetooth.cancelPair(modelData.address);
                                    } else {
                                        NetworkService.bluetooth.pair(modelData.address);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text {
                visible: root.backendOperational && NetworkService.bluetooth.enabled && btConnectedModel.values.length === 0 && btPairedModel.values.length === 0 && btAvailableModel.values.length === 0
                Layout.alignment: Qt.AlignHCenter
                text: "No Bluetooth devices"
                font.family: Fonts.font
                font.pixelSize: 10
                color: Colors.outline
                topPadding: 12
                bottomPadding: 12
            }

            Text {
                visible: root.backendOperational && NetworkService.bluetooth.available && !NetworkService.bluetooth.operational && (NetworkService.bluetooth.enabling || NetworkService.bluetooth.disabling || NetworkService.bluetooth.blocked || NetworkService.bluetooth.state === BluetoothAdapterState.Disabled)
                Layout.alignment: Qt.AlignHCenter
                text: NetworkService.bluetooth.enabling ? "Bluetooth is starting…" : NetworkService.bluetooth.disabling ? "Bluetooth is turning off…" : NetworkService.bluetooth.blocked ? "Bluetooth is blocked" : "Bluetooth is disabled"
                font.family: Fonts.font
                font.pixelSize: 10
                color: Colors.outline
                topPadding: 12
                bottomPadding: 12
            }
        }
    }
}
