import QtQuick
import QtQuick.Layouts
import qs.src.components
import qs.src.theme
import qs.src.state
import qs.src.services

PillBase {
    id: root

    required property var screen

    hoverExpand: true

    border.color: Popups.caffeineOpen ? Colors.primary : "transparent"
    border.width: Popups.caffeineOpen ? 1 : 0

    Behavior on border.width {
        NumberAnimation {
            duration: Theme.motionHover
        }
    }

    readonly property string caffeineText: {
        if (CaffeineService.capability.backendFailure)
            return "󰾪 Unavailable";
        if (!CaffeineService.caffeineActive)
            return "󰾪 Off";
        if (CaffeineService.infinite)
            return "󰛨 ∞";
        return "󰛨 " + formatRemaining(CaffeineService.remainingSeconds);
    }

    readonly property color caffeineColor: {
        if (CaffeineService.capability.backendFailure)
            return Colors.error;
        return CaffeineService.caffeineActive ? Colors.tertiary : Colors.outline;
    }

    function formatRemaining(totalSeconds) {
        const seconds = Math.max(0, Number(totalSeconds));
        const minutes = Math.floor(seconds / 60);
        const remaining = seconds % 60;
        return String(minutes).padStart(2, "0") + ":" + String(remaining).padStart(2, "0");
    }

    Text {
        text: root.caffeineText
        color: root.caffeineColor
        font.pointSize: 11
        font.bold: CaffeineService.caffeineActive
        font.family: Fonts.fontM
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            ColorAnimation {
                duration: Theme.motionHover
            }
        }
    }

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 13
        radius: 1
        color: Colors.outlineVariant
        opacity: 0.8
    }

    Text {
        visible: BrightnessService.capability.hardwareAvailable
        text: BrightnessService.capability.operational ? "󰃠 " + BrightnessService.brightness + "%" : "󰃠 —"
        color: BrightnessService.capability.backendFailure ? Colors.error : Colors.primary
        font.pointSize: 11
        font.bold: true
        font.family: Fonts.fontM
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            ColorAnimation {
                duration: Theme.motionHover
            }
        }
    }

    function updatePopupAnchor() {
        Popups.caffeineScreen = root.screen;
        Popups.caffeineAnchorX = root.mapToItem(null, root.width / 2, 0).x;
    }

    onClicked: {
        const wasOpen = Popups.caffeineOpen;
        root.updatePopupAnchor();
        Popups.caffeineOpen = !wasOpen;
    }

    onRightClicked: {
        if (!CaffeineService.operational)
            return;

        CaffeineService.cyclePreset();
    }
}
