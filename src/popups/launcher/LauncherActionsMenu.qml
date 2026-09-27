import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.src.theme
import qs.src.services

Item {
    id: root

    property var appData: null
    property int selectedAction: 0

    signal closeRequested
    signal finished

    readonly property bool hasExistingWindow: root.appData ? LauncherService.findExistingWindow(root.appData) !== null : false
    readonly property var desktopActions: root.appData && root.appData.actions ? root.appData.actions : []
    readonly property int desktopActionCount: root.desktopActions.length
    readonly property int actionCount: (root.hasExistingWindow ? 1 : 0) + root.desktopActionCount + 1

    function getDesktopAction(index) {
        const action = root.desktopActions[index];
        return action ? action : null;
    }

    function actionLabel(index) {
        let offset = 0;

        if (root.hasExistingWindow) {
            if (index === 0)
                return "Focus existing window";
            offset = 1;
        }

        if (index >= offset && index < offset + root.desktopActionCount) {
            const action = root.getDesktopAction(index - offset);
            return action && action.name ? action.name : "Action";
        }

        return LauncherService.isPinned(root.appData) ? "Unpin application" : "Pin application";
    }

    function actionIcon(index) {
        let offset = 0;

        if (root.hasExistingWindow) {
            if (index === 0)
                return "󰖯";
            offset = 1;
        }

        if (index >= offset && index < offset + root.desktopActionCount) {
            const action = root.getDesktopAction(index - offset);
            if (action && action.icon) {
                return action.icon;
            }
            return "";
        }
        return LauncherService.isPinned(root.appData) ? "󰌐" : "󰐕";
    }

    function executeAction(index) {
        let offset = 0;

        if (root.hasExistingWindow) {
            if (index === 0) {
                LauncherService.focusExisting(root.appData);
                root.finished();
                return;
            }
            offset = 1;
        }

        if (index >= offset && index < offset + root.desktopActionCount) {
            const action = root.getDesktopAction(index - offset);
            if (action)
                action.execute();
            root.finished();
            return;
        }

        LauncherService.togglePin(root.appData);
        root.finished();
    }

    visible: root.appData !== null
    focus: visible

    onSelectedActionChanged: {
        if (root.selectedAction < 0 || root.selectedAction >= root.actionCount) {
            root.selectedAction = 0;
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            leftMargin: Theme.spacingLg
            rightMargin: Theme.spacingLg
            topMargin: Theme.spacingMd
            bottomMargin: Theme.spacingMd
        }

        spacing: 2

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingMd
            Layout.rightMargin: Theme.spacingMd
            Layout.topMargin: 2
            Layout.bottomMargin: Theme.spacingXs

            text: root.appData ? root.appData.name : ""
            color: Colors.on_Surface

            font.pixelSize: 13
            font.family: Fonts.fontM

            elide: Text.ElideRight
        }

        Repeater {
            model: root.actionCount

            delegate: Item {
                required property int index

                Layout.fillWidth: true
                Layout.preferredHeight: 46

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusMd

                    color: actionMouse.pressed ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity) : index === root.selectedAction ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.stateSelectedOpacity) : actionMouse.containsMouse ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.stateHoverOpacity) : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motionInstant
                        }
                    }
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    width: 3
                    radius: Theme.radiusXs / 4
                    color: Colors.primary
                    opacity: index === root.selectedAction ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motionQuick
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: Theme.spacingXxl
                    anchors.rightMargin: 14

                    spacing: Theme.spacingXl

                    Item {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignVCenter

                        Image {
                            id: actionIconImage

                            anchors.centerIn: parent

                            width: 20
                            height: 20

                            source: {
                                const icon = root.actionIcon(index);
                                if (!icon || icon === "󰖯" || icon === "󰌐" || icon === "󰐕")
                                    return "";
                                return Quickshell.iconPath(icon, true);
                            }

                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            asynchronous: true
                            visible: status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: actionIconImage.status !== Image.Ready
                            text: root.actionIcon(index)
                            color: index === root.selectedAction ? Colors.primary : Colors.on_SurfaceVariant
                            font.pixelSize: 17
                            font.family: Fonts.font
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.actionLabel(index)
                        color: Colors.on_Surface
                        font.pixelSize: 12
                        font.family: Fonts.font
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: actionMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.selectedAction = index
                    onClicked: root.executeAction(index)
                }
            }
        }
    }

    Keys.onEscapePressed: event => {
        root.closeRequested();
        event.accepted = true;
    }

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Left:
            root.closeRequested();
            event.accepted = true;
            break;
        case Qt.Key_Up:
            root.selectedAction = (root.selectedAction - 1 + root.actionCount) % root.actionCount;
            event.accepted = true;
            break;
        case Qt.Key_Down:
            root.selectedAction = (root.selectedAction + 1) % root.actionCount;
            event.accepted = true;
            break;
        }
    }

    Keys.onReturnPressed: event => {
        root.executeAction(root.selectedAction);
        event.accepted = true;
    }

    Keys.onEnterPressed: event => {
        root.executeAction(root.selectedAction);
        event.accepted = true;
    }
}
