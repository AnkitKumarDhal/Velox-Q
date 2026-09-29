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
            id: signalIcon

            text: {
                if (root.network.state === ConnectionState.Connecting)
                    return "󱑤";
                if (root.network.state === ConnectionState.Disconnecting)
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

            color: {
                if (root.network.stateChanging)
                    return Colors.primary;
                if (root.network.connected)
                    return Colors.primary;
                return Colors.on_SurfaceVariant;
            }

            opacity: root.network.stateChanging ? 0.55 : 1

            SequentialAnimation on opacity {
                running: root.network.stateChanging
                loops: Animation.Infinite

                NumberAnimation {
                    to: 1
                    duration: Theme.motionNormal
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    to: 0.55
                    duration: Theme.motionNormal
                    easing.type: Easing.InOutSine
                }
            }
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
            width: stateContent.implicitWidth + 16
            height: 22
            radius: 11
            color: root.network.connected && !root.network.stateChanging ? Colors.primary : Colors.surfaceContainerHighest

            RowLayout {
                id: stateContent
                anchors.centerIn: parent
                spacing: Theme.spacingXs

                Item {
                    visible: root.network.stateChanging
                    width: 10
                    height: 10

                    Rectangle {
                        anchors.fill: parent
                        radius: 5
                        color: "transparent"
                        border.width: 1
                        border.color: Colors.outline
                        opacity: 0.45
                    }

                    Rectangle {
                        width: 3
                        height: 5
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
                            running: root.network.stateChanging
                        }
                    }
                }

                Text {
                    id: stateLabel

                    text: {
                        if (root.network.connected && root.network.stateChanging)
                            return "Disconnecting…";
                        if (root.network.stateChanging)
                            return "Connecting…";
                        return "Connected";
                    }

                    font.family: Fonts.font
                    font.pixelSize: 9
                    font.bold: true
                    color: root.network.connected && !root.network.stateChanging ? Colors.on_Primary : Colors.on_SurfaceVariant
                }
            }
        }
    }
}
