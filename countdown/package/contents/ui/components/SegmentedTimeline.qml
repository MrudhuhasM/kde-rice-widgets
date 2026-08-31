// SegmentedTimeline.qml
// A row of thin geometric segments representing REAL elapsed progress
// (elapsed / total span). The leading segment is the "playhead".
//   normal    : monochrome, playhead = primary
//   urgent    : playhead turns accent
//   critical  : playhead turns accent and breathes once per ~2s
//   completed : every segment filled, last one accent
// No decorative motion — segment count only changes with actual progress.

import QtQuick

Item {
    id: root

    property real progress: 0.0            // 0 – 1
    property int segments: 40
    property color primaryColor: "#ECEFF4"
    property color secondaryColor: "#7B889B"
    property color accentColor: "#D71920"
    property string urgency: "normal"      // normal | urgent | critical | completed
    property bool enableAnimations: true

    implicitHeight: 6
    implicitWidth: 200

    readonly property real _clamped: Math.max(0, Math.min(1, progress))

    // Bound directly; the Behavior animates whenever the binding re-evaluates.
    property real _fillReal: root.urgency === "completed"
        ? root.segments
        : Math.round(root._clamped * root.segments)
    Behavior on _fillReal {
        enabled: root.enableAnimations
        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
    }

    property real _pulse: 1.0
    SequentialAnimation on _pulse {
        running: root.urgency === "critical" && root.enableAnimations
        loops: Animation.Infinite
        NumberAnimation { to: 0.3; duration: 950; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0; duration: 950; easing.type: Easing.InOutSine }
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: Math.max(1, (parent.width / root.segments) * 0.4)

        Repeater {
            model: root.segments
            delegate: Rectangle {
                width: Math.max(1, (root.width - (root.segments - 1) *
                       Math.max(1, (root.width / root.segments) * 0.4)) / root.segments)
                height: root.implicitHeight
                anchors.verticalCenter: parent.verticalCenter

                readonly property bool lit: index < Math.round(root._fillReal)
                readonly property bool head: index === Math.round(root._fillReal) - 1
                readonly property bool accentHead: head &&
                    (root.urgency === "urgent" || root.urgency === "critical" || root.urgency === "completed")

                color: lit ? (accentHead ? root.accentColor : root.primaryColor) : root.secondaryColor
                opacity: {
                    if (!lit) return 0.18
                    if (accentHead && root.urgency === "critical") return root._pulse
                    return accentHead ? 1.0 : 0.85
                }
                Behavior on color {
                    enabled: root.enableAnimations
                    ColorAnimation { duration: 200 }
                }
            }
        }
    }
}
