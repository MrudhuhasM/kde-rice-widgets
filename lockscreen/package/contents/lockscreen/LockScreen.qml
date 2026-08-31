/*
 * Nothing Lock — com.mrudhuhas.nothinglock
 * Minimal Nothing-inspired Plasma 6 lock screen.
 *
 * This file is the `lockscreenmainscript` of a Plasma/Shell package that
 * falls back to org.kde.plasma.desktop for everything else, so installing it
 * changes ONLY the lock screen.
 *
 * Authentication uses the `authenticator` context object provided by
 * kscreenlocker (org.kde.kscreenlocker / PamAuthenticators):
 *   authenticator.startAuthenticating()   — open / refresh the PAM conversation
 *   authenticator.respond(password)        — submit the secret
 *   signals: succeeded(), failed(kind), errorMessageChanged(), infoMessageChanged(),
 *            promptChanged(), promptForSecretChanged()
 * The password string only ever travels to authenticator.respond(); it is never
 * logged, printed, or persisted.
 *
 * The wallpaper is supplied and positioned behind this item by kscreenlocker
 * (the `wallpaper` context property); we only draw a subtle overlay on top.
 */

import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kscreenlocker as ScreenLocker
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator

import "components"

Item {
    id: root

    // --- properties kscreenlocker reads / writes ---------------------------
    property bool locked: true
    property bool viewVisible: false
    signal clearPassword()
    property string notification: ""
    signal notificationRepeated()

    implicitWidth: 1920
    implicitHeight: 1080
    focus: true

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    // --- configuration (our config.xml, group [Greeter][LnF]) --------------
    function opt(key, def) {
        try {
            if (typeof config !== "undefined" && config && config[key] !== undefined && config[key] !== null)
                return config[key]
        } catch (e) {}
        return def
    }

    readonly property color accentColor: root.opt("accentColor", "#D71920")
    readonly property color primaryColor: "#F2F2F2"
    readonly property color secondaryColor: "#B5B5B5"

    // --- fonts: Ndot for digits, system sans for everything else ----------
    function _fontAvailable(f) { return f && f.length > 0 && Qt.fontFamilies().indexOf(f) !== -1 }
    readonly property string bodyFont: Kirigami.Theme.defaultFont.family
    readonly property string displayFont: {
        if (root.opt("useDisplayFont", true) === false) return "monospace"
        const want = String(root.opt("displayFont", "Ndot")).trim()
        const cands = want.length ? [want, want.replace(" ", ""), "Ndot", "NDot"] : []
        for (let i = 0; i < cands.length; ++i)
            if (root._fontAvailable(cands[i])) return cands[i]
        return "monospace"   // graceful fallback keeps digit alignment
    }

    // --- reveal / idle state ---------------------------------------------
    property bool uiVisible: false
    property bool activeScreen: true

    function reveal() {
        root.uiVisible = true
        fadeoutTimer.restart()
        if (root.activeScreen)
            passwordField.forceActiveFocus()
    }

    onClearPassword: {
        passwordField.clear()
        passwordField.busy = false
    }

    // combined status line: caps-lock hint + live PAM message
    property string authMessage: ""
    property bool authError: false
    readonly property string statusText: {
        const parts = []
        if (capsLock.locked)
            parts.push(i18nd("plasma_shell_org.kde.plasma.desktop", "Caps Lock is on"))
        if (root.authMessage.length)
            parts.push(root.authMessage)
        return parts.join("   •   ")
    }

    function submit(password) {
        if (!password || password.length === 0)
            return
        passwordField.busy = true
        authenticator.startAuthenticating()
        authenticator.respond(password)
    }

    // ------------------------------------------------------------------
    // AUTHENTICATION
    // ------------------------------------------------------------------
    Connections {
        target: authenticator

        function onSucceeded() {
            // Hand back to the normal Plasma unlock flow immediately.
            Qt.quit()
        }

        function onFailed(kind) {
            if (kind && kind !== 0) return       // a non-interactive method failed; ignore here
            passwordField.busy = false
            root.authError = true
            root.authMessage = i18nd("plasma_shell_org.kde.plasma.desktop", "Unlocking failed")
            root.clearPassword()
            authenticator.startAuthenticating()
            clearErrorTimer.restart()
        }

        function onErrorMessageChanged() {
            const m = authenticator.errorMessage
            if (m && m.length) {
                passwordField.busy = false
                root.authError = true
                root.authMessage = m
                clearErrorTimer.restart()
            }
        }
        function onInfoMessageChanged() {
            const m = authenticator.infoMessage
            if (m && m.length) {
                root.authError = false
                root.authMessage = m
            }
        }
        function onPromptChanged() {
            const m = authenticator.prompt
            if (m && m.length) {
                root.authError = false
                root.authMessage = m
            }
        }
        function onPromptForSecretChanged() {
            passwordField.forceActiveFocus()
            const m = authenticator.promptForSecret
            if (m && m.length) {
                root.authError = false
                root.authMessage = m
            }
        }
    }

    Timer {
        id: heartbeat
        interval: 1000; repeat: true
        running: root.uiVisible
        onTriggered: authenticator.startAuthenticating()
    }
    Timer {
        id: clearErrorTimer
        interval: 3500
        onTriggered: { root.authMessage = ""; root.authError = false }
    }
    Timer {
        id: fadeoutTimer
        interval: 20000
        onTriggered: if (passwordField.text.length === 0) root.uiVisible = false
    }

    onUiVisibleChanged: if (uiVisible) authenticator.startAuthenticating()

    // Multi-screen: kscreenlocker creates one view per screen; only the screen
    // under the cursor shows the auth block.
    ScreenLocker.ActiveScreenMonitor {
        id: screenMonitor
        lockscreenState: ScreenLocker.LockscreenState
        window: root.Window.window
        onActiveChanged: {
            root.activeScreen = active
            if (!active) root.uiVisible = false
        }
    }

    KeyboardIndicator.KeyState {
        id: capsLock
        key: Qt.Key_CapsLock
    }

    // Reveal UI on any interaction (matches the stock locker's behaviour).
    Keys.onEscapePressed: {
        if (root.uiVisible) {
            root.uiVisible = false
            root.clearPassword()
        }
    }
    Keys.onPressed: event => {
        root.reveal()
        event.accepted = false
    }

    MouseArea {
        id: catcher
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.uiVisible ? Qt.ArrowCursor : Qt.BlankCursor
        acceptedButtons: Qt.AllButtons
        property bool movedOnce: false
        onPressed: mouse => { root.reveal(); mouse.accepted = false }
        onPositionChanged: { if (movedOnce) root.reveal(); movedOnce = true }
        onWheel: wheel => { root.reveal(); wheel.accepted = false }
    }

    // ------------------------------------------------------------------
    // LEGIBILITY OVERLAY — subtle; the wallpaper stays dominant
    // ------------------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.uiVisible
                 ? Math.min(0.6, root.opt("overlayOpacity", 0.22) + 0.08)
                 : root.opt("overlayOpacity", 0.22)
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration } }
    }

    // ------------------------------------------------------------------
    // CONTENT
    // ------------------------------------------------------------------
    Item {
        id: stage
        anchors.fill: parent
        opacity: 0
        Component.onCompleted: introAnim.start()
        NumberAnimation {
            id: introAnim
            target: stage; property: "opacity"
            from: 0; to: 1
            duration: Kirigami.Units.longDuration * 2
            easing.type: Easing.OutCubic
        }

        // CLOCK — upper third
        ClockBlock {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.round(parent.height * 0.30) - height / 2
            visible: root.opt("alwaysShowClock", true)
                     && !(root.opt("hideClockWhenIdle", false) && !root.uiVisible)
            use24Hour: root.opt("use24Hour", true)
            showSeconds: root.opt("showSeconds", false)
            showDate: root.opt("showDate", true)
            displayFont: root.displayFont
            bodyFont: root.bodyFont
            primaryColor: root.primaryColor
            secondaryColor: root.secondaryColor
            accentColor: root.accentColor
            timePixelSize: Math.max(56, Math.min(120, Math.round(parent.height * 0.11)))
        }

        // AUTH — lower centre, active screen only
        ColumnLayout {
            id: authBlock
            width: Math.min(parent.width - Kirigami.Units.gridUnit * 4, 320)
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.round(parent.height * 0.58)
            spacing: Kirigami.Units.largeSpacing
            visible: root.activeScreen
            opacity: root.uiVisible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration } }

            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: root.opt("showUserName", true)
                         && typeof kscreenlocker_userName !== "undefined"
                         && String(kscreenlocker_userName).length > 0
                text: typeof kscreenlocker_userName !== "undefined" ? kscreenlocker_userName : ""
                font.family: root.bodyFont
                font.pixelSize: 13
                font.letterSpacing: 1.5
                color: root.secondaryColor
                style: Text.Raised
                styleColor: Qt.rgba(0, 0, 0, 0.5)
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: i18nd("plasma_shell_org.kde.plasma.desktop", "Password")
                font.family: root.bodyFont
                font.pixelSize: 10
                font.letterSpacing: 3
                font.capitalization: Font.AllUppercase
                color: root.secondaryColor
                opacity: 0.7
            }

            PasswordField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                primaryColor: root.primaryColor
                secondaryColor: root.secondaryColor
                accentColor: root.accentColor
                bodyFont: root.bodyFont
                onAccepted: password => root.submit(password)
                // The field keeps focus even while hidden, so a keystroke wakes the UI.
                onTextChanged: if (text.length > 0) root.reveal()
            }

            StatusLabel {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(implicitHeight, Kirigami.Units.gridUnit)
                text: root.statusText
                isError: root.authError
                normalColor: root.secondaryColor
                accentColor: root.accentColor
                bodyFont: root.bodyFont
            }
        }

        // BOTTOM — battery + minimal actions
        RowLayout {
            anchors {
                left: parent.left; right: parent.right; bottom: parent.bottom
                margins: Kirigami.Units.gridUnit
            }
            opacity: root.uiVisible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration } }

            BatteryTag {
                visible: root.opt("showBattery", true)
                primaryColor: root.primaryColor
                secondaryColor: root.secondaryColor
                accentColor: root.accentColor
                bodyFont: root.bodyFont
            }

            Item { Layout.fillWidth: true }

            ActionRow {
                visible: root.opt("showActions", true) && root.activeScreen
                Layout.preferredWidth: parent.width * 0.45
                primaryColor: root.primaryColor
                secondaryColor: root.secondaryColor
                accentColor: root.accentColor
                bodyFont: root.bodyFont
                onAboutToSuspend: root.clearPassword()
            }
        }
    }

    Component.onCompleted: {
        // Field holds focus even while hidden, so the first keystroke after
        // wake lands in it (matches the stock locker).
        passwordField.forceActiveFocus()
    }
}
