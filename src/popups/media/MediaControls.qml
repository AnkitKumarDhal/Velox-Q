import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.src.theme
import qs.src.services

RowLayout {
    id: root

    required property var player
    required property bool isPlaying

    readonly property bool backendOperational: MediaService.backendOperational
    readonly property bool playerAvailable: root.backendOperational && root.player !== null
    readonly property bool shuffleAvailable: root.playerAvailable && root.player?.canControl && root.player?.shuffleSupported
    readonly property bool repeatAvailable: root.playerAvailable && root.player?.canControl && root.player?.loopSupported

    Layout.fillWidth: true
    spacing: 2

    component IconButton: Item {
        id: button

        property string icon: ""
        property color iconColor: Colors.on_SurfaceVariant
        property int iconSize: 16
        property bool enabledState: true
        property bool activeState: false

        signal clicked

        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        opacity: enabledState ? 1 : 0.35

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motionFast
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: mouse.containsMouse ? 30 : 26
            height: width
            radius: width / 2
            color: !button.enabledState ? "transparent" : mouse.pressed ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity) : button.activeState ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.stateSelectedOpacity) : mouse.containsMouse ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.stateHoverOpacity) : "transparent"

            Behavior on width {
                NumberAnimation {
                    duration: Theme.motionFast
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: Theme.motionFast
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.hoverFadeDuration
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: button.icon
            font.family: Fonts.fontM
            font.pointSize: button.iconSize
            color: button.activeState ? Colors.primary : button.iconColor
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: button.enabledState
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: button.clicked()
        }
    }

    Item {
        Layout.fillWidth: true
    }

    // Shuffle
    IconButton {
        icon: "󰒝"
        activeState: root.shuffleAvailable && root.player?.shuffle
        enabledState: root.shuffleAvailable
        iconColor: root.shuffleAvailable ? Colors.on_SurfaceVariant : Colors.outline
        onClicked: {
            if (root.shuffleAvailable)
                root.player.shuffle = !root.player.shuffle;
        }
    }

    // Previous
    IconButton {
        icon: "󰒮"
        iconSize: 16
        enabledState: root.playerAvailable && root.player?.canGoPrevious
        onClicked: {
            if (root.playerAvailable && root.player?.canGoPrevious) {
                root.player.previous();
            }
        }
    }

    // Play / Pause
    Item {
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        property bool hovered: playMouse.containsMouse

        Rectangle {
            anchors.centerIn: parent
            width: parent.hovered ? 42 : 38
            height: width
            radius: width / 2
            color: parent.hovered ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.28) : Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.18)

            Behavior on width {
                NumberAnimation {
                    duration: Theme.motionFast
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.hoverFadeDuration
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.isPlaying ? "󰏤" : "󰐊"
            font.family: Fonts.fontM
            font.pointSize: 18
            color: root.playerAvailable ? Colors.primary : Colors.outline
        }

        MouseArea {
            id: playMouse

            anchors.fill: parent
            hoverEnabled: true
            enabled: root.playerAvailable && (root.player?.canTogglePlaying ?? false)
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (root.playerAvailable && root.player?.canTogglePlaying) {
                    root.player.togglePlaying();
                }
            }
        }
    }

    // Next
    IconButton {
        icon: "󰒭"
        iconSize: 16
        enabledState: root.playerAvailable && root.player?.canGoNext
        onClicked: {
            if (root.playerAvailable && root.player?.canGoNext) {
                root.player.next();
            }
        }
    }

    // Repeat
    IconButton {
        icon: "󰑖"
        activeState: root.repeatAvailable && root.player?.loopState !== MprisLoopState.None
        enabledState: root.repeatAvailable
        iconColor: root.repeatAvailable ? Colors.on_SurfaceVariant : Colors.outline

        onClicked: {
            if (!root.repeatAvailable)
                return;

            switch (root.player.loopState) {
            case MprisLoopState.None:
                root.player.loopState = MprisLoopState.Track;
                break;
            case MprisLoopState.Track:
                root.player.loopState = MprisLoopState.Playlist;
                break;
            default:
                root.player.loopState = MprisLoopState.None;
                break;
            }
        }
    }

    Item {
        Layout.fillWidth: true
    }
}
