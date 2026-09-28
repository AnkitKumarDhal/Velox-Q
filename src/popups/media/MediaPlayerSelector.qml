import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.src.components
import qs.src.theme
import qs.src.services

Item {
    id: root

    required property var player

    readonly property var players: MediaService.players
    readonly property var selectorModel: [
        {
            automatic: true
        }
    ].concat(root.players)

    property bool open: false

    implicitWidth: selectorButton.implicitWidth
    implicitHeight: selectorButton.height

    Rectangle {
        id: selectorButton

        implicitWidth: playerRow.implicitWidth + 12
        height: 18
        radius: 9

        scale: buttonMouse.pressed ? 0.985 : buttonMouse.containsMouse ? 1.01 : 1

        Behavior on scale {
            NumberAnimation {
                duration: Theme.motionFast
                easing.type: Easing.OutCubic
            }
        }

        color: "transparent"

        InteractionFeedback {
            hovered: buttonMouse.containsMouse
            pressed: buttonMouse.pressed
            radius: parent.radius
            hoverColor: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.stateHoverOpacity)
        }

        RowLayout {
            id: playerRow

            anchors.fill: parent
            anchors.leftMargin: Theme.spacingMd
            anchors.rightMargin: Theme.spacingMd
            spacing: Theme.spacingXs

            Image {
                Layout.preferredWidth: 12
                Layout.preferredHeight: 12
                width: 12
                height: 12
                source: root.player?.desktopEntry ? Quickshell.iconPath(root.player.desktopEntry, true) : ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                asynchronous: true
                visible: status === Image.Ready
            }

            Text {
                visible: root.player === null || (root.player?.desktopEntry || "") === ""
                text: "󰎆"
                color: Colors.on_SurfaceVariant
                font.family: Fonts.fontM
                font.pixelSize: 9
            }

            Rectangle {
                width: 5
                height: 5
                radius: 2.5
                color: root.player ? root.player.playbackState === MprisPlaybackState.Playing ? Colors.primary : Colors.on_SurfaceVariant : Colors.outline
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: root.player?.identity || "No player"
                color: Colors.on_SurfaceVariant
                font.family: Fonts.font
                font.pixelSize: 8
                font.bold: true
                elide: Text.ElideRight
                maximumLineCount: 1
                Layout.maximumWidth: 115
            }

            Text {
                visible: root.players.length > 1
                text: root.open ? "󰅃" : "󰅀"
                color: Colors.outline
                font.family: Fonts.fontM
                font.pixelSize: 8
            }
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            enabled: root.players.length > 1
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: root.open = !root.open
        }
    }

    Rectangle {
        id: selectorMenu

        x: selectorButton.width - width
        y: selectorButton.height + 4
        width: 160
        height: Math.min(root.selectorModel.length * 30 + 8, 170)
        radius: Theme.radiusMd
        color: Colors.surfaceContainerHigh
        border.color: Colors.outlineVariant
        border.width: 1
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.94
        transformOrigin: Item.TopRight
        visible: root.open || opacity > 0
        z: 100

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
            anchors {
                fill: parent
                margins: Theme.spacingXs
            }

            spacing: 1

            Repeater {
                model: root.selectorModel

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: Theme.radiusSm

                    readonly property bool automatic: modelData?.automatic === true
                    readonly property bool isActive: !automatic && modelData === MediaService.activePlayer
                    readonly property bool isSelected: automatic ? !MediaService.hasExplicitSelection : MediaService.hasExplicitSelection && modelData === MediaService.activePlayer

                    scale: itemMouse.pressed ? 0.985 : itemMouse.containsMouse ? 1.01 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.motionFast
                            easing.type: Easing.OutCubic
                        }
                    }

                    color: isSelected ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.stateSelectedOpacity) : "transparent"

                    InteractionFeedback {
                        hovered: itemMouse.containsMouse
                        pressed: itemMouse.pressed
                        radius: parent.radius
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingSm
                        anchors.rightMargin: Theme.spacingSm
                        spacing: Theme.spacingSm

                        Rectangle {
                            width: 3
                            height: 16
                            radius: 1.5
                            color: isActive ? Colors.primary : "transparent"
                        }

                        Image {
                            visible: !automatic && modelData.desktopEntry !== ""
                            Layout.preferredWidth: 14
                            Layout.preferredHeight: 14
                            width: 14
                            height: 14
                            source: !automatic && modelData.desktopEntry ? Quickshell.iconPath(modelData.desktopEntry, true) : ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            asynchronous: true
                        }

                        Text {
                            visible: automatic || modelData?.desktopEntry === ""
                            text: automatic ? "󰒓" : "󰎆"
                            color: isSelected ? Colors.primary : Colors.on_SurfaceVariant
                            font.family: Fonts.fontM
                            font.pixelSize: 11
                        }

                        Text {
                            text: automatic ? "Automatic" : modelData.identity || "Unknown Player"
                            color: isSelected ? Colors.on_Surface : Colors.on_SurfaceVariant
                            font.family: Fonts.font
                            font.pixelSize: 8
                            font.bold: isSelected
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: isSelected
                            text: "󰄬"
                            color: Colors.primary
                            font.family: Fonts.fontM
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        id: itemMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (automatic)
                                MediaService.clearPlayerSelection();
                            else
                                MediaService.selectPlayer(modelData);

                            root.open = false;
                        }
                    }
                }
            }
        }
    }
}
