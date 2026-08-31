// UsageIndicator.qml
// Nothing-inspired segmented dot meter for CPU / RAM.
// A fixed row of dots; filled dots represent the current percentage.
// Filled = primary colour, empty = secondary colour at low opacity.
// The last filled dot turns accent-red only while in a warning state.
//
// This deliberately replaces the conventional thick progress bar — it stays
// visually quiet and reads at a glance.

import QtQuick

Item {
    id: root

    property real percentage: 0.0          // 0 - 100
    property int segments: 10
    property color primaryColor: "#ECEFF4"
    property color secondaryColor: "#7B889B"
    property color accentColor: "#B72B2B"
    property bool isWarning: false
    property bool enableAnimations: true
    property real dotSize: 5
    property real dotSpacing: 4

    implicitWidth: segments * dotSize + (segments - 1) * dotSpacing
    implicitHeight: dotSize

    // Smoothed fill count so the meter interpolates instead of snapping.
    property real _fill: 0.0
    Behavior on _fill {
        enabled: root.enableAnimations
        NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
    }
    onPercentageChanged: _fill = Math.max(0, Math.min(root.segments,
                                    root.percentage / 100.0 * root.segments))
    Component.onCompleted: _fill = root.percentage / 100.0 * root.segments

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.dotSpacing

        Repeater {
            model: root.segments
            delegate: Rectangle {
                width: root.dotSize
                height: root.dotSize
                radius: width / 2
                readonly property bool filled: index < Math.round(root._fill)
                readonly property bool isLastFilled: index === Math.round(root._fill) - 1
                color: filled
                       ? ((root.isWarning && isLastFilled) ? root.accentColor : root.primaryColor)
                       : root.secondaryColor
                opacity: filled ? (root.isWarning && isLastFilled ? 1.0 : 0.85) : 0.22

                Behavior on color {
                    enabled: root.enableAnimations
                    ColorAnimation { duration: 200 }
                }
                Behavior on opacity {
                    enabled: root.enableAnimations
                    NumberAnimation { duration: 200 }
                }
            }
        }
    }
}
