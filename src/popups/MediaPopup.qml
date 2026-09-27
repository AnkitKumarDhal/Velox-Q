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
    property real trackContextX: 0
    property real trackContextY: 0
    property bool trackContextOpen: false

    onPlayerChanged: {
        _position = 0;
        trackChangeToken++;
    }

    onVisibleChanged: {
        if (!visible) {
            playerSelector.open = false;
            win.trackContextOpen = false;
        }
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
                        duration: Theme.motionMedium
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
                anchors.margins: Theme.spacingXxl
                spacing: Theme.spacingXxl

                MediaArt {
                    id: art
                    player: win.player
                    hasArt: win.hasArt
                    Layout.preferredWidth: 178
                    Layout.preferredHeight: 178
                    Layout.alignment: Qt.AlignVCenter
                }

                Item {
                    id: rightColumn

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter

                    ColumnLayout {
                        id: contentColumn

                        anchors.fill: parent
                        spacing: Theme.spacingXs

                        Rectangle {
                            id: raisePlayerButton
                            anchors {
                                top: parent.top
                                right: playerSelector.left
                                rightMargin: Theme.spacingXs
                                topMargin: 12
                            }

                            width: 18
                            height: 18
                            radius: 9

                            visible: win.player?.canRaise ?? false
                            color: raiseMouse.pressed ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity) : raiseMouse.containsMouse ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.stateHoverOpacity) : "transparent"

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.motionFast
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰏂"
                                color: Colors.on_SurfaceVariant
                                font.family: Fonts.fontM
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: raiseMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: win.player?.canRaise ?? false
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (win.player?.canRaise)
                                        win.player.raise();
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 18
                        }

                        MediaTrackInfo {
                            id: trackInfo
                            player: win.player
                            transitionKey: win.trackChangeToken
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            onContextRequested: (x, y) => {
                                const point = trackInfo.mapToItem(rightColumn, x, y);
                                win.trackContextX = point.x;
                                win.trackContextY = point.y;
                                win.trackContextOpen = true;
                            }
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

                    MouseArea {
                        id: trackContextDismiss
                        anchors.fill: parent
                        visible: win.trackContextOpen
                        z: 110
                        onClicked: win.trackContextOpen = false
                    }

                    PopupCard {
                        id: trackContextMenu
                        x: Math.min(Math.max(0, win.trackContextX + 8), rightColumn.width - width)
                        y: Math.min(Math.max(0, win.trackContextY + 8), rightColumn.height - height)
                        width: 170
                        height: 132
                        color: Colors.surfaceContainerHigh
                        visible: win.trackContextOpen
                        opacity: visible ? 1 : 0
                        scale: visible ? 1 : 0.94
                        transformOrigin: Item.TopRight
                        z: 120

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

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                radius: Theme.radiusSm

                                color: copyTitleMouse.pressed ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity) : copyTitleMouse.containsMouse ? Colors.surfaceContainerHighest : "transparent"

                                Text {
                                    anchors {
                                        left: parent.left
                                        leftMargin: Theme.spacingSm
                                        verticalCenter: parent.verticalCenter
                                    }

                                    text: "Copy title"
                                    color: Colors.on_SurfaceVariant
                                    font.family: Fonts.font
                                    font.pixelSize: 9
                                }

                                MouseArea {
                                    id: copyTitleMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        Quickshell.clipboardText = win.player?.trackTitle || "Unknown Title";
                                        win.trackContextOpen = false;
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                radius: Theme.radiusSm
                                color: copyArtistMouse.pressed ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity) : copyArtistMouse.containsMouse ? Colors.surfaceContainerHighest : "transparent"

                                Text {
                                    anchors {
                                        left: parent.left
                                        leftMargin: Theme.spacingSm
                                        verticalCenter: parent.verticalCenter
                                    }

                                    text: "Copy artist"
                                    color: Colors.on_SurfaceVariant
                                    font.family: Fonts.font
                                    font.pixelSize: 9
                                }

                                MouseArea {
                                    id: copyArtistMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Quickshell.clipboardText = win.player?.trackArtist || "Unknown Artist";
                                        win.trackContextOpen = false;
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                radius: Theme.radiusSm

                                color: copyAlbumMouse.pressed ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity) : copyAlbumMouse.containsMouse ? Colors.surfaceContainerHighest : "transparent"

                                Text {
                                    anchors {
                                        left: parent.left
                                        leftMargin: Theme.spacingSm
                                        verticalCenter: parent.verticalCenter
                                    }

                                    text: "Copy album"
                                    color: Colors.on_SurfaceVariant
                                    font.family: Fonts.font
                                    font.pixelSize: 9
                                }

                                MouseArea {
                                    id: copyAlbumMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        Quickshell.clipboardText = win.player?.trackAlbum || "Unknown Album";
                                        win.trackContextOpen = false;
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                radius: Theme.radiusSm

                                color: copyTrackMouse.pressed ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity) : copyTrackMouse.containsMouse ? Colors.surfaceContainerHighest : "transparent"

                                Text {
                                    anchors {
                                        left: parent.left
                                        leftMargin: Theme.spacingSm
                                        verticalCenter: parent.verticalCenter
                                    }

                                    text: "Copy artist — title"
                                    color: Colors.on_SurfaceVariant
                                    font.family: Fonts.font
                                    font.pixelSize: 9
                                }

                                MouseArea {
                                    id: copyTrackMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        const artist = win.player?.trackArtist || "Unknown Artist";
                                        const title = win.player?.trackTitle || "Unknown Title";
                                        Quickshell.clipboardText = artist + " — " + title;
                                        win.trackContextOpen = false;
                                    }
                                }
                            }
                        }
                    }

                    MediaPlayerSelector {
                        id: playerSelector
                        player: win.player
                        anchors {
                            top: parent.top
                            right: parent.right
                            topMargin: 12
                        }
                        z: 10
                    }

                    MouseArea {
                        id: playerSelectorDismiss

                        anchors.fill: parent
                        visible: playerSelector.open
                        z: 9

                        onClicked: playerSelector.open = false
                    }
                }
            }

            ColumnLayout {
                visible: !win.mediaOperational

                anchors {
                    fill: parent
                    margins: 24
                }

                spacing: Theme.spacingLg

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
