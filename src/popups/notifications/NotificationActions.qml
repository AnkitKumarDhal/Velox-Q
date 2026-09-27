import QtQuick
import QtQuick.Layouts
import qs.src.theme

Item {
    id: root

    required property var notification

    visible: !!root.notification && root.notification.actions.length > 0

    implicitHeight: visible ? actionsFlow.implicitHeight : 0
    implicitWidth: visible ? actionsFlow.implicitWidth : 0

    Flow {
        id: actionsFlow

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        spacing: Theme.spacingSm

        Repeater {
            model: root.notification ? root.notification.actions : []

            delegate: Rectangle {
                required property var modelData

                width: Math.min(actionText.implicitWidth + 24, 150)
                height: 28

                color: actionTap.pressed ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity) : actionHover.hovered ? Colors.primaryContainer : "transparent"

                radius: Theme.radiusLg
                border.color: actionTap.pressed ? Colors.primary : actionHover.hovered ? Colors.primary : Colors.outline
                border.width: 1

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.motionFast
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: Theme.motionFast
                    }
                }

                Text {
                    id: actionText

                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter

                        leftMargin: Theme.spacingXl
                        rightMargin: Theme.spacingXl
                    }

                    text: modelData ? modelData.text : ""
                    color: actionTap.pressed ? Colors.on_Primary : actionHover.hovered ? Colors.on_PrimaryContainer : Colors.on_Surface
                    font.pixelSize: 10
                    font.family: Fonts.font

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                }

                HoverHandler {
                    id: actionHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: actionTap
                    acceptedButtons: Qt.LeftButton
                    onTapped: {
                        if (modelData)
                            modelData.invoke();
                    }
                }
            }
        }
    }
}
