// MusicVisualizer.qml
//
// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZER DATA SOURCE — READ THIS
// ─────────────────────────────────────────────────────────────────────────────
// This is NOT a real audio-reactive spectrum. It does not sample PCM data and
// does not run an FFT.
//
// Why: Plasma 6 / Qt 6 expose no pure-QML API for real-time audio amplitude or
// frequency data. PipeWire/PulseAudio monitor-sink capture requires a native
// helper (C/C++ via libpipewire, or Python via sounddevice) feeding QML over a
// socket or shared memory. The KDE Store "Music Waves" widget works exactly
// that way — it ships a compiled native capture helper. The project constraints
// for this repo explicitly forbid a Python/Node/C++ backend or a polling daemon,
// so that route is out of scope for v1.
//
// What this actually is: a DETERMINISTIC, PLAYBACK-STATE-REACTIVE animation.
//   - Bar motion is driven by fixed per-bar sine oscillators (no Math.random,
//     no per-frame randomness) seeded from the bar index only.
//   - The whole field's amplitude envelope follows the real MPRIS playback
//     state: it rises to full only while `isPlaying` is true, eases back to
//     zero on pause, and the ticker stops entirely when idle (0% CPU).
// So the *presence and intensity* of motion is real information (is music
// playing?), while the bar shape is decorative and must not be read as a
// spectrum.
//
// To upgrade to real data later: add a capture helper that writes N amplitude
// floats to $XDG_RUNTIME_DIR/dashboard-viz.sock, read it here with a QML
// Socket/FileIO, and replace `_env * _shape(i)` below with the real sample.
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick

Item {
    id: root

    property bool isPlaying: false
    property bool enableAnimations: true
    property color barColor: "#ECEFF4"
    property color accentColor: "#D71920"
    property int barCount: 24

    implicitHeight: 24
    implicitWidth: 200

    // Amplitude envelope: 1 while playing, eased to 0 otherwise.
    property real _env: 0.0
    Behavior on _env {
        enabled: root.enableAnimations
        NumberAnimation { duration: 550; easing.type: Easing.OutQuad }
    }
    onIsPlayingChanged: _env = root.isPlaying ? 1.0 : 0.0
    Component.onCompleted: _env = root.isPlaying ? 1.0 : 0.0

    property real _t: 0.0
    property var _levels: {
        var a = []; for (var i = 0; i < barCount; i++) a.push(0.0); return a
    }

    // Deterministic per-bar shape — index-seeded, no randomness.
    function _shape(i, t) {
        var center = (root.barCount - 1) / 2.0
        var dist = Math.abs(i - center) / center          // 0 centre .. 1 edge
        var freqA = 1.6 + (1.0 - dist) * 2.2               // centre bars faster
        var freqB = freqA * 1.73
        var phase = i * 0.7
        var v = 0.45
              + 0.38 * Math.sin(t * freqA + phase)
              + 0.17 * Math.sin(t * freqB + phase * 0.5)
        // Taper the edges so the field reads as a soft band.
        v *= (0.35 + 0.65 * (1.0 - dist))
        return Math.max(0.0, Math.min(1.0, v))
    }

    Timer {
        interval: 55                                       // ~18 fps, cheap
        repeat: true
        running: root.isPlaying || root._env > 0.01
        onTriggered: {
            root._t += 0.055
            var out = []
            for (var i = 0; i < root.barCount; i++)
                out.push(root._shape(i, root._t) * root._env)
            root._levels = out
        }
    }

    Row {
        anchors.fill: parent
        spacing: Math.max(1, (root.width / root.barCount) * 0.35)

        Repeater {
            model: root.barCount
            delegate: Item {
                width: (root.width - (root.barCount - 1) *
                        Math.max(1, (root.width / root.barCount) * 0.35)) / root.barCount
                height: root.height

                readonly property real ratio: index < root._levels.length ? root._levels[index] : 0.0
                readonly property bool isCentre: index === Math.round((root.barCount - 1) / 2)

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: Math.max(1, parent.ratio * parent.height)
                    color: parent.isCentre ? root.accentColor : root.barColor
                    opacity: parent.isCentre ? 0.9 : 0.7

                    Behavior on height {
                        enabled: root.enableAnimations
                        NumberAnimation { duration: 90; easing.type: Easing.InOutSine }
                    }
                }
            }
        }
    }

    // Baseline rule
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        color: root.barColor
        opacity: 0.12
    }
}
