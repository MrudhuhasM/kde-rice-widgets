// Countdown — com.mrudhuhas.countdown
// A Nothing-inspired countdown instrument. Hero = remaining time in the
// DISPLAY font; a segmented dot timeline shows real elapsed progress.
// The hierarchy adapts to the remaining scale (days / hours / minutes).
//
// TRANSPARENCY CONTRACT (unchanged):
//   Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
//   preferredRepresentation: fullRepresentation   (no compactRepresentation)
//
// All date / progress / urgency math below is preserved from the previous
// implementation — only the presentation is new.

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "components"

PlasmoidItem {
    id: root

    Layout.minimumWidth: 180
    Layout.minimumHeight: 120
    Layout.preferredWidth: 300
    Layout.preferredHeight: 190

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    // ── Palette ─────────────────────────────────────────────────────────────
    readonly property color primaryTextColor: {
        const c = Plasmoid.configuration.customTextColor
        return (c && c !== "") ? c : (Kirigami.Theme.textColor || "#ECEFF4")
    }
    readonly property color secondaryTextColor: {
        const c = Plasmoid.configuration.customSecondaryColor
        return (c && c !== "") ? c : (Kirigami.Theme.disabledTextColor || "#7B889B")
    }
    readonly property color accentColor: {
        const c = Plasmoid.configuration.accentColor
        return (c && c !== "") ? c : "#D71920"
    }

    // ── Typography ──────────────────────────────────────────────────────────
    readonly property string bodyFont: Kirigami.Theme.defaultFont.family
    function _fontAvailable(f) { return f && f.length > 0 && Qt.fontFamilies().indexOf(f) !== -1 }
    readonly property string displayFont: {
        if (Plasmoid.configuration.useDisplayFont === false) return "monospace"
        const want = (Plasmoid.configuration.displayFont || "").trim()
        const cands = want.length ? [want, want.replace(" ", ""), want.replace("NDot", "Ndot")] : []
        for (let i = 0; i < cands.length; ++i) if (root._fontAvailable(cands[i])) return cands[i]
        return "monospace"
    }

    readonly property bool enableAnimations: Plasmoid.configuration.enableAnimations !== false

    // ── State (preserved) ───────────────────────────────────────────────────
    property int daysRemaining: 0
    property int hoursRemaining: 0
    property int minutesRemaining: 0
    property int secondsRemaining: 0
    property int totalSecondsRemaining: 0
    property bool isCompleted: false
    property real countdownProgress: 0.0
    property string urgencyState: "normal"      // normal | urgent | critical | completed
    property string targetPrefix: "UNTIL"
    property string targetFormattedString: ""

    function padZero(n) { return (n < 10 ? "0" : "") + n }

    // ── Date parsing (preserved verbatim) ───────────────────────────────────
    function parseTargetDate() {
        let dStr = Plasmoid.configuration.targetDate
        let tStr = Plasmoid.configuration.targetTime || "18:00:00"
        if (!dStr || dStr.trim() === "") {
            let def = new Date()
            def.setDate(def.getDate() + 1)
            dStr = def.getFullYear() + "-" + padZero(def.getMonth() + 1) + "-" + padZero(def.getDate())
        }
        let tp = tStr.split(":")
        let hours = parseInt(tp[0] || "0", 10)
        let minutes = parseInt(tp[1] || "0", 10)
        let seconds = parseInt(tp[2] || "0", 10)
        let dp = dStr.split("-")
        if (dp.length === 3) {
            return new Date(parseInt(dp[0], 10), parseInt(dp[1], 10) - 1, parseInt(dp[2], 10),
                            hours, minutes, seconds)
        }
        let fallback = new Date(dStr + "T" + tStr)
        return isNaN(fallback.getTime()) ? new Date(Date.now() + 3600000) : fallback
    }

    function parseStartDate(targetDateObj) {
        let sDateStr = Plasmoid.configuration.startDate
        let sTimeStr = Plasmoid.configuration.startTime
        if (sDateStr && sDateStr.trim() !== "") {
            let tp = (sTimeStr || "00:00:00").split(":")
            let hours = parseInt(tp[0] || "0", 10)
            let minutes = parseInt(tp[1] || "0", 10)
            let seconds = parseInt(tp[2] || "0", 10)
            let dp = sDateStr.split("-")
            if (dp.length === 3) {
                let parsed = new Date(parseInt(dp[0], 10), parseInt(dp[1], 10) - 1, parseInt(dp[2], 10),
                                      hours, minutes, seconds)
                if (!isNaN(parsed.getTime()) && parsed.getTime() < targetDateObj.getTime()) return parsed
            }
        }
        return new Date(targetDateObj.getTime() - 86400000)
    }

    function formatTarget(targetDateObj, now) {
        const months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"]
        let isToday = targetDateObj.getFullYear() === now.getFullYear()
                   && targetDateObj.getMonth() === now.getMonth()
                   && targetDateObj.getDate() === now.getDate()
        let timeStr = padZero(targetDateObj.getHours()) + ":" + padZero(targetDateObj.getMinutes())
        root.targetPrefix = isToday ? "TODAY" : "UNTIL"
        return isToday
            ? timeStr
            : padZero(targetDateObj.getDate()) + " " + months[targetDateObj.getMonth()] + "  ·  " + timeStr
    }

    // ── Countdown engine (preserved) ────────────────────────────────────────
    function updateCountdown() {
        let now = new Date()
        let target = parseTargetDate()
        let start = parseStartDate(target)
        let diffMs = target.getTime() - now.getTime()

        root.targetFormattedString = formatTarget(target, now)

        if (diffMs <= 0) {
            root.isCompleted = true
            root.daysRemaining = root.hoursRemaining = root.minutesRemaining = root.secondsRemaining = 0
            root.totalSecondsRemaining = 0
            root.countdownProgress = 1.0
            root.urgencyState = "completed"
            return
        }
        root.isCompleted = false

        let totalSeconds = Math.floor(diffMs / 1000)
        root.totalSecondsRemaining = totalSeconds
        root.daysRemaining = Math.floor(totalSeconds / 86400)
        root.hoursRemaining = Math.floor((totalSeconds % 86400) / 3600)
        root.minutesRemaining = Math.floor((totalSeconds % 3600) / 60)
        root.secondsRemaining = totalSeconds % 60

        let totalSpan = target.getTime() - start.getTime()
        let elapsed = now.getTime() - start.getTime()
        root.countdownProgress = totalSpan > 0
            ? Math.max(0.0, Math.min(1.0, elapsed / totalSpan)) : 0.0

        let minutesLeft = diffMs / 60000
        let crit = Plasmoid.configuration.criticalThresholdMinutes || 1
        let urg = Plasmoid.configuration.urgentThresholdMinutes || 10
        root.urgencyState = minutesLeft <= crit ? "critical"
                          : minutesLeft <= urg  ? "urgent" : "normal"
    }

    Timer {
        interval: Plasmoid.configuration.showSeconds ? 1000 : 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateCountdown()
    }

    Connections {
        target: Plasmoid.configuration
        function onTargetDateChanged() { root.updateCountdown() }
        function onTargetTimeChanged() { root.updateCountdown() }
        function onStartDateChanged() { root.updateCountdown() }
        function onStartTimeChanged() { root.updateCountdown() }
        function onShowSecondsChanged() { root.updateCountdown() }
    }

    // ── Derived presentation ────────────────────────────────────────────────
    readonly property bool _showSeconds: Plasmoid.configuration.showSeconds !== false
    readonly property bool _hasDays: root.daysRemaining > 0 && !root.isCompleted

    // Hero string, adapts to remaining scale.
    readonly property string heroText: {
        if (root.isCompleted) {
            const raw = Plasmoid.configuration.completedText || "COMPLETE"
            return raw.toUpperCase()
        }
        const t = root.totalSecondsRemaining
        const hh = root.padZero(root.hoursRemaining)
        const mm = root.padZero(root.minutesRemaining)
        const ss = root.padZero(root.secondsRemaining)
        if (t < 3600) return mm + ":" + ss                 // final hour  -> MM:SS
        return root._showSeconds ? hh + ":" + mm + ":" + ss // has hours   -> HH:MM:SS
                                 : hh + ":" + mm
    }

    // Hero size: base, enlarged for the shorter forms.
    readonly property int heroBase: Plasmoid.configuration.countdownFontSize || 34
    readonly property int heroSize: {
        if (root.isCompleted) return Math.round(root.heroBase * 0.9)
        if (root.totalSecondsRemaining < 60)   return Math.round(root.heroBase * 1.30)
        if (root.totalSecondsRemaining < 3600) return Math.round(root.heroBase * 1.15)
        return root.heroBase
    }
    readonly property color heroColor:
        root.urgencyState === "critical" ? root.accentColor : root.primaryTextColor

    readonly property bool _finalMinutePulse:
        !root.isCompleted && root.totalSecondsRemaining < 60 && root.enableAnimations

    // ── Full representation ─────────────────────────────────────────────────
    fullRepresentation: Item {
        id: view
        Layout.minimumWidth: 180
        Layout.minimumHeight: 120
        Layout.preferredWidth: 300
        Layout.preferredHeight: 190

        readonly property int metaFont: Plasmoid.configuration.detailsFontSize || 10
        readonly property int labelFont: Plasmoid.configuration.titleFontSize || 10

        ColumnLayout {
            id: col
            anchors.centerIn: parent
            width: Math.min(parent.width, 380)
            spacing: 6

            // 1 · target block — restrained, body font
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                visible: Plasmoid.configuration.showTargetDateTime !== false

                Text {
                    text: root.isCompleted ? "" : root.targetPrefix
                    visible: text.length > 0
                    font.family: root.bodyFont
                    font.pixelSize: Math.max(8, view.labelFont - 1)
                    font.letterSpacing: 3.0
                    font.capitalization: Font.AllUppercase
                    color: root.secondaryTextColor
                    opacity: 0.75
                }
                Text {
                    text: root.targetFormattedString
                    visible: !root.isCompleted && text.length > 0
                    font.family: root.bodyFont
                    font.pixelSize: view.metaFont + 1
                    font.letterSpacing: 1.6
                    color: root.secondaryTextColor
                }
            }

            // 2 · days line (only when >= 1 day)
            RowLayout {
                visible: root._hasDays
                Layout.topMargin: 2
                spacing: 8

                DisplayValue {
                    text: root.padZero(root.daysRemaining)
                    pixelSize: Math.round(root.heroBase * 0.7)
                    color: root.primaryTextColor
                    separatorColor: root.accentColor
                    displayFamily: root.displayFont
                    bodyFamily: root.bodyFont
                }
                Text {
                    text: root.daysRemaining === 1 ? "DAY" : "DAYS"
                    font.family: root.bodyFont
                    font.pixelSize: Math.max(9, view.labelFont)
                    font.letterSpacing: 2.5
                    font.bold: true
                    color: root.accentColor
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            // 3 · HERO remaining time / completion word
            CountdownDigits {
                id: hero
                Layout.fillWidth: true
                Layout.preferredHeight: root.heroSize * 1.15
                text: root.heroText
                pixelSize: root.heroSize
                color: root.heroColor
                separatorColor: root.urgencyState === "normal" ? root.secondaryTextColor : root.accentColor
                displayFamily: root.displayFont
                bodyFamily: root.bodyFont
                enableAnimations: root.enableAnimations
                horizontalAlignment: Qt.AlignLeft

                opacity: 1.0
                SequentialAnimation on opacity {
                    running: root._finalMinutePulse
                    loops: Animation.Infinite
                    onRunningChanged: if (!running) hero.opacity = 1.0
                    NumberAnimation { to: 0.45; duration: 700; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
                }
            }

            // 4 · segmented timeline (real progress)
            SegmentedTimeline {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                Layout.topMargin: 4
                visible: Plasmoid.configuration.showProgressLine !== false
                progress: root.countdownProgress
                primaryColor: root.primaryTextColor
                secondaryColor: root.secondaryTextColor
                accentColor: root.accentColor
                urgency: root.urgencyState
                enableAnimations: root.enableAnimations
            }
        }
    }
}
