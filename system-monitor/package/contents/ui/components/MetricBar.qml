import QtQuick

Item {
    id: root

    property real percentage: 0.0 // 0 to 100
    property color barColor: "#ECEFF4"
    property color trackColor: "#7B889B"
    property color accentColor: "#B72B2B"
    property int barHeight: 2
    property bool isWarning: false
    property bool enableAnimations: true

    implicitWidth: 200
    implicitHeight: Math.max(6, root.barHeight + 4)

    // Clamped ratio (0.0 to 1.0)
    readonly property real ratio: Math.max(0.0, Math.min(1.0, root.percentage / 100.0))

    // Background track baseline
    Rectangle {
        id: trackLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        color: root.trackColor
        opacity: 0.25
    }

    // Left terminal endcap tick
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 4
        color: root.trackColor
        opacity: 0.4
    }

    // Right terminal endcap tick
    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 4
        color: root.trackColor
        opacity: 0.4
    }

    // Active progress fill bar
    Rectangle {
        id: fillBar
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: root.barHeight
        width: root.width * root.ratio
        color: root.isWarning ? root.accentColor : root.barColor
        opacity: root.isWarning ? 0.95 : 0.8

        Behavior on width {
            enabled: root.enableAnimations
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }
        }

        Behavior on color {
            enabled: root.enableAnimations
            ColorAnimation { duration: 180 }
        }
    }
}
