// ResultValue.qml
// The visual anchor of the calculator: the current result / error, in the
// DISPLAY font, right-aligned, auto-shrinking so long results never clip.
// On value change the new result slides up a few px and fades in.

import QtQuick

Item {
    id: root

    property string text: "0"
    property int pixelSize: 40
    property color textColor: "#ECEFF4"
    property color accentColor: "#D71920"
    property bool isError: false
    property bool enableAnimations: true
    property string displayFamily: "monospace"
    property string bodyFamily: ""

    implicitHeight: pixelSize * 1.2

    DisplayValue {
        id: value
        anchors.fill: parent
        text: root.text
        pixelSize: root.isError ? Math.round(root.pixelSize * 0.5) : root.pixelSize
        minPixelSize: Math.round(root.pixelSize * 0.34)
        color: root.isError ? root.accentColor : root.textColor
        separatorColor: root.isError ? root.accentColor : root.accentColor
        displayFamily: root.displayFamily
        bodyFamily: root.bodyFamily
        bold: false
        horizontalAlignment: Qt.AlignRight

        transform: Translate { id: slide; y: 0 }
    }

    onTextChanged: {
        if (!root.enableAnimations) return
        slideAnim.stop(); fadeAnim.stop()
        slide.y = root.pixelSize * 0.22
        value.opacity = 0.0
        slideAnim.start(); fadeAnim.start()
    }

    NumberAnimation {
        id: slideAnim
        target: slide; property: "y"; to: 0
        duration: 190; easing.type: Easing.OutCubic
    }
    NumberAnimation {
        id: fadeAnim
        target: value; property: "opacity"; to: 1.0
        duration: 190; easing.type: Easing.OutCubic
    }

    // Single subtle pulse when an error appears.
    onIsErrorChanged: if (root.isError && root.enableAnimations) errPulse.restart()
    SequentialAnimation {
        id: errPulse
        NumberAnimation { target: value; property: "scale"; to: 1.05; duration: 90; easing.type: Easing.OutQuad }
        NumberAnimation { target: value; property: "scale"; to: 1.0;  duration: 130; easing.type: Easing.OutQuad }
    }
}
