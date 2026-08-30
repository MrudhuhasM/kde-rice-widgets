import QtQuick

Item {
    id: root

    property real progress: 0.0 // 0.0 to 1.0
    property color accentColor: "#b72b2b"
    property color secondaryColor: "#808080"
    property bool isCritical: false
    property bool enableAnimations: true

    implicitWidth: 200
    implicitHeight: 12

    // Clamped progress
    readonly property real clampedProgress: Math.max(0.0, Math.min(1.0, root.progress))

    // Background track line
    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        color: root.secondaryColor
        opacity: 0.35
    }

    // Left terminal bracket tick
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 5
        color: root.secondaryColor
        opacity: 0.5
    }

    // Right terminal bracket tick
    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 5
        color: root.secondaryColor
        opacity: 0.5
    }

    // Center midpoint notch
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 3
        color: root.secondaryColor
        opacity: 0.3
    }

    // Active progress fill line
    Rectangle {
        id: fillLine
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        width: marker.x + (marker.width / 2)
        color: root.accentColor
        opacity: root.isCritical ? criticalPulse.pulseOpacity : 0.85
    }

    // Geometric indicator marker (Precision Diamond)
    Item {
        id: marker
        width: 8
        height: 8
        anchors.verticalCenter: parent.verticalCenter
        x: (root.width - width) * root.clampedProgress

        Behavior on x {
            enabled: root.enableAnimations
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }
        }

        // Diamond shape (rotated square)
        Rectangle {
            anchors.centerIn: parent
            width: 5
            height: 5
            rotation: 45
            color: root.accentColor
            antialiasing: true
            opacity: root.isCritical ? criticalPulse.pulseOpacity : 1.0
        }

        // Outer reticle ring
        Rectangle {
            anchors.centerIn: parent
            width: 7
            height: 7
            rotation: 45
            color: "transparent"
            border.color: root.accentColor
            border.width: 1
            antialiasing: true
            opacity: root.isCritical ? criticalPulse.pulseOpacity * 0.6 : 0.4
        }
    }

    // Subtle breathing pulse for critical urgency
    QtObject {
        id: criticalPulse
        property real pulseOpacity: 1.0

        SequentialAnimation on pulseOpacity {
            running: root.isCritical && root.enableAnimations
            loops: Animation.Infinite

            NumberAnimation {
                to: 0.35
                duration: 1000
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                to: 1.0
                duration: 1000
                easing.type: Easing.InOutSine
            }
        }
    }
}
