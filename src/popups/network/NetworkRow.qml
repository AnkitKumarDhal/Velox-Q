import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

import qs.src.components
import qs.src.theme

Item {
    id: root

    required property var network
    signal networkSelected(var network)

    implicitHeight: 46
    scale: rootHover.pressed ? 0.985 : rootHover.containsMouse ? 1.01 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Theme.motionFast
            easing.type: Easing.OutCubic
        }
    }
    opacity: root.network.stateChanging ? Theme.stateLoadingOpacity : 1

    readonly property bool supportsPsk: {
        switch (root.network.security) {
        case WifiSecurityType.WpaPsk:
        case WifiSecurityType.Wpa2Psk:
        case WifiSecurityType.Sae:
            return true;
        default:
            return false;
        }
    }

    Rectangle {
        id: background

        anchors.fill: parent
        radius: Theme.radiusMd

        color: root.network.connected ? Qt.rgba(Colors.primaryContainer.r, Colors.primaryContainer.g, Colors.primaryContainer.b, 0.28) : "transparent"

        InteractionFeedback {
            hovered: rootHover.containsMouse
            pressed: rootHover.pressed
            radius: parent.radius
        }
    }

    MouseArea {
        id: rootHover
        anchors.fill: parent
        hoverEnabled: true

        enabled: !root.network.stateChanging
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.network.connected) {
                root.network.disconnect();
            } else {
                root.networkSelected(root.network);
            }
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: Theme.spacingXl
            rightMargin: Theme.spacingXl
        }

        spacing: Theme.spacingLg

        Text {
            text: {
                if (!root.network.connected && root.network.state === ConnectionState.Connecting)
                    return "󱑤";

                const signal = root.network.signalStrength ?? 0;

                if (signal < 0.25)
                    return "󰤟";
                if (signal < 0.50)
                    return "󰤢";
                if (signal < 0.75)
                    return "󰤥";
                return "󰤨";
            }

            font.family: Fonts.fontM
            font.pixelSize: 16

            color: root.network.connected ? Colors.primary : Colors.on_SurfaceVariant
        }

        Text {
            text: root.network.name || "Unknown network"

            Layout.fillWidth: true

            elide: Text.ElideRight

            font.family: Fonts.font
            font.pixelSize: 12
            font.bold: root.network.connected

            color: root.network.connected ? Colors.on_Surface : Colors.on_SurfaceVariant
        }

        // Security indicator
        Text {
            visible: root.network.security !== WifiSecurityType.Open
            text: root.supportsPsk ? "󰌾" : "󰒃"

            font.family: Fonts.fontM
            font.pixelSize: 13

            color: Colors.outline
        }

        // Connection state
        Rectangle {
            visible: root.network.connected || root.network.stateChanging

            width: stateLabel.implicitWidth + 16
            height: 22
            radius: 11

            color: root.network.connected ? Colors.primary : Colors.surfaceContainerHighest

            Text {
                id: stateLabel

                anchors.centerIn: parent
                text: root.network.connected ? "Connected" : "Connecting"

                font.family: Fonts.font
                font.pixelSize: 9
                font.bold: true

                color: root.network.connected ? Colors.on_Primary : Colors.on_SurfaceVariant
            }
        }
    }
}
