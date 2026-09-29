import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Networking

import qs.src.services
import qs.src.theme
import qs.src.components

ColumnLayout {
    id: root

    property var selectedNetwork: null
    property var pendingKnownNetwork: null
    property bool showPassword: false
    property string connectionError: ""
    property var connectionErrorNetwork: null
    property real selectionSourceY: -1
    property real selectionIntroOffsetY: 0
    property real selectionIntroOpacity: 1
    property real selectionIntroScale: 1

    readonly property var capability: NetworkService.wifiCapability
    readonly property bool operational: root.capability.operational
    readonly property bool backendFailure: root.capability.backendFailure
    readonly property bool hardwareAvailable: root.capability.hardwareAvailable
    signal networkSelected(var network)

    readonly property bool selectedNetworkSupportsPsk: root.selectedNetwork !== null && (root.selectedNetwork.security === WifiSecurityType.WpaPsk || root.selectedNetwork.security === WifiSecurityType.Wpa2Psk || root.selectedNetwork.security === WifiSecurityType.Sae)

    Layout.fillWidth: true
    spacing: Theme.spacingMd

    onSelectedNetworkChanged: {
        root.showPassword = false;
        root.connectionError = "";
        root.connectionErrorNetwork = null;
        selectionIntroAnimation.stop();

        if (root.selectedNetwork === null) {
            root.selectionSourceY = -1;
            root.selectionIntroOffsetY = 0;
            root.selectionIntroOpacity = 1;
            root.selectionIntroScale = 1;
            return;
        }

        if (root.selectionSourceY >= 0) {
            root.selectionIntroOffsetY = 0;
            root.selectionIntroOpacity = 0;
            root.selectionIntroScale = 0.96;

            Qt.callLater(function () {
                if (!root.selectedNetwork || root.selectionSourceY < 0)
                    return;

                const targetY = selectionSection.mapToItem(wifiContent, 0, 0).y;

                root.selectionIntroOffsetY = root.selectionSourceY - targetY;
                selectionIntroAnimation.restart();
            });
        } else {
            root.selectionIntroOffsetY = 0;
            root.selectionIntroOpacity = 1;
            root.selectionIntroScale = 1;
        }

        if (root.selectedNetworkSupportsPsk) {
            Qt.callLater(function () {
                if (root.operational && root.selectedNetwork !== null)
                    passwordField.forceActiveFocus();
            });
        }
    }

    ParallelAnimation {
        id: selectionIntroAnimation

        NumberAnimation {
            target: root
            property: "selectionIntroOffsetY"
            to: 0
            duration: Theme.motionMedium
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "selectionIntroOpacity"
            to: 1
            duration: Theme.motionFast
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "selectionIntroScale"
            to: 1
            duration: Theme.motionSmooth
            easing.type: Easing.OutBack
        }

        onFinished: root.selectionSourceY = -1
    }

    Connections {
        target: root.pendingKnownNetwork

        function onConnectionFailed(reason) {
            if (root.pendingKnownNetwork === null)
                return;

            if (reason === ConnectionFailReason.NoSecrets) {
                root.selectedNetwork = root.pendingKnownNetwork;
                root.pendingKnownNetwork = null;
                return;
            }

            root.connectionErrorNetwork = root.pendingKnownNetwork;
            root.connectionError = "Connection failed. Try again.";
            root.selectedNetwork = root.pendingKnownNetwork;
            root.pendingKnownNetwork = null;
        }
    }

    Connections {
        target: root.selectedNetwork

        function onConnectionFailed(reason) {
            if (!root.selectedNetwork)
                return;

            if (reason === ConnectionFailReason.NoSecrets) {
                root.connectionError = "";
                Qt.callLater(function () {
                    if (root.selectedNetwork !== null && root.selectedNetworkSupportsPsk)
                        passwordField.forceActiveFocus();
                });
                return;
            }

            root.connectionErrorNetwork = root.selectedNetwork;
            root.connectionError = "Connection failed. Check the network and try again.";
        }
    }

    ScriptModel {
        id: wifiConnectedModel
        objectProp: "name"
        values: {
            if (!root.operational || !NetworkService.wifiDevice)
                return [];

            return [...NetworkService.wifiDevice.networks.values].filter(network => network.connected).sort((a, b) => b.signalStrength - a.signalStrength);
        }
    }

    ScriptModel {
        id: wifiAvailableModel
        objectProp: "name"
        values: {
            if (!root.operational || !NetworkService.wifiDevice)
                return [];

            return [...NetworkService.wifiDevice.networks.values].filter(network => !network.connected && network !== root.selectedNetwork).sort((a, b) => b.signalStrength - a.signalStrength);
        }
    }

    Rectangle {
        visible: root.backendFailure
        Layout.fillWidth: true
        implicitHeight: capabilityErrorColumn.implicitHeight + 20
        radius: 12
        color: Colors.errorContainer
        border.width: 1
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
                    text: "󰅙"
                    font.family: Fonts.fontM
                    font.pixelSize: 17
                    color: Colors.on_ErrorContainer
                }

                Text {
                    text: "Wi-Fi backend unavailable"
                    font.family: Fonts.font
                    font.pixelSize: 11
                    font.bold: true
                    color: Colors.on_ErrorContainer
                    Layout.fillWidth: true
                }
            }

            Text {
                text: root.capability.errorMessage || "The Wi-Fi backend could not be reached."
                font.family: Fonts.font
                font.pixelSize: 9
                color: Colors.on_ErrorContainer
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }
    }

    Rectangle {
        visible: root.hardwareAvailable && !root.backendFailure && !root.operational
        Layout.fillWidth: true
        implicitHeight: 44
        radius: 12
        color: Colors.surfaceContainerHigh

        Text {
            anchors.centerIn: parent
            text: "Waiting for Wi-Fi backend…"
            font.family: Fonts.font
            font.pixelSize: 10
            color: Colors.outline
        }
    }

    RowLayout {
        visible: root.operational
        Layout.fillWidth: true

        Text {
            text: NetworkService.wifiScanning ? "Wi-Fi networks · Scanning" : "Wi-Fi networks"
            font.family: Fonts.font
            font.pixelSize: 14
            font.bold: true
            color: Colors.on_SurfaceVariant
            Layout.fillWidth: true
        }

        Rectangle {
            id: wifiScanButton
            Layout.preferredWidth: scanContent.implicitWidth + 20
            height: 28
            radius: Theme.radiusLg
            scale: wifiScanMouse.pressed ? 0.94 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.motionFast
                    easing.type: Easing.OutCubic
                }
            }
            color: Colors.surfaceContainerHighest

            InteractionFeedback {
                hovered: wifiScanHover.hovered
                pressed: wifiScanMouse.pressed
                radius: parent.radius
                hoverColor: Colors.primary
            }

            RowLayout {
                id: scanContent
                anchors.centerIn: parent
                spacing: Theme.spacingXs

                Item {
                    visible: NetworkService.wifiScanning

                    width: 9
                    height: 9

                    Rectangle {
                        anchors.fill: parent
                        radius: 4.5
                        color: "transparent"
                        border.width: 1
                        border.color: wifiScanHover.hovered ? Colors.on_Primary : Colors.on_PrimaryContainer
                        opacity: 0.45
                    }

                    Rectangle {
                        width: 2.5
                        height: 4
                        radius: 1.25
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        color: wifiScanHover.hovered ? Colors.on_Primary : Colors.on_PrimaryContainer
                        transformOrigin: Item.Bottom

                        RotationAnimation on rotation {
                            from: 0
                            to: 360
                            duration: Theme.motionAmbient
                            loops: Animation.Infinite
                            running: NetworkService.wifiScanning
                        }
                    }
                }

                Text {
                    id: wifiScanLabel

                    text: NetworkService.wifiScanning ? "Scanning…" : "Scan"

                    font.family: Fonts.font
                    font.pixelSize: 10
                    font.bold: true

                    color: wifiScanHover.hovered ? Colors.on_Primary : Colors.on_Surface
                }
            }

            HoverHandler {
                id: wifiScanHover
                enabled: root.operational
            }

            MouseArea {
                id: wifiScanMouse

                anchors.fill: parent
                enabled: root.operational && NetworkService.wifiEnabled
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                onClicked: {
                    if (!root.operational || !NetworkService.wifiEnabled)
                        return;

                    NetworkService.scanWifi();
                }
            }
        }
    }

    Flickable {
        visible: root.operational && NetworkService.wifiEnabled
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(wifiContent.implicitHeight, 320)
        contentHeight: wifiContent.implicitHeight

        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: wifiContent

            width: parent.width
            spacing: Theme.spacingSm

            Text {
                visible: wifiConnectedModel.values.length > 0
                text: "Connected"

                font.family: Fonts.font
                font.pixelSize: 10
                font.bold: true

                color: Colors.on_SurfaceVariant

                topPadding: 2
                bottomPadding: 2
            }

            Repeater {
                model: wifiConnectedModel

                delegate: NetworkRow {
                    required property var modelData

                    Layout.fillWidth: true
                    network: modelData
                    onNetworkSelected: network => {
                        if (!root.operational)
                            return;
                        root.networkSelected(network);
                    }
                }
            }

            ColumnLayout {
                id: selectionSection

                visible: root.selectedNetwork !== null

                Layout.fillWidth: true
                spacing: 0
                z: 10

                opacity: root.selectionIntroOpacity
                scale: root.selectionIntroScale
                transformOrigin: Item.Top

                transform: Translate {
                    y: root.selectionIntroOffsetY
                }

                Text {
                    text: "Connect"
                    font.family: Fonts.font
                    font.pixelSize: 10
                    font.bold: true
                    color: Colors.on_SurfaceVariant
                    topPadding: 6
                    bottomPadding: 2
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: selectedEditorColumn.implicitHeight + 20
                    radius: 12
                    color: Colors.primaryContainer
                    border.width: 1
                    border.color: Colors.primary

                    ColumnLayout {
                        id: selectedEditorColumn

                        anchors {
                            fill: parent
                            margins: Theme.spacingLg
                        }

                        spacing: Theme.spacingMd

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingMd

                            Item {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 28

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰤨"
                                    font.family: Fonts.fontM
                                    font.pixelSize: 18
                                    color: Colors.on_PrimaryContainer
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: root.selectedNetwork?.name ?? ""
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    font.family: Fonts.font
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: Colors.on_PrimaryContainer
                                }

                                Text {
                                    text: {
                                        if (root.connectionError.length > 0)
                                            return "Connection failed";
                                        if (root.selectedNetwork?.stateChanging)
                                            return "Connecting…";
                                        if (root.selectedNetworkSupportsPsk)
                                            return "Enter Wi-Fi password";
                                        return "Additional authentication may be required";
                                    }
                                    font.family: Fonts.font
                                    font.pixelSize: 9

                                    color: root.connectionError.length > 0 ? Colors.error : Colors.on_PrimaryContainer
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                width: 28
                                height: 28
                                radius: Theme.radiusLg
                                scale: closeConnectMouse.pressed ? 0.94 : 1

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Theme.motionFast
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                color: "transparent"

                                InteractionFeedback {
                                    hovered: closeConnectHover.hovered
                                    pressed: closeConnectMouse.pressed
                                    radius: parent.radius
                                    hoverColor: Colors.surfaceContainerHighest
                                }

                                HoverHandler {
                                    id: closeConnectHover
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰅖"
                                    font.family: Fonts.fontM
                                    font.pixelSize: 14
                                    color: Colors.on_PrimaryContainer
                                }

                                MouseArea {
                                    id: closeConnectMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.networkSelected(null)
                                }
                            }
                        }

                        Rectangle {
                            visible: root.connectionError.length > 0
                            Layout.fillWidth: true
                            implicitHeight: connectionErrorColumn.implicitHeight + 12

                            radius: Theme.radiusSm
                            color: Colors.errorContainer
                            border.width: 1
                            border.color: Colors.error

                            opacity: visible ? 1 : 0
                            scale: visible ? 1 : 0.96

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.motionFast
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Theme.motionSmooth
                                    easing.type: Easing.OutBack
                                }
                            }

                            ColumnLayout {
                                id: connectionErrorColumn

                                anchors {
                                    fill: parent
                                    margins: Theme.spacingSm
                                }

                                spacing: Theme.spacingXs

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.spacingSm

                                    Text {
                                        text: "󰅙"
                                        color: Colors.on_ErrorContainer
                                        font.family: Fonts.fontM
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: root.connectionError
                                        color: Colors.on_ErrorContainer
                                        font.family: Fonts.font
                                        font.pixelSize: 9
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 28
                                    radius: Theme.radiusSm

                                    color: Colors.primaryContainer

                                    InteractionFeedback {
                                        hovered: retryConnectionMouse.containsMouse
                                        pressed: retryConnectionMouse.pressed
                                        radius: parent.radius
                                        hoverColor: Colors.primary
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Retry"
                                        color: retryConnectionMouse.containsMouse ? Colors.on_Primary : Colors.on_PrimaryContainer
                                        font.family: Fonts.font
                                        font.pixelSize: 9
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: retryConnectionMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        enabled: root.selectedNetwork !== null && root.operational
                                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                                        onClicked: {
                                            if (!root.selectedNetwork || !root.operational)
                                                return;

                                            root.connectionError = "";

                                            if (root.selectedNetworkSupportsPsk) {
                                                if (passwordField.text.length <= 0) {
                                                    passwordField.forceActiveFocus();
                                                    return;
                                                }

                                                root.selectedNetwork.connectWithPsk(passwordField.text);
                                                passwordField.text = "";
                                                return;
                                            }

                                            root.selectedNetwork.connect();
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            visible: root.selectedNetworkSupportsPsk
                            enabled: root.operational && !root.selectedNetwork?.stateChanging
                            Layout.fillWidth: true
                            spacing: Theme.spacingMd

                            TextField {
                                id: passwordField

                                Layout.fillWidth: true
                                height: 34
                                rightPadding: 42
                                placeholderText: "Password"
                                echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                                font.family: Fonts.font
                                font.pixelSize: 11
                                color: Colors.on_Surface
                                placeholderTextColor: Colors.outline

                                background: Rectangle {
                                    radius: Theme.radiusSm
                                    color: Colors.surfaceContainer
                                    border.width: passwordField.activeFocus ? 1 : 0
                                    border.color: Colors.primary
                                }

                                Rectangle {
                                    id: passwordVisibilityButton

                                    anchors {
                                        top: parent.top
                                        right: parent.right
                                        bottom: parent.bottom
                                    }

                                    width: 42
                                    color: "transparent"

                                    z: 10

                                    HoverHandler {
                                        id: passwordVisibilityHover
                                        cursorShape: Qt.PointingHandCursor
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: root.showPassword ? "󰈉" : "󰈈"
                                        font.family: Fonts.fontM
                                        font.pixelSize: 15
                                        color: passwordVisibilityHover.hovered ? Colors.primary : Colors.outline
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        z: 1
                                        acceptedButtons: Qt.LeftButton
                                        cursorShape: Qt.PointingHandCursor
                                        onPressed: mouse => mouse.accepted = true
                                        onReleased: mouse => mouse.accepted = true
                                        onClicked: mouse => {
                                            mouse.accepted = true;
                                            root.showPassword = !root.showPassword;
                                            passwordField.forceActiveFocus();
                                        }
                                    }
                                }

                                Keys.onReturnPressed: {
                                    if (root.operational && root.selectedNetworkSupportsPsk && text.length > 0) {
                                        root.selectedNetwork.connectWithPsk(text);
                                        text = "";
                                    }
                                }

                                Component.onCompleted: {
                                    if (root.operational)
                                        forceActiveFocus();
                                }
                            }

                            Rectangle {
                                width: 26
                                height: 26
                                radius: root.selectedNetwork?.stateChanging ? 15 : Theme.radiusSm
                                opacity: root.operational ? 1 : 0.45
                                scale: confirmMouse.pressed ? 0.94 : 1
                                enabled: root.operational && !root.selectedNetwork?.stateChanging

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Theme.motionFast
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                color: confirmHover.hovered ? Colors.primary : Colors.on_Surface

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.hoverFadeDuration
                                    }
                                }

                                HoverHandler {
                                    id: confirmHover
                                    enabled: root.operational
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: root.selectedNetwork?.stateChanging ? "󰑣" : "󰌑"
                                    font.family: Fonts.font
                                    font.pixelSize: 14
                                    color: Colors.on_Primary
                                }

                                RotationAnimation on rotation {
                                    from: 0
                                    to: 360
                                    duration: Theme.motionAmbient
                                    loops: Animation.Infinite
                                    running: root.selectedNetwork?.stateChanging ?? false
                                }

                                MouseArea {
                                    id: confirmMouse
                                    anchors.fill: parent
                                    enabled: root.operational
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                                    onClicked: {
                                        if (!root.operational || !root.selectedNetworkSupportsPsk || passwordField.text.length <= 0) {
                                            return;
                                        }
                                        root.selectedNetwork.connectWithPsk(passwordField.text);
                                        passwordField.text = "";
                                    }
                                }
                            }
                        }

                        Rectangle {
                            visible: root.selectedNetwork !== null && !root.selectedNetworkSupportsPsk && root.selectedNetwork.security !== WifiSecurityType.Open
                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: Theme.radiusSm
                            color: Colors.surfaceContainer

                            Text {
                                anchors.centerIn: parent
                                text: "This network does not use PSK authentication."
                                font.family: Fonts.font
                                font.pixelSize: 9
                                color: Colors.on_SurfaceVariant
                            }
                        }
                    }
                }
            }

            Text {
                visible: wifiAvailableModel.values.length > 0
                text: "Available"
                font.family: Fonts.font
                font.pixelSize: 10
                font.bold: true
                color: Colors.on_SurfaceVariant
                topPadding: 6
                bottomPadding: 2
            }

            Repeater {
                model: wifiAvailableModel

                delegate: NetworkRow {
                    required property var modelData
                    Layout.fillWidth: true
                    network: modelData

                    onNetworkSelected: network => {
                        if (!root.operational)
                            return;
                        if (network.security === WifiSecurityType.Open) {
                            network.connect();
                            return;
                        }

                        root.selectionSourceY = y;

                        if (network.known) {
                            root.pendingKnownNetwork = network;
                            network.connect();
                            return;
                        }

                        root.networkSelected(network);
                    }
                }
            }

            Text {
                visible: wifiConnectedModel.values.length === 0 && root.selectedNetwork === null && wifiAvailableModel.values.length === 0
                Layout.alignment: Qt.AlignHCenter

                text: NetworkService.wifiScanning ? "Scanning…" : "No Wi-Fi networks found"

                font.family: Fonts.font
                font.pixelSize: 10

                color: Colors.outline

                topPadding: 10
                bottomPadding: 10
            }
        }
    }

    Rectangle {
        visible: root.operational && !NetworkService.wifiEnabled
        Layout.fillWidth: true
        implicitHeight: 44
        radius: 12
        color: Colors.surfaceContainerHigh

        Text {
            anchors.centerIn: parent
            text: "Wi-Fi is disabled"
            font.family: Fonts.font
            font.pixelSize: 10
            color: Colors.outline
        }
    }
}
