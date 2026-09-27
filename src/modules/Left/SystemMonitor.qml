import QtQuick
import Quickshell
import qs.src.components
import qs.src.theme
import qs.src.state
import qs.src.services
import qs.src.services.system

PillBase {
    id: root

    border.color: Colors.primary
    border.width: Popups.systemOpen ? 1 : 0
    Behavior on border.width {
        NumberAnimation {
            duration: Theme.motionHover
        }
    }

    required property var screen

    hoverExpand: false

    property real cpuUsage: SystemStats.cpuUsage * 100
    property real memUsedGb: SystemStats.memUsedGb

    Row {
        spacing: Theme.spacingSm

        Text {
            text: " " + Math.round(root.cpuUsage) + "%"
            color: Colors.primary
            font.pointSize: 11
            font.bold: true
            font.family: Fonts.fontM
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            width: 1
            height: 14
            radius: 0.5
            color: Colors.outlineVariant
            opacity: 0.8
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: " " + root.memUsedGb.toFixed(1) + "GB"
            color: Colors.primary
            font.pointSize: 11
            font.bold: true
            font.family: Fonts.fontM
            verticalAlignment: Text.AlignVCenter
        }
    }

    function updatePopupAnchor() {
        Popups.systemScreen = root.screen;
        Popups.systemAnchorX = root.mapToItem(null, root.width / 2, 0).x;
    }

    onWidthChanged: {
        if (Popups.systemOpen)
            root.updatePopupAnchor();
    }

    onXChanged: {
        if (Popups.systemOpen)
            root.updatePopupAnchor();
    }

    onClicked: {
        const wasOpen = Popups.systemOpen;
        root.updatePopupAnchor();
        Popups.systemOpen = !wasOpen;
    }

    onRightClicked: {
        root.updatePopupAnchor();
        Popups.systemOpen = true;
    }
}
