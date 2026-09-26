import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.src.components
import qs.src.theme
import qs.src.state
import qs.src.services
import qs.src.popups.notifications

PanelWindow {
    id: root

    color: "transparent"

    anchors {
        top: true
        right: true
    }

    implicitWidth: 380
    implicitHeight: root.screen ? root.screen.height : 800

    exclusionMode: ExclusionMode.Ignore
    screen: NotificationService.panelScreen
    WlrLayershell.layer: WlrLayer.Overlay
    visible: slidePanel.windowVisible

    property bool clearAllAnimating: false
    property int clearAllCount: 0

    function clearAllWithAnimation() {
        if (root.clearAllAnimating)
            return;
        if (NotificationService.notificationCount <= 0)
            return;
        root.clearAllCount = NotificationService.notificationCount;
        root.clearAllAnimating = true;
        clearAllTimer.interval = 460 + Math.max(0, root.clearAllCount - 1) * 35;
        clearAllTimer.start();
    }

    mask: Region {
        x: panelCard.x
        y: panelCard.y
        width: panelCard.width
        height: panelCard.height
    }

    Connections {
        target: NotificationService

        function onNotificationCountChanged() {
            if (NotificationService.notificationCount === 0) {
                emptyState.opacity = 0;
                emptyStateFadeIn.restart();
            } else {
                emptyStateFadeIn.stop();
                emptyState.opacity = 0;
            }
        }
    }

    NumberAnimation {
        id: emptyStateFadeIn
        target: emptyState
        property: "opacity"
        from: 0
        to: 1
        duration: Theme.motionNormal
        easing.type: Easing.OutCubic
    }

    Timer {
        id: clearAllTimer
        repeat: false
        onTriggered: {
            NotificationService.clearAll();
            root.clearAllAnimating = false;
        }
    }

    PopupSlide {
        id: slidePanel

        anchors.fill: parent
        edge: "right"
        open: Popups.notificationsOpen

        onCloseRequested: Popups.notificationsOpen = false

        Rectangle {
            id: panelCard

            anchors {
                top: parent.top
                right: parent.right
                topMargin: Theme.barHeight + 2
                rightMargin: Theme.barMargin
            }

            width: 360
            height: Math.min((root.clearAllAnimating || NotificationService.notificationCount === 0) ? 48 + notifCol.padding * 2 + emptyState.height : notifCol.implicitHeight + 48, root.implicitHeight - Theme.barHeight - 24)

            Behavior on height {
                NumberAnimation {
                    duration: Theme.motionNormal
                    easing.type: Easing.OutCubic
                }
            }

            radius: Theme.popupRadius
            color: Colors.background
            border.color: Colors.outlineVariant
            border.width: Theme.popupBorder

            clip: true

            Rectangle {
                id: panelHeader
                z: 10

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                height: 48

                color: "transparent"

                RowLayout {
                    anchors {
                        fill: parent

                        topMargin: 8
                        leftMargin: 16
                        rightMargin: 16
                        bottomMargin: 8
                    }

                    Text {
                        text: "Notifications"

                        color: Colors.on_Surface

                        font.pixelSize: 14
                        font.bold: true
                        font.family: Fonts.font

                        Layout.fillWidth: true

                        textFormat: Text.PlainText
                    }

                    Rectangle {
                        visible: NotificationService.notificationCount > 0

                        width: 90
                        height: 26

                        radius: 13

                        color: "transparent"

                        border.color: Colors.outline
                        border.width: 1

                        Rectangle {
                            anchors.fill: parent
                            radius: 13
                            color: Colors.primary
                            opacity: clearHover.containsMouse ? 0.25 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.motionHover
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Clear all"
                            color: Colors.on_Surface
                            font.pixelSize: 11
                            font.family: Fonts.font
                            textFormat: Text.PlainText
                        }

                        MouseArea {
                            id: clearHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: !root.clearAllAnimating
                            onClicked: root.clearAllWithAnimation()
                        }
                    }
                }

                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }

                    height: 1
                    color: Colors.outlineVariant
                    opacity: 0.5
                }
            }

            Flickable {
                anchors {
                    top: panelHeader.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                contentHeight: notifCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: notifCol

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }

                    spacing: 4
                    padding: 8

                    Repeater {
                        model: NotificationService.notificationsModel
                        delegate: Item {
                            id: delegateRoot
                            required property var modelData
                            required property int index
                            width: notifCol.width - 16
                            height: notificationCard.implicitHeight

                            NotificationCard {
                                id: notificationCard
                                anchors.fill: parent
                                notification: delegateRoot.modelData
                                bodyMaximumLineCount: 3
                            }

                            SequentialAnimation {
                                running: root.clearAllAnimating
                                PauseAnimation {
                                    duration: Math.max(0, root.clearAllCount - 1 - delegateRoot.index) * 35
                                }
                                ParallelAnimation {
                                    NumberAnimation {
                                        target: delegateRoot
                                        property: "opacity"
                                        to: 0
                                        duration: Theme.motionSmooth
                                        easing.type: Easing.OutCubic
                                    }

                                    NumberAnimation {
                                        target: delegateRoot
                                        property: "x"
                                        to: 24
                                        duration: Theme.motionSmooth
                                        easing.type: Easing.OutCubic
                                    }

                                    NumberAnimation {
                                        target: delegateRoot
                                        property: "height"
                                        to: 0
                                        duration: Theme.motionNormal
                                        easing.type: Easing.InOutCubic
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    id: emptyState
                    x: 8
                    y: 8
                    width: parent.width - 16
                    height: 80
                    visible: root.clearAllAnimating || NotificationService.notificationCount === 0
                    opacity: 0

                    Component.onCompleted: {
                        if (NotificationService.notificationCount === 0)
                            opacity = 1;
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰂚"
                            font.pixelSize: 28
                            font.family: Fonts.font
                            color: Colors.outline
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No notifications"
                            font.pixelSize: 12
                            font.family: Fonts.font
                            color: Colors.outline
                            textFormat: Text.PlainText
                        }
                    }
                }
            }
        }
    }
}
