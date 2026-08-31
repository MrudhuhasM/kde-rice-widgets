// ActionRow.qml
// Minimal session actions via the native SessionManagement object — no shelling
// out to systemctl/loginctl. Only shows actions the environment reports as
// available. Text-only, quiet, appears near the bottom.

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.private.sessions as Sessions

RowLayout {
    id: root

    property color primaryColor: "#FFFFFF"
    property color secondaryColor: "#B9B9B9"
    property color accentColor: "#D71920"
    property string bodyFont: ""

    signal aboutToSuspend()

    spacing: 28

    Sessions.SessionManagement {
        id: session
        onAboutToSuspend: root.aboutToSuspend()
    }

    component ActionText: Text {
        id: actionText
        signal triggered()
        font.family: root.bodyFont
        font.pixelSize: 11
        font.letterSpacing: 2.5
        font.capitalization: Font.AllUppercase
        color: hover.hovered ? root.primaryColor : root.secondaryColor
        opacity: hover.hovered ? 1.0 : 0.7
        style: Text.Raised
        styleColor: Qt.rgba(0, 0, 0, 0.5)
        Behavior on opacity { NumberAnimation { duration: 120 } }
        HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: actionText.triggered() }
        Accessible.role: Accessible.Button
        Accessible.name: actionText.text
    }

    Item { Layout.fillWidth: true }

    ActionText {
        text: i18nd("plasma_shell_org.kde.plasma.desktop", "Sleep")
        visible: session.canSuspend
        onTriggered: session.suspend()
    }
    ActionText {
        text: i18nd("plasma_shell_org.kde.plasma.desktop", "Switch User")
        visible: session.canSwitchUser
        onTriggered: session.switchUser()
    }

    Item { Layout.fillWidth: true }
}
