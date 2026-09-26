import QtQuick
import QtQuick.Layouts
import qs.src.theme
import qs.src.services

ColumnLayout {
    id: root

    required property var player
    required property real position
    required property bool seeking

    readonly property bool backendOperational: MediaService.backendOperational
    readonly property bool seekOperational: root.backendOperational && root.player !== null

    signal seekStarted(real pos)
    signal seekMoved(real pos)
    signal seekReleased(real pos)

    Layout.fillWidth: true
    Layout.preferredHeight: 31
    spacing: 2
    visible: root.seekOperational && root.player.positionSupported

    Item {
        id: slider

        Layout.fillWidth: true
        Layout.preferredHeight: 17
        property real trackLen: root.player?.length ?? 0
        property real fraction: trackLen > 0 ? Math.max(0, Math.min(root.position / trackLen, 1)) : 0
        property bool hovered: mouseArea.containsMouse

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: slider.hovered ? 5 : 4
            radius: height / 2
            color: Colors.surfaceContainerHighest

            Behavior on height {
                NumberAnimation {
                    duration: Theme.motionFast
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * parent.fraction
            height: slider.hovered ? 5 : 4
            radius: height / 2
            color: Colors.primary

            Behavior on width {
                enabled: !root.seeking
                NumberAnimation {
                    duration: Theme.motionNormal
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: Theme.motionFast
                }
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width * parent.fraction - width / 2
            width: slider.hovered ? 12 : 8
            height: width
            radius: width / 2
            color: Colors.primary

            Behavior on x {
                enabled: !root.seeking
                NumberAnimation {
                    duration: Theme.motionNormal
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: Theme.motionFast
                }
            }
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            enabled: root.seekOperational && (root.player?.canSeek ?? false)
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            function positionFromMouse(mouseX) {
                return Math.max(0, Math.min(mouseX / width, 1)) * (root.player?.length ?? 0);
            }

            onPressed: mouse => {
                if (!root.seekOperational || !root.player?.canSeek)
                    return;
                root.seekStarted(positionFromMouse(mouse.x));
            }
            onPositionChanged: mouse => {
                if (!pressed || !root.seekOperational || !root.player?.canSeek)
                    return;
                root.seekMoved(positionFromMouse(mouse.x));
            }
            onReleased: mouse => {
                if (!root.seekOperational || !root.player?.canSeek)
                    return;
                root.seekReleased(positionFromMouse(mouse.x));
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 12

        Text {
            text: root.formatTime(root.position)
            color: Colors.on_SurfaceVariant
            font.family: Fonts.font
            font.pointSize: 8
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: root.formatTime(root.player?.length ?? 0)
            color: Colors.on_SurfaceVariant
            font.family: Fonts.font
            font.pointSize: 8
        }
    }

    function formatTime(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        const minutes = Math.floor(s / 60);
        const secs = String(s % 60).padStart(2, "0");

        return "%1:%2".arg(minutes).arg(secs);
    }
}
