pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool busy: false

    property bool _hyprctlAvailable: false
    property bool _hyprlockAvailable: false
    property bool _systemdAvailable: false
    property string _hyprctlError: ""
    property string _hyprlockError: ""
    property string _systemdError: ""

    property IntegrationCapability lockCapability: IntegrationCapability {
        hardwareAvailable: true
        backendAvailable: root._hyprlockAvailable
        errorMessage: root._hyprlockError
    }

    property IntegrationCapability compositorCapability: IntegrationCapability {
        hardwareAvailable: true
        backendAvailable: root._hyprctlAvailable
        errorMessage: root._hyprctlError
    }

    property IntegrationCapability powerCapability: IntegrationCapability {
        hardwareAvailable: true
        backendAvailable: root._systemdAvailable
        errorMessage: root._systemdError
    }

    readonly property bool lockOperational: root.lockCapability.operational

    readonly property bool compositorOperational: root.compositorCapability.operational

    readonly property bool powerOperational: root.powerCapability.operational

    function _refreshCapabilities() {
        if (!hyprctlProbe.running)
            hyprctlProbe.running = true;

        if (!hyprlockProbe.running)
            hyprlockProbe.running = true;

        if (!systemdProbe.running)
            systemdProbe.running = true;
    }

    Process {
        id: hyprctlProbe

        command: ["hyprctl", "version"]

        running: false

        onExited: (exitCode, exitStatus) => {
            root._hyprctlAvailable = exitCode === 0;

            if (exitCode === 0) {
                root._hyprctlError = "";
                return;
            }

            root._hyprctlError = "Hyprland IPC is unavailable";
        }
    }

    Process {
        id: hyprlockProbe

        command: ["sh", "-c", "command -v hyprlock >/dev/null 2>&1"]

        running: false

        onExited: (exitCode, exitStatus) => {
            root._hyprlockAvailable = exitCode === 0;

            if (exitCode === 0) {
                root._hyprlockError = "";
                return;
            }

            root._hyprlockError = "hyprlock is not installed";
        }
    }

    Process {
        id: systemdProbe

        command: ["systemctl", "--system", "show", "--property=Version", "--value"]

        running: false

        onExited: (exitCode, exitStatus) => {
            root._systemdAvailable = exitCode === 0;

            if (exitCode === 0) {
                root._systemdError = "";
                return;
            }

            root._systemdError = "systemd system manager is unavailable";
        }
    }

    Timer {
        id: capabilityTimer

        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: root._refreshCapabilities()
    }

    Process {
        id: actionProcess
        command: []
        onExited: (exitCode, exitStatus) => {
            root.busy = false;
            if (exitCode !== 0) {
                console.warn("SessionService: command exited with code", exitCode);
            }
            root._refreshCapabilities();
        }
    }

    function perform(action) {
        if (root.busy)
            return;
        let command = [];

        switch (action) {
        case "lock":
            if (!root.lockOperational) {
                console.warn("SessionService: lock backend unavailable");
                return;
            }

            command = ["hyprlock"];
            break;
        case "logout":
            if (!root.compositorOperational) {
                console.warn("SessionService: Hyprland IPC unavailable");
                return;
            }

            command = ["hyprctl", "dispatch", "hl.dsp.exit()"];
            break;
        case "suspend":
            if (!root.powerOperational) {
                console.warn("SessionService: systemd backend unavailable");
                return;
            }

            command = ["systemctl", "suspend"];
            break;
        case "hibernate":
            if (!root.powerOperational) {
                console.warn("SessionService: systemd backend unavailable");
                return;
            }

            command = ["systemctl", "hibernate"];
            break;
        case "reboot":
            if (!root.powerOperational) {
                console.warn("SessionService: systemd backend unavailable");
                return;
            }

            command = ["systemctl", "reboot"];
            break;
        case "poweroff":
            if (!root.powerOperational) {
                console.warn("SessionService: systemd backend unavailable");
                return;
            }

            command = ["systemctl", "poweroff"];
            break;
        default:
            console.warn("SessionService: unknown action:", action);
            return;
        }

        actionProcess.command = command;
        root.busy = true;
        actionProcess.running = true;
    }

    Component.onCompleted: root._refreshCapabilities()
}
