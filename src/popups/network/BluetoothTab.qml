import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.src.components
import qs.src.services
import qs.src.theme

ColumnLayout {
    id: root

    readonly property var capability: NetworkService.bluetooth.capability
    readonly property bool hardwareAvailable: root.capability.hardwareAvailable
    readonly property bool backendFailure: root.capability.backendFailure
    readonly property bool backendOperational: root.capability.operational

    Layout.fillWidth: true
    spacing: Theme.spacingMd

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
                margins: Theme.spacingLg
            }
            spacing: Theme.spacingXs

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMd

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
            id: bluetoothScanButton
            width: scanLabel.implicitWidth + 20
            height: 28
            radius: Theme.radiusLg
            scale: bluetoothScanMouse.pressed ? 0.94 : 1
            Behavior on scale {
                NumberAnimation {
                    duration: Theme.motionFast
                    easing.type: Easing.OutCubic
                }
            }
            enabled: root.backendOperational && (NetworkService.bluetooth.operational || NetworkService.bluetooth.scanning)
            color: Colors.surfaceContainerHighest

            InteractionFeedback {
                hovered: btScanHover.hovered
                pressed: bluetoothScanMouse.pressed
                radius: parent.radius
                active: parent.enabled
                hoverColor: Colors.primary
            }

            opacity: enabled ? 1 : 0.45

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motionFast
                }
            }

            Text {
                id: scanLabel
                anchors.centerIn: parent
                text: NetworkService.bluetooth.scanning ? "Stop" : "Scan"
                font.family: Fonts.font
                font.pixelSize: 10
                font.bold: true
                color: NetworkService.bluetooth.scanning || btScanHover.hovered ? Colors.on_Primary : Colors.on_Surface
            }

            HoverHandler {
                id: btScanHover
                enabled: root.backendOperational && (NetworkService.bluetooth.operational || NetworkService.bluetooth.scanning)
            }

            MouseArea {
                id: bluetoothScanMouse
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
            spacing: Theme.spacingSm

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
                    readonly property bool deviceBusy: NetworkService.bluetooth.isDisconnecting(modelData.address)
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: Theme.radiusMd
                    scale: connectedHover.hovered ? 1.005 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.motionFast
                            easing.type: Easing.OutCubic
                        }
                    }

                    color: Qt.rgba(Colors.primaryContainer.r, Colors.primaryContainer.g, Colors.primaryContainer.b, 0.28)

                    InteractionFeedback {
                        hovered: connectedHover.hovered
                        pressed: false
                        radius: parent.radius
                    }
                    HoverHandler {
                        id: connectedHover
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: Theme.spacingXl
                            rightMargin: Theme.spacingLg
                        }
                        spacing: Theme.spacingMd

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
                            scale: disconnectMouse.pressed ? 0.94 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Theme.motionFast
                                    easing.type: Easing.OutCubic
                                }
                            }
                            enabled: root.backendOperational && !deviceBusy
                            color: Colors.primary

                            InteractionFeedback {
                                hovered: disconnectHover.hovered
                                pressed: disconnectMouse.pressed
                                radius: parent.radius
                                active: parent.enabled
                                hoverColor: Colors.on_Primary
                                pressedColor: Colors.on_Primary
                                hoverOpacity: Theme.stateHoverOpacity
                                pressedOpacity: Theme.statePressedOpacity
                            }

                            opacity: root.backendOperational ? 1 : 0.45

                            Text {
                                id: disconnectLabel
                                anchors.centerIn: parent
                                text: deviceBusy ? "Disconnecting..." : "Disconnect"
                                font.family: Fonts.font
                                font.pixelSize: 9
                                font.bold: true
                                color: disconnectHover.hovered && !deviceBusy ? Colors.on_Primary : Colors.on_Primary
                            }

                            HoverHandler {
                                id: disconnectHover
                                enabled: root.backendOperational
                            }

                            MouseArea {
                                id: disconnectMouse
                                anchors.fill: parent
                                enabled: root.backendOperational && !deviceBusy
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
                    readonly property bool deviceBusy: NetworkService.bluetooth.isConnecting(modelData.address) || NetworkService.bluetooth.isDisconnecting(modelData.address)
                    readonly property bool deviceBlocked: modelData.blocked
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: Theme.radiusMd
                    scale: pairedHover.hovered ? 1.005 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.motionFast
                            easing.type: Easing.OutCubic
                        }
                    }

                    color: "transparent"

                    InteractionFeedback {
                        hovered: pairedHover.hovered
                        pressed: false
                        radius: parent.radius
                    }
                    HoverHandler {
                        id: pairedHover
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: Theme.spacingXl
                            rightMargin: Theme.spacingLg
                        }
                        spacing: Theme.spacingMd

                        Text {
                            text: "󰂯"
                            font.family: Fonts.fontM
                            font.pixelSize: 16
                            color: Colors.on_SurfaceVariant
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: modelData.name
                                font.family: Fonts.font
                                font.pixelSize: 11
                                color: Colors.on_SurfaceVariant
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: deviceBusy || deviceBlocked
                                text: deviceBlocked ? "Blocked" : NetworkService.bluetooth.deviceStateText(modelData.address)
                                font.family: Fonts.font
                                font.pixelSize: 8
                                color: deviceBlocked ? Colors.error : Colors.primary
                            }
                        }

                        Rectangle {
                            width: connectLabel.implicitWidth + 18
                            height: 24
                            radius: 12
                            scale: connectMouse.pressed ? 0.94 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Theme.motionFast
                                    easing.type: Easing.OutCubic
                                }
                            }
                            enabled: root.backendOperational && !deviceBusy && !deviceBlocked
                            color: !enabled ? Colors.surfaceContainerHighest : Colors.primaryContainer
                            opacity: enabled ? 1 : 0.45

                            InteractionFeedback {
                                hovered: pairedConnectHover.hovered
                                pressed: connectMouse.pressed
                                radius: parent.radius
                                active: parent.enabled
                                hoverColor: Colors.primary
                            }

                            HoverHandler {
                                id: pairedConnectHover
                                enabled: root.backendOperational && !deviceBusy && !deviceBlocked
                            }

                            Text {
                                id: connectLabel
                                anchors.centerIn: parent
                                text: deviceBlocked ? "Blocked" : deviceBusy ? NetworkService.bluetooth.deviceStateText(modelData.address) : "Connect"
                                font.family: Fonts.font
                                font.pixelSize: 9
                                font.bold: true
                                color: !parent.enabled ? Colors.on_SurfaceVariant : pairedConnectHover.hovered ? Colors.on_Primary : Colors.on_PrimaryContainer
                            }

                            MouseArea {
                                id: connectMouse
                                anchors.fill: parent
                                enabled: root.backendOperational && !deviceBusy && !deviceBlocked
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
                            scale: removeMouse.pressed ? 0.94 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Theme.motionFast
                                    easing.type: Easing.OutCubic
                                }
                            }
                            enabled: root.backendOperational
                            color: "transparent"
                            opacity: enabled ? 1 : 0.45

                            InteractionFeedback {
                                hovered: removeHover.hovered
                                pressed: removeMouse.pressed
                                radius: parent.radius
                                active: parent.enabled
                                hoverColor: Colors.errorContainer
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
                                id: removeMouse
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
                    readonly property bool deviceBusy: NetworkService.bluetooth.isPairing(modelData.address)
                    readonly property bool deviceBlocked: modelData.blocked
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: Theme.radiusMd
                    scale: availableHover.hovered ? 1.005 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.motionFast
                            easing.type: Easing.OutCubic
                        }
                    }

                    color: "transparent"

                    InteractionFeedback {
                        hovered: availableHover.hovered
                        pressed: false
                        radius: parent.radius
                    }
                    HoverHandler {
                        id: availableHover
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: Theme.spacingXl
                            rightMargin: Theme.spacingLg
                        }

                        spacing: Theme.spacingMd

                        Text {
                            text: "󰂯"
                            font.family: Fonts.fontM
                            font.pixelSize: 16
                            color: deviceBusy ? Colors.primary : Colors.on_SurfaceVariant

                            SequentialAnimation on opacity {
                                running: deviceBusy
                                loops: Animation.Infinite

                                NumberAnimation {
                                    to: 1
                                    duration: Theme.motionNormal
                                    easing.type: Easing.InOutSine
                                }

                                NumberAnimation {
                                    to: 0.45
                                    duration: Theme.motionNormal
                                    easing.type: Easing.InOutSine
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: modelData.name
                                font.family: Fonts.font
                                font.pixelSize: 11
                                color: Colors.on_SurfaceVariant
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: deviceBusy || deviceBlocked
                                text: deviceBlocked ? "Blocked" : "Pairing…"
                                font.family: Fonts.font
                                font.pixelSize: 8
                                color: deviceBlocked ? Colors.error : Colors.primary
                            }
                        }

                        Rectangle {
                            implicitWidth: pairLabel.implicitWidth + 18
                            width: implicitWidth
                            Layout.preferredWidth: implicitWidth
                            Layout.minimumWidth: implicitWidth
                            Layout.maximumWidth: implicitWidth
                            height: 24
                            radius: 12
                            scale: pairMouse.pressed ? 0.94 : 1
                            Behavior on scale {
                                NumberAnimation {
                                    duration: Theme.motionFast
                                    easing.type: Easing.OutCubic
                                }
                            }
                            enabled: root.backendOperational && !deviceBlocked
                            color: !enabled || NetworkService.bluetooth.isPairing(modelData.address) ? Colors.surfaceContainerHighest : Colors.primary

                            opacity: enabled ? 1 : 0.45

                            InteractionFeedback {
                                hovered: availablePairHover.hovered
                                pressed: pairMouse.pressed
                                radius: parent.radius
                                active: parent.enabled && !NetworkService.bluetooth.isPairing(modelData.address)
                                hoverColor: Colors.primaryContainer
                                pressedColor: Colors.primary
                            }

                            HoverHandler {
                                id: availablePairHover
                                enabled: root.backendOperational
                            }

                            Text {
                                id: pairLabel
                                anchors.centerIn: parent
                                text: deviceBlocked ? "Blocked" : deviceBusy ? "Cancel pairing" : "Pair"
                                font.family: Fonts.font
                                font.pixelSize: 9
                                font.bold: true
                                color: !parent.enabled ? Colors.on_SurfaceVariant : NetworkService.bluetooth.isPairing(modelData.address) ? availablePairHover.hovered ? Colors.on_ErrorContainer : Colors.surfaceContainerHighest : availablePairHover.hovered ? Colors.on_PrimaryContainer : Colors.on_Primary
                            }

                            MouseArea {
                                id: pairMouse
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
                opacity: NetworkService.bluetooth.powerTransitioning ? 0.55 : 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.motionFast
                        easing.type: Easing.OutCubic
                    }
                }
                font.family: Fonts.font
                font.pixelSize: 10
                color: Colors.outline
                topPadding: 12
                bottomPadding: 12
            }

            Rectangle {
                visible: NetworkService.bluetooth.powerTransitioning

                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                Layout.alignment: Qt.AlignHCenter

                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    radius: 9
                    border.width: 1
                    border.color: Colors.outline
                    opacity: 0.4
                }

                Rectangle {
                    width: 3
                    height: 7
                    radius: 1.5

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top

                    color: Colors.primary

                    transformOrigin: Item.Bottom

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: Theme.motionAmbient
                        loops: Animation.Infinite
                        running: NetworkService.bluetooth.powerTransitioning
                    }
                }
            }
        }
    }
}
