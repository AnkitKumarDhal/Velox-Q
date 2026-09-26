import QtQuick
import Quickshell
import qs.src.components
import qs.src.theme
import qs.src.state
import qs.src.services

PillBase {
    id: root

    visible: BatteryService.hasBattery
    hoverExpand: true

    border.color: Colors.primary
    border.width: Popups.batteryOpen ? 1 : 0
    Behavior on border.width {
        NumberAnimation {
            duration: Theme.motionHover
        }
    }

    Text {
        id: batteryText
        text: BatteryService.getIcon() + BatteryService.capacity + "%"
        color: BatteryService.getColor()
        font.pointSize: 11
        font.bold: true
        font.family: Fonts.fontM
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            ColorAnimation {
                duration: Theme.motionMedium
            }
        }

        SequentialAnimation on opacity {
            running: BatteryService.capacity <= 10 && !BatteryService.charging
            loops: Animation.Infinite
            NumberAnimation {
                to: 0.3
                duration: Theme.motionEmphasis
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                to: 1.0
                duration: Theme.motionEmphasis
                easing.type: Easing.InOutSine
            }
        }
    }

    onClicked: Popups.batteryOpen = !Popups.batteryOpen
}
