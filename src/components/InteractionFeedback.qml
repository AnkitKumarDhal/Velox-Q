import QtQuick

import qs.src.theme

Item {
    id: root

    required property bool hovered
    required property bool pressed

    property bool active: true
    property real radius: 0
    property int borderWidth: 0

    property color hoverColor: Colors.surfaceContainerHighest
    property color pressedColor: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity)

    property real hoverOpacity: 1
    property real pressedOpacity: 1

    anchors.fill: parent
    anchors.margins: root.borderWidth
    visible: root.active
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: Math.max(0, root.radius - root.borderWidth)

        color: root.hoverColor
        opacity: root.active && root.hovered && !root.pressed ? root.hoverOpacity : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motionHover
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Math.max(0, root.radius - root.borderWidth)

        color: root.pressedColor
        opacity: root.active && root.pressed ? root.pressedOpacity : 0
        z: 1

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motionInstant
                easing.type: Easing.OutCubic
            }
        }
    }
}
