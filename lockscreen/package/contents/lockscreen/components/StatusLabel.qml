// StatusLabel.qml
// Authentication status / PAM conversation / error text.
// Small, uppercase, wide-tracked. On an error it does ONE short fade pulse and
// the text turns restrained red. No shake, no loop.

import QtQuick

Item {
    id: root

    property string text: ""
    property bool isError: false
    property color normalColor: "#B9B9B9"
    property color accentColor: "#D71920"
    property string bodyFont: ""

    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.fill: parent
        text: root.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: root.bodyFont
        font.pixelSize: 12
        font.letterSpacing: 2.5
        font.capitalization: Font.AllUppercase
        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
        color: root.isError ? root.accentColor : root.normalColor
        opacity: root.text.length > 0 ? 0.9 : 0.0
        style: Text.Raised
        styleColor: Qt.rgba(0, 0, 0, 0.5)

        Behavior on opacity { NumberAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    onIsErrorChanged: if (isError && text.length > 0) pulse.restart()
    onTextChanged: if (isError && text.length > 0) pulse.restart()

    SequentialAnimation {
        id: pulse
        running: false
        NumberAnimation { target: label; property: "scale"; from: 1.0; to: 1.04; duration: 90; easing.type: Easing.OutQuad }
        NumberAnimation { target: label; property: "scale"; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
    }
}
