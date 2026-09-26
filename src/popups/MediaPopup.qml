import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects

import qs.src.components
import qs.src.theme
import qs.src.state
import qs.src.services
import qs.src.popups.media

PanelWindow {
    id: win

    WlrLayershell.screen: screen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors.top: true
    implicitHeight: win.screen ? win.screen.height : 800
    implicitWidth: 600

    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    visible: slide.windowVisible

    property var player: MediaService.activePlayer
    property bool isPlaying: MediaService.isPlaying
    property bool hasArt: MediaService.hasArt
    readonly property var capability: MediaService.capability
    readonly property bool backendOperational: MediaService.backendOperational
    readonly property bool backendFailure: MediaService.capability.backendFailure
    readonly property bool hasPlayer: MediaService.hasPlayer
    readonly property bool mediaOperational: MediaService.operational
    property real _position: 0
    property bool _seeking: false
    property int trackChangeToken: 0

    onPlayerChanged: {
        _position = 0;
        trackChangeToken++;
    }

    Timer {
        interval: 1000
        repeat: true
        running: win.mediaOperational && win.player !== null && win.isPlaying && !win._seeking && win.player.positionSupported
        onTriggered: {
            if (!win.player)
                return;
            if (!win._seeking)
                win._position = win.player.position;
        }
    }

    Connections {
        target: win.player ?? null

        function onTrackChanged() {
            win._position = 0;
        }
        function onPostTrackChanged() {
            win.trackChangeToken++;
        }
        function onPositionChanged() {
            if (!win._seeking)
                win._position = win.player?.position ?? 0;
        }
    }

    mask: Region {
        x: (win.implicitWidth - mediaCard.width) / 2
        y: Theme.barHeight + 8
        width: mediaCard.width
        height: mediaCard.height
    }

    PopupSlide {
        id: slide

        anchors.fill: parent
        open: Popups.mediaOpen
        edge: "top"
        onCloseRequested: {
            Popups.mediaOpen = false;
        }

        Rectangle {
            id: mediaCard

            width: 560
            height: 210
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: Theme.barHeight + 8
            }

            radius: Theme.popupRadius

            color: Colors.surfaceContainer

            border.color: Colors.outlineVariant
            border.width: Theme.popupBorder
            clip: true

            Item {
                visible: win.mediaOperational && win.hasArt
                anchors.fill: parent
                opacity: win.mediaOperational && win.hasArt ? 0.14 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                Image {
                    anchors.fill: parent
                    source: win.mediaOperational && win.hasArt ? win.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    layer.enabled: true
                    layer.effect: FastBlur {
                        radius: 12
                        transparentBorder: false
                    }
                    opacity: 0.95
                }

                Rectangle {
                    anchors.fill: parent
                    color: Colors.surfaceContainer
                    opacity: 0.68
                }
            }

            RowLayout {
                visible: win.mediaOperational
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                MediaArt {
                    id: art
                    player: win.player
                    hasArt: win.hasArt
                    Layout.preferredWidth: 178
                    Layout.preferredHeight: 178
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    id: rightColumn

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 18

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 7
                            height: 7
                            radius: 3.5

                            color: win.isPlaying ? Colors.primary : Colors.on_SurfaceVariant

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }

                        Text {
                            text: MediaService.playerIdentity
                            color: Colors.on_SurfaceVariant
                            font.family: Fonts.font
                            font.pointSize: 8.5
                            font.bold: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    MediaTrackInfo {
                        player: win.player
                        transitionKey: win.trackChangeToken
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                    }

                    MediaProgress {
                        player: win.player
                        position: win._position
                        seeking: win._seeking
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24

                        onSeekStarted: pos => {
                            win._seeking = true;
                            win._position = pos;
                        }
                        onSeekMoved: pos => {
                            win._position = pos;
                        }
                        onSeekReleased: pos => {
                            if (win.mediaOperational && win.player && win.player.canSeek) {
                                win.player.position = pos;
                            }
                            win._seeking = false;
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40

                        MediaControls {
                            player: win.player
                            isPlaying: win.isPlaying
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                        }

                        MediaVolumeRow {
                            player: win.player
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }
            }

            ColumnLayout {
                visible: !win.mediaOperational

                anchors {
                    fill: parent
                    margins: 24
                }

                spacing: 10

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        if (win.backendFailure)
                            return "Media backend unavailable";
                        if (!win.hasPlayer)
                            return "No media player detected";
                        return "Media unavailable";
                    }

                    color: win.backendFailure ? Colors.error : Colors.on_Surface
                    font.family: Fonts.font
                    font.pixelSize: 15
                    font.bold: true
                }

                Text {
                    visible: win.backendFailure
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: win.capability.errorMessage || "The user D-Bus session is unavailable."
                    color: Colors.error
                    font.family: Fonts.font
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }

                Text {
                    visible: !win.backendFailure && !win.hasPlayer
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: "Start a media player to use media controls."
                    color: Colors.on_SurfaceVariant
                    font.family: Fonts.font
                    font.pixelSize: 10
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
