import QtQuick
import QtQuick.Layouts
import qs.src.theme
import qs.src.services

RowLayout {
    id: root

    required property var player
    required property bool isPlaying

    readonly property bool backendOperational: MediaService.backendOperational
    readonly property bool playerAvailable: root.backendOperational && root.player !== null

    Layout.fillWidth: true
    spacing: 2

    component IconButton: Item {
        id: button

        property string icon: ""
        property color iconColor: Colors.on_SurfaceVariant
        property int iconSize: 16
        property bool enabledState: true

        signal clicked

        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        opacity: enabledState ? 1 : 0.35

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: mouse.containsMouse ? 30 : 26
            height: width
            radius: width / 2
            color: mouse.containsMouse ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.12) : "transparent"

            Behavior on width {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: 120
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
            color: button.iconColor
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
                    duration: 130
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

    Item {
        Layout.fillWidth: true
    }
}
