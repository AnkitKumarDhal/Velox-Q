pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int brightness: 0
    property bool available: false
    property bool setting: false
    property int _pendingBrightness: -1

    property bool _hardwareAvailable: false
    property bool _backendAvailable: false
    property string _backendError: ""

    property IntegrationCapability capability: IntegrationCapability {
        hardwareAvailable: root._hardwareAvailable
        backendAvailable: root._backendAvailable
        errorMessage: root._backendError
    }

    Timer {
        id: refreshTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Timer {
        id: hardwareTimer
        interval: 5000
        repeat: true
        running: true
        onTriggered: root.refreshHardware()
    }

    Process {
        id: hardwareProbe

        command: ["sh", "-c", "for path in /sys/class/backlight/*; do " + "[ -e \"$path\" ] && exit 0; " + "done; " + "exit 1"]
        running: false

        onExited: (exitCode, exitStatus) => {
            root._hardwareAvailable = exitCode === 0;

            if (!root._hardwareAvailable)
                root.available = false;
        }
    }

    Process {
        id: readProcess

        command: ["brightnessctl", "-m", "-c", "backlight"]

        stdout: StdioCollector {
            onStreamFinished: root._parse(this.text)
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const error = this.text.trim();
                if (error.length > 0)
                    root._backendError = error;
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root._backendAvailable = false;
                root.available = false;
                if (root._backendError === "")
                    root._backendError = "brightnessctl backlight probe failed";
                return;
            }

            root._backendAvailable = true;
            root._backendError = "";
        }
    }

    Process {
        id: setProcess

        onStarted: {
            root.setting = true;
        }

        onExited: (exitCode, exitStatus) => {
            root.setting = false;

            if (exitCode !== 0) {
                root._backendAvailable = false;
                root._backendError = "brightnessctl failed to set brightness";
            } else {
                root._backendAvailable = true;
                root._backendError = "";
            }

            if (root._pendingBrightness >= 0) {
                const nextValue = root._pendingBrightness;
                root._pendingBrightness = -1;
                root._startSetBrightness(nextValue);
            } else {
                root.refresh();
            }
        }
    }

    function refreshHardware() {
        if (hardwareProbe.running)
            return;
        hardwareProbe.running = true;
    }

    function refresh() {
        if (readProcess.running)
            return;
        root._backendError = "";
        readProcess.running = true;
    }

    function _parse(output) {
        const lines = output.split(/\r?\n/).map(line => line.trim()).filter(line => line.length > 0);
        if (lines.length === 0) {
            root.available = false;
            return;
        }

        const fields = lines[0].split(",");

        if (fields.length < 4) {
            root.available = false;
            return;
        }

        const value = Number(String(fields[3]).replace("%", ""));

        if (!Number.isFinite(value)) {
            root.available = false;
            return;
        }

        root.brightness = Math.max(0, Math.min(100, Math.round(value)));
        root.available = true;
    }

    function _startSetBrightness(percent) {
        const value = Math.max(1, Math.min(100, Math.round(Number(percent))));
        root.brightness = value;
        setProcess.exec({
            command: ["brightnessctl", "-q", "-c", "backlight", "set", value + "%"]
        });
    }

    function setBrightness(percent) {
        if (!root.capability.operational)
            return;
        const value = Math.max(1, Math.min(100, Math.round(Number(percent))));
        root.brightness = value;

        if (setProcess.running) {
            root._pendingBrightness = value;
            return;
        }

        root._pendingBrightness = -1;
        root._startSetBrightness(value);
    }

    Component.onCompleted: {
        root.refreshHardware();
        root.refresh();
    }
}
