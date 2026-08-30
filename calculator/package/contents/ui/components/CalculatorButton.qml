import QtQuick
import QtQuick.Controls

Item {
    id: root

    property string text: ""
    property color textColor: "#ECEFF4"
    property color accentColor: "#B72B2B"
    property bool isAccent: false
    property bool isOperator: false
    property int fontSize: 14
    property bool enableAnimations: true

    signal clicked()

    implicitWidth: 44
    implicitHeight: 36

    // Press scale animation
    scale: (mouseArea.pressed && root.enableAnimations) ? 0.94 : 1.0
    Behavior on scale {
        enabled: root.enableAnimations
        NumberAnimation {
            duration: 110
            easing.type: Easing.OutQuad
        }
    }

    // Button frame / hover highlight
    Rectangle {
        id: bg
        anchors.fill: parent
        anchors.margins: 1
        radius: 3
        color: {
            if (mouseArea.pressed) {
                return root.isAccent ? root.accentColor : Qt.rgba(1, 1, 1, 0.15);
            }
            if (mouseArea.containsMouse) {
                return root.isAccent ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25) : Qt.rgba(1, 1, 1, 0.08);
            }
            if (root.isAccent) {
                return Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.12);
            }
            return "transparent";
        }
        border.color: {
            if (root.isAccent) {
                return root.accentColor;
            }
            if (mouseArea.containsMouse) {
                return Qt.rgba(1, 1, 1, 0.3);
            }
            return Qt.rgba(1, 1, 1, 0.12);
        }
        border.width: 1

        Behavior on color {
            enabled: root.enableAnimations
            ColorAnimation { duration: 120 }
        }
        Behavior on border.color {
            enabled: root.enableAnimations
            ColorAnimation { duration: 120 }
        }
    }

    // Button label
    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: root.fontSize
        font.bold: root.isAccent || root.isOperator
        font.letterSpacing: 0.5
        color: {
            if (root.isAccent) {
                return mouseArea.pressed ? "#FFFFFF" : root.accentColor;
            }
            if (root.isOperator) {
                return root.textColor;
            }
            return root.textColor;
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
