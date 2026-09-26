import QtQuick

QtObject {
    id: root

    property bool hardwareAvailable: false
    property bool backendAvailable: false

    property string errorMessage: ""
    readonly property bool operational: root.hardwareAvailable && root.backendAvailable
    readonly property bool backendFailure: root.hardwareAvailable && !root.backendAvailable
    readonly property string state: {
        if (!root.hardwareAvailable)
            return "unavailable";
        if (!root.backendAvailable)
            return "error";
        return "ready";
    }
}
