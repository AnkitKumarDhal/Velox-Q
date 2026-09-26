pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: root.adapter !== null
    readonly property var state: root.adapter?.state
    readonly property bool enabled: root.adapter?.enabled ?? false
    readonly property bool enabling: root.state === BluetoothAdapterState.Enabling
    readonly property bool disabling: root.state === BluetoothAdapterState.Disabling
    readonly property bool blocked: root.state === BluetoothAdapterState.Blocked
    readonly property bool powerTransitioning: root.enabling || root.disabling
    readonly property bool powerActive: root.state === BluetoothAdapterState.Enabled || root.state === BluetoothAdapterState.Enabling
    readonly property bool discovering: root.adapter?.discovering ?? false
    readonly property bool scanning: root.discovering

    readonly property var devices: root.adapter ? root.adapter.devices.values : []
    readonly property var connectedDevices: root.devices.filter(device => device.connected)
    readonly property var pairedDevices: root.devices.filter(device => device.paired && !device.connected)
    readonly property var availableDevices: root.devices.filter(device => !device.paired && !device.connected)
    readonly property int connectedDeviceCount: root.connectedDevices.length
    readonly property bool effectiveEnabled: root.enabled || root.enabling || root.connectedDeviceCount > 0
    readonly property bool operational: root.enabled || root.connectedDeviceCount > 0

    property bool _hardwareAvailable: false
    property bool _bluetoothServiceActive: false
    property string _backendError: ""

    readonly property bool _capabilityBackendAvailable: root._bluetoothServiceActive && root.adapter !== null

    property IntegrationCapability capability: IntegrationCapability {
        hardwareAvailable: root._hardwareAvailable
        backendAvailable: root._capabilityBackendAvailable
        errorMessage: root._backendError
    }

    readonly property bool capabilityOperational: root.capability.operational

    readonly property string stateText: {
        if (!root.available)
            return "Unavailable";
        if (root.connectedDeviceCount > 0)
            return root.connectedDeviceCount + " conn.";
        if (root.enabling)
            return "Enabling";
        if (root.disabling)
            return "Disabling";
        if (root.blocked)
            return "Blocked";
        if (root.state === BluetoothAdapterState.Disabled)
            return "Disabled";
        if (root.state === BluetoothAdapterState.Enabled)
            return "Ready";
        return "Unavailable";
    }

    function _refreshCapabilities() {
        if (!hardwareProbe.running)
            hardwareProbe.running = true;
        if (!backendProbe.running)
            backendProbe.running = true;
    }

    Process {
        id: hardwareProbe
        command: ["sh", "-c", "for path in /sys/class/bluetooth/hci*; do " + "[ -e \"$path\" ] && exit 0; " + "done; " + "exit 1"]
        running: false
        onExited: (exitCode, exitStatus) => {
            root._hardwareAvailable = exitCode === 0;
        }
    }

    Process {
        id: backendProbe
        command: ["systemctl", "is-active", "bluetooth.service"]
        running: false
        onExited: (exitCode, exitStatus) => {
            root._bluetoothServiceActive = exitCode === 0;
            if (exitCode !== 0) {
                root._backendError = "Bluetooth service is unavailable";
            } else if (root.adapter === null) {
                root._backendError = "Bluetooth adapter is unavailable";
            } else {
                root._backendError = "";
            }
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

    Connections {
        target: Bluetooth
        function onDefaultAdapterChanged() {
            root._refreshCapabilities();
        }
    }

    function reconcilePowerState() {
        if (!root.adapter)
            return;
        if (root.connectedDeviceCount <= 0)
            return;
        if (root.adapter.enabled)
            return;

        root.adapter.enabled = true;
    }

    onConnectedDeviceCountChanged: root.reconcilePowerState()

    function isPairing(address) {
        const device = root.devices.find(item => item.address === address);
        return device?.pairing ?? false;
    }

    function isConnecting(address) {
        const device = root.devices.find(item => item.address === address);
        return device?.state === BluetoothDeviceState.Connecting;
    }

    function scan() {
        if (!root.adapter || !root.enabled)
            return;
        root.adapter.discovering = true;
    }

    function stopScan() {
        if (!root.adapter)
            return;
        root.adapter.discovering = false;
    }

    function pair(address) {
        const device = root.devices.find(item => item.address === address);
        if (!device || !root.enabled || root.isPairing(address))
            return;
        device.pair();
    }

    function cancelPair(address) {
        const device = root.devices.find(item => item.address === address);
        if (!device || !device.pairing)
            return;
        device.cancelPair();
    }

    function connect(address) {
        const device = root.devices.find(item => item.address === address);
        if (!device || !root.enabled || root.isConnecting(address))
            return;
        device.connect();
    }

    function disconnect(address) {
        const device = root.devices.find(item => item.address === address);
        if (!device)
            return;
        device.disconnect();
    }

    function remove(address) {
        const device = root.devices.find(item => item.address === address);
        if (!device)
            return;
        device.forget();
    }

    function setEnabled(value) {
        if (!root.adapter)
            return;
        if (value) {
            root.adapter.enabled = true;
            return;
        }

        if (!root.adapter.enabled && root.effectiveEnabled)
            root.adapter.enabled = true;

        root.adapter.enabled = false;
    }

    Component.onCompleted: root._refreshCapabilities()
}
