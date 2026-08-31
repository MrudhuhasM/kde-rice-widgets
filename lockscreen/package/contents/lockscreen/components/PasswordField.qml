// PasswordField.qml
// Minimal password entry: transparent area, thin underline, hidden bullets,
// a small red focus marker. No filled box, no pill, no card, no shadow.
//
// Security: echoMode Password; the text is never logged or persisted. It leaves
// this component only via the accepted(password) signal.

import QtQuick
import QtQuick.Controls as QQC2

Item {
    id: root

    property color primaryColor: "#FFFFFF"
    property color secondaryColor: "#B9B9B9"
    property color accentColor: "#D71920"
    property string bodyFont: ""
    property alias text: field.text
    property bool busy: false

    signal accepted(string password)

    implicitWidth: 260
    implicitHeight: 40

    function clear() { field.clear() }
    function forceActiveFocus() { field.forceActiveFocus() }

    QQC2.TextField {
        id: field
        anchors.fill: parent
        enabled: !root.busy
        echoMode: TextInput.Password
        passwordCharacter: "•"
        passwordMaskDelay: 0
        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhHiddenText
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        font.family: root.bodyFont
        font.pixelSize: 17
        font.letterSpacing: 4
        color: root.primaryColor
        selectionColor: root.accentColor
        selectedTextColor: root.primaryColor
        persistentSelection: false
        // Wake the greeter / reveal UI is handled by the parent; just take focus.
        focus: true
        cursorVisible: activeFocus

        background: Item {
            // rest: thin quiet underline · focus: brighter underline + red marker
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: field.activeFocus ? root.primaryColor : root.secondaryColor
                opacity: field.activeFocus ? 0.9 : 0.4
                Behavior on opacity { NumberAnimation { duration: 120 } }
                Behavior on color { ColorAnimation { duration: 120 } }
            }
            Rectangle {
                anchors { right: parent.right; bottom: parent.bottom }
                width: 5; height: 5
                color: root.accentColor
                opacity: field.activeFocus ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
        }

        onAccepted: if (field.text.length > 0) root.accepted(field.text)
        Keys.onEscapePressed: event => { event.accepted = false } // let the screen handle Escape
    }
}
