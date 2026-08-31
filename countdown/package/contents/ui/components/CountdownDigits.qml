// CountdownDigits.qml
// The hero remaining-time readout. Digits use the DISPLAY font; ':' is drawn
// as geometry by DisplayValue. Per-second value changes are NOT animated
// (that would be noisy); only a change in FORMAT (e.g. HH:MM:SS -> MM:SS, or
// switching to the completed word) triggers a short crossfade.

import QtQuick

Item {
    id: root

    property string text: "00:00"
    property int pixelSize: 34
    property color color: "#ECEFF4"
    property color separatorColor: "#D71920"
    property string displayFamily: "monospace"
    property string bodyFamily: ""
    property bool enableAnimations: true
    property int horizontalAlignment: Qt.AlignHCenter

    implicitWidth: value.implicitWidth
    implicitHeight: pixelSize * 1.15

    property int _prevLen: text.length
    onTextChanged: {
        if (root.enableAnimations && text.length !== root._prevLen) fade.restart()
        root._prevLen = text.length
    }

    DisplayValue {
        id: value
        anchors.fill: parent
        text: root.text
        pixelSize: root.pixelSize
        minPixelSize: Math.round(root.pixelSize * 0.4)
        color: root.color
        separatorColor: root.separatorColor
        displayFamily: root.displayFamily
        bodyFamily: root.bodyFamily
        horizontalAlignment: root.horizontalAlignment
    }

    SequentialAnimation {
        id: fade
        NumberAnimation { target: value; property: "opacity"; to: 0.0; duration: 90; easing.type: Easing.OutQuad }
        NumberAnimation { target: value; property: "opacity"; to: 1.0; duration: 170; easing.type: Easing.OutCubic }
    }
}
