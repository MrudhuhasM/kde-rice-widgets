// Keypad.qml
// Supporting mouse interaction for the keyboard-first calculator.
// Left: a 3-column digit cluster (bare glyphs). Right: a slim operator rail.
// Bottom: a utility strip ending in the restrained red '=' action.

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property color primaryColor: "#ECEFF4"
    property color secondaryColor: "#7B889B"
    property color accentColor: "#D71920"
    property string bodyFamily: ""
    property int fontSize: 15
    property bool enableAnimations: true

    signal append(string token)
    signal equals()
    signal clear()
    signal backspace()
    signal ans()

    spacing: 8

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 14

        GridLayout {
            id: digitGrid
            columns: 3
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.horizontalStretchFactor: 3
            rowSpacing: 4
            columnSpacing: 4

            Repeater {
                model: ["7","8","9","4","5","6","1","2","3"]
                delegate: KeyGlyph {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: modelData
                    kind: "digit"
                    primaryColor: root.primaryColor; secondaryColor: root.secondaryColor
                    accentColor: root.accentColor; bodyFamily: root.bodyFamily
                    fontSize: root.fontSize; enableAnimations: root.enableAnimations
                    onActivated: root.append(modelData)
                }
            }

            KeyGlyph {
                Layout.fillWidth: true; Layout.fillHeight: true
                label: "0"; kind: "digit"
                primaryColor: root.primaryColor; secondaryColor: root.secondaryColor
                accentColor: root.accentColor; bodyFamily: root.bodyFamily
                fontSize: root.fontSize; enableAnimations: root.enableAnimations
                onActivated: root.append("0")
            }
            KeyGlyph {
                Layout.fillWidth: true; Layout.fillHeight: true
                label: "."; kind: "digit"
                primaryColor: root.primaryColor; secondaryColor: root.secondaryColor
                accentColor: root.accentColor; bodyFamily: root.bodyFamily
                fontSize: root.fontSize; enableAnimations: root.enableAnimations
                onActivated: root.append(".")
            }
            KeyGlyph {
                Layout.fillWidth: true; Layout.fillHeight: true
                label: "⌫"; kind: "utility"       // ⌫
                primaryColor: root.primaryColor; secondaryColor: root.secondaryColor
                accentColor: root.accentColor; bodyFamily: root.bodyFamily
                fontSize: root.fontSize; enableAnimations: root.enableAnimations
                onActivated: root.backspace()
            }
        }

        ColumnLayout {
            id: opRail
            Layout.fillHeight: true
            Layout.preferredWidth: 40
            Layout.horizontalStretchFactor: 1
            spacing: 4

            Repeater {
                model: [
                    { g: "÷", t: "÷" },   // ÷
                    { g: "×", t: "×" },   // ×
                    { g: "−", t: "−" },   // −
                    { g: "+",      t: "+"      }
                ]
                delegate: KeyGlyph {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: modelData.g
                    kind: "operator"
                    primaryColor: root.primaryColor; secondaryColor: root.secondaryColor
                    accentColor: root.accentColor; bodyFamily: root.bodyFamily
                    fontSize: root.fontSize + 1; enableAnimations: root.enableAnimations
                    onActivated: root.append(modelData.t)
                }
            }
        }
    }

    // Utility strip
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        spacing: 4

        KeyGlyph {
            Layout.fillWidth: true; Layout.fillHeight: true
            label: "AC"; kind: "utility"
            primaryColor: root.primaryColor; secondaryColor: root.secondaryColor
            accentColor: root.accentColor; bodyFamily: root.bodyFamily
            fontSize: Math.round(root.fontSize * 0.82); enableAnimations: root.enableAnimations
            onActivated: root.clear()
        }
        KeyGlyph {
            Layout.fillWidth: true; Layout.fillHeight: true
            label: "( )"; kind: "utility"
            primaryColor: root.primaryColor; secondaryColor: root.secondaryColor
            accentColor: root.accentColor; bodyFamily: root.bodyFamily
            fontSize: Math.round(root.fontSize * 0.82); enableAnimations: root.enableAnimations
            // Smart paren: append ')' if it balances, else '('.
            onActivated: root.append("(")
        }
        KeyGlyph {
            Layout.fillWidth: true; Layout.fillHeight: true
            label: ")"; kind: "utility"
            primaryColor: root.primaryColor; secondaryColor: root.secondaryColor
            accentColor: root.accentColor; bodyFamily: root.bodyFamily
            fontSize: Math.round(root.fontSize * 0.82); enableAnimations: root.enableAnimations
            onActivated: root.append(")")
        }
        KeyGlyph {
            Layout.fillWidth: true; Layout.fillHeight: true
            label: "%"; kind: "utility"
            primaryColor: root.primaryColor; secondaryColor: root.secondaryColor
            accentColor: root.accentColor; bodyFamily: root.bodyFamily
            fontSize: Math.round(root.fontSize * 0.82); enableAnimations: root.enableAnimations
            onActivated: root.append("%")
        }
        KeyGlyph {
            Layout.fillWidth: true; Layout.fillHeight: true
            label: "ANS"; kind: "utility"
            primaryColor: root.primaryColor; secondaryColor: root.secondaryColor
            accentColor: root.accentColor; bodyFamily: root.bodyFamily
            fontSize: Math.round(root.fontSize * 0.72); enableAnimations: root.enableAnimations
            onActivated: root.ans()
        }
        KeyGlyph {
            Layout.fillWidth: true; Layout.fillHeight: true
            Layout.horizontalStretchFactor: 2
            label: "="; kind: "accent"
            primaryColor: root.primaryColor; secondaryColor: root.secondaryColor
            accentColor: root.accentColor; bodyFamily: root.bodyFamily
            fontSize: root.fontSize + 2; enableAnimations: root.enableAnimations
            onActivated: root.equals()
        }
    }
}
