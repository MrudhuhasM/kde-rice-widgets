// DisplayValue.qml
// Renders a numeric / time string with the DISPLAY font for digits only.
// ':' '.' '-' are drawn as QML geometry so they never depend on the display
// font's (often irregular) punctuation glyphs. Everything else (e, +, letters)
// falls back to the body font.
//
// Width is estimated analytically (not from child geometry) so there is no
// binding loop between the auto-fit size and the laid-out row width.

import QtQuick

Item {
    id: root

    property string text: "0"
    property int pixelSize: 32
    property color color: "#ECEFF4"
    property color separatorColor: color
    property string displayFamily: "monospace"
    property string bodyFamily: ""
    property bool bold: false
    property real digitSpacing: 0.0
    property int horizontalAlignment: Qt.AlignLeft
    property int minPixelSize: 0            // 0 = never shrink

    // Per-character advance as a fraction of the effective pixel size.
    function _advance(ch) {
        if (ch >= "0" && ch <= "9") return 0.62
        if (ch === ":" || ch === "-" || ch === "−") return 0.42
        if (ch === ".") return 0.34
        if (ch === " ") return 0.28
        return 0.52
    }
    readonly property real _naturalWidth: {
        var w = 0
        for (var i = 0; i < text.length; ++i) w += _advance(text.charAt(i)) * root.pixelSize
        return w + Math.max(0, text.length - 1) * root.digitSpacing
    }
    readonly property int _effective: {
        if (root.minPixelSize <= 0 || width <= 0 || root._naturalWidth <= width)
            return root.pixelSize
        return Math.max(root.minPixelSize,
                        Math.floor(root.pixelSize * width / root._naturalWidth))
    }
    readonly property real _dot: Math.max(2, Math.round(_effective * 0.12))

    implicitWidth: _naturalWidth
    implicitHeight: pixelSize * 1.15

    Row {
        id: rowLayout
        height: parent.height
        spacing: root.digitSpacing
        anchors.left: root.horizontalAlignment === Qt.AlignLeft ? parent.left : undefined
        anchors.right: root.horizontalAlignment === Qt.AlignRight ? parent.right : undefined
        anchors.horizontalCenter: root.horizontalAlignment === Qt.AlignHCenter ? parent.horizontalCenter : undefined

        Repeater {
            model: root.text.length
            delegate: Item {
                id: cell
                readonly property string ch: root.text.charAt(index)
                readonly property bool isDigit: ch >= "0" && ch <= "9"
                readonly property bool isColon: ch === ":"
                readonly property bool isDotCh: ch === "."
                readonly property bool isMinus: ch === "-" || ch === "−"
                readonly property bool isSpace: ch === " "

                width: root._advance(ch) * root._effective
                height: rowLayout.height

                Text {
                    visible: !cell.isColon && !cell.isDotCh && !cell.isMinus && !cell.isSpace
                    anchors.centerIn: parent
                    text: cell.ch
                    color: root.color
                    font.family: cell.isDigit ? root.displayFamily : root.bodyFamily
                    font.pixelSize: cell.isDigit ? root._effective : Math.round(root._effective * 0.64)
                    font.bold: root.bold
                    renderType: Text.NativeRendering
                }

                Column {   // ':'
                    visible: cell.isColon
                    anchors.centerIn: parent
                    spacing: root._effective * 0.20
                    Repeater {
                        model: 2
                        delegate: Rectangle { width: root._dot; height: root._dot; color: root.separatorColor }
                    }
                }

                Rectangle {   // '.'
                    visible: cell.isDotCh
                    width: root._dot; height: root._dot
                    color: root.separatorColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: root._effective * 0.30
                }

                Rectangle {   // '-'
                    visible: cell.isMinus
                    width: root._effective * 0.30
                    height: Math.max(2, root._dot)
                    color: root.separatorColor
                    anchors.centerIn: parent
                }
            }
        }
    }
}
