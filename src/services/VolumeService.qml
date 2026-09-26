pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sink: Pipewire.defaultAudioSink
    property var audio: sink?.audio ?? null
    property real volume: audio?.volume ?? 0.0
    property bool muted: audio?.muted ?? false

    property IntegrationCapability outputCapability: IntegrationCapability {
        hardwareAvailable: root.sink !== null
        backendAvailable: Pipewire.ready
        errorMessage: Pipewire.ready ? "" : "PipeWire is unavailable"
    }

    readonly property bool outputOperational: root.outputCapability.operational

    function toggleMute() {
        if (audio)
            audio.muted = !audio.muted;
    }

    function changeVolume(step) {
        if (audio)
            audio.volume = Math.max(0.0, Math.min(1.0, audio.volume + step));
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSource]
    }

    property var source: Pipewire.defaultAudioSource
    property var inputAudio: source?.audio ?? null
    property real inputVolume: inputAudio?.volume ?? 0.0
    property bool inputMuted: inputAudio?.muted ?? false

    property IntegrationCapability inputCapability: IntegrationCapability {
        hardwareAvailable: root.source !== null
        backendAvailable: Pipewire.ready
        errorMessage: Pipewire.ready ? "" : "PipeWire is unavailable"
    }

    readonly property bool inputOperational: root.inputCapability.operational

    function toggleInputMute() {
        if (inputAudio)
            inputAudio.muted = !inputAudio.muted;
    }

    function changeInputVolume(step) {
        if (inputAudio)
            inputAudio.volume = Math.max(0.0, Math.min(1.0, inputAudio.volume + step));
    }
}
