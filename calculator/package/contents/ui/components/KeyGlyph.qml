// KeyGlyph.qml
// A single keypad key with NO persistent border or fill.
//   normal   : transparent, just the glyph
//   hover    : a faint geometric backing (rounded rect) fades in
//   pressed  : brief scale + opacity dip
//   accent   : the '=' key — glyph always red; pressed = solid red fill, white glyph
//
// Keys are mouse-only affordances; all keyboard input is handled by main.qml.

import QtQuick

Item {
    id: root

    property string label: ""
    property string kind: "digit"          // digit | operator | utility | accent
    property color primaryColor: "#ECEFF4"
    property color secondaryColor: "#7B889B"
    property color accentColor: "#D71920"
    property string bodyFamily: ""
    property int fontSize: 15
    property bool enableAnimations: true

    signal activated()

    implicitWidth: 40
    implicitHeight: 34

    readonly property bool _accent: kind === "accent"

    scale: (tap.pressed && root.enableAnimations) ? 0.93 : 1.0
    Behavior on scale {
        enabled: root.enableAnimations
        NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
    }

    Rectangle {
        id: backing
        anchors.fill: parent
        anchors.margins: 1
        radius: 3
        color: {
            if (root._accent)
                return tap.pressed ? root.accentColor
                     : Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, hover.hovered ? 0.20 : 0.10)
            if (tap.pressed) return Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.16)
            if (hover.hovered) return Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.08)
            return "transparent"
        }
        Behavior on color {
            enabled: root.enableAnimations
            ColorAnimation { duration: 110 }
        }
    }

    // Accent key keeps a thin outline so it reads as the primary action.
    Rectangle {
        anchors.fill: backing
        radius: 3
        visible: root._accent
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.55)
    }

    Text {
        anchors.centerIn: parent
        text: root.label
        font.family: root.bodyFamily
        font.pixelSize: root.fontSize
        font.bold: root.kind === "operator" || root._accent
        font.letterSpacing: root.kind === "utility" ? 1.0 : 0.5
        color: {
            if (root._accent) return tap.pressed ? "#FFFFFF" : root.accentColor
            if (root.kind === "digit") return root.primaryColor
            return root.secondaryColor
        }
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { id: tap; onTapped: root.activated() }
}
