import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
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

    implicitWidth: selectorButton.implicitWidth
    implicitHeight: selectorButton.height

    Rectangle {
        id: selectorButton

        implicitWidth: playerRow.implicitWidth + 12
        height: 24
        radius: 12

        color: buttonMouse.pressed ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity) : buttonMouse.containsMouse ? Colors.surfaceContainerHighest : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.motionFast
            }
        }

        RowLayout {
            id: playerRow

            anchors.fill: parent
            anchors.leftMargin: Theme.spacingXs
            anchors.rightMargin: Theme.spacingXs
            spacing: Theme.spacingXs

            Image {
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
                width: 14
                height: 14
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
                font.pixelSize: 13
            }

            Rectangle {
                width: 6
                height: 6
                radius: 3
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
                Layout.maximumWidth: 130
            }

            Text {
                visible: root.players.length > 1
                text: "󰅀"
                color: Colors.outline
                font.family: Fonts.fontM
                font.pixelSize: 11
            }
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            enabled: root.players.length > 1
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: selectorPopup.visible = !selectorPopup.visible
        }
    }

    PopupWindow {
        id: selectorPopup

        property bool open: false

        visible: root.players.length > 1 && open

        anchor {
            window: selectorButton.QsWindow.window
            adjustment: PopupAdjustment.None
            gravity: Edges.Bottom | Edges.Right

            onAnchoring: {
                const pos = selectorButton.QsWindow.contentItem.mapFromItem(selectorButton, selectorButton.width - selectorPopup.width, selectorButton.height + 6);

                anchor.rect.x = pos.x;
                anchor.rect.y = pos.y;
            }
        }

        implicitWidth: 250
        implicitHeight: Math.min(root.selectorModel.length * 46 + 12, 300)

        color: "transparent"

        PopupCard {
            anchors.fill: parent
            color: Colors.surfaceContainerHigh

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: Theme.spacingSm
                }

                spacing: Theme.spacingXs

                Repeater {
                    model: root.selectorModel

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: Theme.radiusMd

                        readonly property bool automatic: modelData?.automatic === true
                        readonly property bool isActive: !automatic && modelData === MediaService.activePlayer
                        readonly property bool isSelected: automatic ? !MediaService.hasExplicitSelection : MediaService.hasExplicitSelection && modelData === MediaService.activePlayer

                        color: itemMouse.pressed ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity) : isSelected ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.stateSelectedOpacity) : itemMouse.containsMouse ? Colors.surfaceContainerHighest : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motionFast
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingMd
                            anchors.rightMargin: Theme.spacingMd
                            spacing: Theme.spacingMd

                            Rectangle {
                                width: 4
                                height: 22
                                radius: 2
                                color: isActive ? Colors.primary : "transparent"
                            }

                            Image {
                                visible: !automatic && modelData.desktopEntry !== ""
                                Layout.preferredWidth: 22
                                Layout.preferredHeight: 22
                                width: 22
                                height: 22
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
                                font.pixelSize: 16
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: automatic ? "Automatic" : modelData.identity || "Unknown Player"
                                    color: isSelected ? Colors.on_Surface : Colors.on_SurfaceVariant
                                    font.family: Fonts.font
                                    font.pixelSize: 10
                                    font.bold: isSelected
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    visible: !automatic && modelData.desktopEntry !== ""
                                    text: modelData.desktopEntry
                                    color: Colors.outline
                                    font.family: Fonts.font
                                    font.pixelSize: 8
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Text {
                                visible: isSelected
                                text: "󰄬"
                                color: Colors.primary
                                font.family: Fonts.fontM
                                font.pixelSize: 14
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

                                selectorPopup.open = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
