pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    property var _lastActive: null
    property bool _sessionBusAvailable: false
    property string _backendError: ""
    property var selectedPlayer: null

    property IntegrationCapability capability: IntegrationCapability {
        hardwareAvailable: true
        backendAvailable: root._sessionBusAvailable
        errorMessage: root._backendError
    }

    readonly property bool backendOperational: root.capability.operational
    readonly property bool operational: root.backendOperational && root.hasPlayer
    readonly property var currentlyPlaying: {
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing) {
                return players[i];
            }
        }

        return null;
    }

    readonly property bool hasExplicitSelection: {
        if (!root.selectedPlayer)
            return false;
        return root.players.indexOf(root.selectedPlayer) >= 0;
    }

    readonly property var activePlayer: {
        if (root.hasExplicitSelection)
            return root.selectedPlayer;
        if (root.players.length === 0)
            return null;
        if (root.currentlyPlaying)
            return root.currentlyPlaying;
        if (root._lastActive) {
            for (let i = 0; i < root.players.length; i++) {
                if (root.players[i] === root._lastActive) {
                    return root._lastActive;
                }
            }
        }
        return root.players[0];
    }

    function selectPlayer(player) {
        if (!player)
            return;
        root.selectedPlayer = player;
        root._lastActive = player;
    }

    function clearPlayerSelection() {
        root.selectedPlayer = null;
    }

    readonly property bool hasPlayer: root.activePlayer !== null
    readonly property bool isPlaying: root.activePlayer?.playbackState === MprisPlaybackState.Playing ?? false
    readonly property bool hasArt: root.activePlayer !== null && root.activePlayer.trackArtUrl !== ""
    readonly property string playerIdentity: root.activePlayer?.identity || "Unknown Player"

    function _refreshCapability() {
        if (sessionBusProbe.running)
            return;
        sessionBusProbe.running = true;
    }

    Process {
        id: sessionBusProbe
        command: ["busctl", "--user", "status"]
        running: false
        onExited: (exitCode, exitStatus) => {
            root._sessionBusAvailable = exitCode === 0;
            if (exitCode === 0) {
                root._backendError = "";
                return;
            }
            root._backendError = "User D-Bus session is unavailable";
        }
    }

    Timer {
        id: capabilityTimer
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root._refreshCapability()
    }

    onCurrentlyPlayingChanged: {
        if (currentlyPlaying)
            _lastActive = currentlyPlaying;
    }

    onPlayersChanged: {
        if (root.selectedPlayer && root.players.indexOf(root.selectedPlayer) < 0)
            root.selectedPlayer = null;
    }

    Component.onCompleted: root._refreshCapability()
}
