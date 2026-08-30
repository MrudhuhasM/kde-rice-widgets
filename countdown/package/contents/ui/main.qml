import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "components"

PlasmoidItem {
    id: root

    // Desktop widget sizing hints
    Layout.minimumWidth: 160
    Layout.minimumHeight: 75
    Layout.preferredWidth: 260
    Layout.preferredHeight: 130

    // Force transparent background with no Plasma-provided container background
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // -------------------------------------------------------------------------
    // THEME & COLORS
    // -------------------------------------------------------------------------
    readonly property color primaryTextColor: {
        if (Plasmoid.configuration.customTextColor && Plasmoid.configuration.customTextColor !== "") {
            return Plasmoid.configuration.customTextColor;
        }
        return Kirigami.Theme.textColor ? Kirigami.Theme.textColor : "#ECEFF4";
    }

    readonly property color secondaryTextColor: {
        if (Plasmoid.configuration.customSecondaryColor && Plasmoid.configuration.customSecondaryColor !== "") {
            return Plasmoid.configuration.customSecondaryColor;
        }
        return Kirigami.Theme.disabledTextColor ? Kirigami.Theme.disabledTextColor : "#7B889B";
    }

    readonly property color accentColor: {
        if (Plasmoid.configuration.accentColor && Plasmoid.configuration.accentColor !== "") {
            return Plasmoid.configuration.accentColor;
        }
        return "#B72B2B"; // Restrained crimson
    }

    // -------------------------------------------------------------------------
    // STATE & TIME PROPERTIES
    // -------------------------------------------------------------------------
    property int daysRemaining: 0
    property int hoursRemaining: 0
    property int minutesRemaining: 0
    property int secondsRemaining: 0
    property bool isCompleted: false
    property real countdownProgress: 0.0
    property string urgencyState: "normal" // "normal" | "urgent" | "critical" | "completed"
    property string targetFormattedString: ""

    // -------------------------------------------------------------------------
    // COUNTDOWN ENGINE
    // -------------------------------------------------------------------------
    function padZero(num) {
        return (num < 10 ? "0" : "") + num;
    }

    function parseTargetDate() {
        let dStr = Plasmoid.configuration.targetDate;
        let tStr = Plasmoid.configuration.targetTime || "18:00:00";

        if (!dStr || dStr.trim() === "") {
            let def = new Date();
            def.setDate(def.getDate() + 1);
            let y = def.getFullYear();
            let m = padZero(def.getMonth() + 1);
            let d = padZero(def.getDate());
            dStr = y + "-" + m + "-" + d;
        }

        let timeParts = tStr.split(":");
        let hours = parseInt(timeParts[0] || "0", 10);
        let minutes = parseInt(timeParts[1] || "0", 10);
        let seconds = parseInt(timeParts[2] || "0", 10);

        let dateParts = dStr.split("-");
        if (dateParts.length === 3) {
            let year = parseInt(dateParts[0], 10);
            let month = parseInt(dateParts[1], 10) - 1;
            let day = parseInt(dateParts[2], 10);
            return new Date(year, month, day, hours, minutes, seconds);
        }

        let fallback = new Date(dStr + "T" + tStr);
        return isNaN(fallback.getTime()) ? new Date(Date.now() + 3600000) : fallback;
    }

    function parseStartDate(targetDateObj) {
        let sDateStr = Plasmoid.configuration.startDate;
        let sTimeStr = Plasmoid.configuration.startTime;

        if (sDateStr && sDateStr.trim() !== "") {
            let timeParts = (sTimeStr || "00:00:00").split(":");
            let hours = parseInt(timeParts[0] || "0", 10);
            let minutes = parseInt(timeParts[1] || "0", 10);
            let seconds = parseInt(timeParts[2] || "0", 10);

            let dateParts = sDateStr.split("-");
            if (dateParts.length === 3) {
                let year = parseInt(dateParts[0], 10);
                let month = parseInt(dateParts[1], 10) - 1;
                let day = parseInt(dateParts[2], 10);
                let parsed = new Date(year, month, day, hours, minutes, seconds);
                if (!isNaN(parsed.getTime()) && parsed.getTime() < targetDateObj.getTime()) {
                    return parsed;
                }
            }
        }

        return new Date(targetDateObj.getTime() - 86400000);
    }

    function formatTargetDisplay(targetDateObj, now) {
        let isToday = (targetDateObj.getFullYear() === now.getFullYear() &&
                       targetDateObj.getMonth() === now.getMonth() &&
                       targetDateObj.getDate() === now.getDate());

        let timeStr = padZero(targetDateObj.getHours()) + ":" + padZero(targetDateObj.getMinutes());

        if (isToday) {
            return "UNTIL " + timeStr;
        }

        const months = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
                        "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"];
        let monthName = months[targetDateObj.getMonth()] || "";
        return padZero(targetDateObj.getDate()) + " " + monthName + " · " + timeStr;
    }

    function updateCountdown() {
        let now = new Date();
        let target = parseTargetDate();
        let start = parseStartDate(target);

        let diffMs = target.getTime() - now.getTime();

        root.targetFormattedString = formatTargetDisplay(target, now);

        if (diffMs <= 0) {
            root.isCompleted = true;
            root.daysRemaining = 0;
            root.hoursRemaining = 0;
            root.minutesRemaining = 0;
            root.secondsRemaining = 0;
            root.countdownProgress = 1.0;
            root.urgencyState = "completed";
            return;
        }

        root.isCompleted = false;

        let totalSeconds = Math.floor(diffMs / 1000);
        root.daysRemaining = Math.floor(totalSeconds / 86400);
        root.hoursRemaining = Math.floor((totalSeconds % 86400) / 3600);
        root.minutesRemaining = Math.floor((totalSeconds % 3600) / 60);
        root.secondsRemaining = totalSeconds % 60;

        let totalSpan = target.getTime() - start.getTime();
        let elapsed = now.getTime() - start.getTime();
        if (totalSpan > 0) {
            root.countdownProgress = Math.max(0.0, Math.min(1.0, elapsed / totalSpan));
        } else {
            root.countdownProgress = 0.0;
        }

        let totalMinutesRemaining = diffMs / 60000;
        let critThreshold = Plasmoid.configuration.criticalThresholdMinutes || 1;
        let urgThreshold = Plasmoid.configuration.urgentThresholdMinutes || 10;

        if (totalMinutesRemaining <= critThreshold) {
            root.urgencyState = "critical";
        } else if (totalMinutesRemaining <= urgThreshold) {
            root.urgencyState = "urgent";
        } else {
            root.urgencyState = "normal";
        }
    }

    // Refresh timer
    Timer {
        id: updateTimer
        interval: Plasmoid.configuration.showSeconds ? 1000 : 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateCountdown()
    }

    Connections {
        target: Plasmoid.configuration
        function onTargetDateChanged() { root.updateCountdown(); }
        function onTargetTimeChanged() { root.updateCountdown(); }
        function onStartDateChanged() { root.updateCountdown(); }
        function onStartTimeChanged() { root.updateCountdown(); }
        function onShowSecondsChanged() { root.updateCountdown(); }
    }

    // -------------------------------------------------------------------------
    // COMPACT REPRESENTATION (FOR PANELS)
    // -------------------------------------------------------------------------
    compactRepresentation: Item {
        Layout.minimumWidth: compactText.implicitWidth + 8
        Layout.minimumHeight: compactText.implicitHeight + 4

        Text {
            id: compactText
            anchors.centerIn: parent
            text: {
                if (root.isCompleted) {
                    return "00:00";
                }
                if (root.daysRemaining > 0) {
                    return root.padZero(root.daysRemaining) + "d " + root.padZero(root.hoursRemaining) + ":" + root.padZero(root.minutesRemaining);
                }
                return root.padZero(root.hoursRemaining) + ":" + root.padZero(root.minutesRemaining) + (Plasmoid.configuration.showSeconds ? (":" + root.padZero(root.secondsRemaining)) : "");
            }
            font.bold: true
            font.pixelSize: 12
            color: root.urgencyState === "critical" ? root.accentColor : root.primaryTextColor
        }
    }

    // -------------------------------------------------------------------------
    // FULL REPRESENTATION (DESKTOP WIDGET)
    // -------------------------------------------------------------------------
    fullRepresentation: Item {
        id: desktopRepresentation
        Layout.minimumWidth: 160
        Layout.minimumHeight: 75
        Layout.preferredWidth: 260
        Layout.preferredHeight: 130

        ColumnLayout {
            id: mainLayout
            anchors.centerIn: parent
            width: Math.min(parent.width, 320)
            spacing: 4

            // 1. TITLE / OBJECTIVE HEADER
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Rectangle {
                    width: 12
                    height: 1
                    color: root.urgencyState === "critical" || root.urgencyState === "urgent" ? root.accentColor : root.secondaryTextColor
                    opacity: 0.5
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    id: titleLabel
                    text: {
                        if (root.isCompleted) {
                            return Plasmoid.configuration.completedText || "OBJECTIVE COMPLETE";
                        }
                        let raw = Plasmoid.configuration.title || "MISSION ENDS IN";
                        return Plasmoid.configuration.uppercaseTitle ? raw.toUpperCase() : raw;
                    }
                    font.pixelSize: Plasmoid.configuration.titleFontSize || 10
                    font.capitalization: Plasmoid.configuration.uppercaseTitle ? Font.AllUppercase : Font.MixedCase
                    font.letterSpacing: 1.8
                    font.bold: true
                    color: root.isCompleted ? root.accentColor : (root.urgencyState === "critical" ? root.accentColor : root.secondaryTextColor)
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    width: 12
                    height: 1
                    color: root.urgencyState === "critical" || root.urgencyState === "urgent" ? root.accentColor : root.secondaryTextColor
                    opacity: 0.5
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            // 2. MULTI-DAY BADGE (Displayed only when days > 0)
            Item {
                id: daysContainer
                visible: root.daysRemaining > 0 && !root.isCompleted
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: daysContentRow.implicitWidth
                implicitHeight: visible ? daysContentRow.implicitHeight + 2 : 0

                RowLayout {
                    id: daysContentRow
                    anchors.centerIn: parent
                    spacing: 6

                    AnimatedValue {
                        text: root.padZero(root.daysRemaining)
                        font.pixelSize: Math.round((Plasmoid.configuration.countdownFontSize || 28) * 0.75)
                        font.bold: true
                        font.letterSpacing: 1.2
                        color: root.primaryTextColor
                        enableAnimations: Plasmoid.configuration.enableAnimations
                    }

                    Text {
                        text: root.daysRemaining === 1 ? "DAY" : "DAYS"
                        font.pixelSize: Math.round((Plasmoid.configuration.titleFontSize || 10) * 1.1)
                        font.letterSpacing: 1.5
                        font.bold: true
                        color: root.accentColor
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            // 3. MAIN COUNTDOWN DIGITS (HH : MM : SS)
            RowLayout {
                id: timeRow
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                AnimatedValue {
                    text: root.padZero(root.hoursRemaining)
                    font.pixelSize: Plasmoid.configuration.countdownFontSize || 28
                    font.bold: true
                    font.letterSpacing: 1.0
                    color: root.isCompleted ? root.secondaryTextColor : root.primaryTextColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                }

                Text {
                    text: ":"
                    font.pixelSize: Math.round((Plasmoid.configuration.countdownFontSize || 28) * 0.85)
                    font.bold: true
                    color: root.urgencyState === "critical" ? root.accentColor : root.secondaryTextColor
                    opacity: 0.7
                    Layout.alignment: Qt.AlignVCenter
                }

                AnimatedValue {
                    text: root.padZero(root.minutesRemaining)
                    font.pixelSize: Plasmoid.configuration.countdownFontSize || 28
                    font.bold: true
                    font.letterSpacing: 1.0
                    color: root.isCompleted ? root.secondaryTextColor : root.primaryTextColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                }

                Text {
                    visible: Plasmoid.configuration.showSeconds
                    text: ":"
                    font.pixelSize: Math.round((Plasmoid.configuration.countdownFontSize || 28) * 0.85)
                    font.bold: true
                    color: root.urgencyState === "critical" ? root.accentColor : root.secondaryTextColor
                    opacity: 0.7
                    Layout.alignment: Qt.AlignVCenter
                }

                AnimatedValue {
                    visible: Plasmoid.configuration.showSeconds
                    text: root.padZero(root.secondsRemaining)
                    font.pixelSize: Plasmoid.configuration.countdownFontSize || 28
                    font.bold: true
                    font.letterSpacing: 1.0
                    color: root.urgencyState === "critical" ? root.accentColor : (root.isCompleted ? root.secondaryTextColor : root.primaryTextColor)
                    enableAnimations: Plasmoid.configuration.enableAnimations
                }
            }

            // 4. PROGRESS / SEPARATOR LINE
            ProgressLine {
                id: progressSeparator
                visible: Plasmoid.configuration.showProgressLine
                Layout.fillWidth: true
                Layout.preferredHeight: 10
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                progress: root.countdownProgress
                accentColor: root.accentColor
                secondaryColor: root.secondaryTextColor
                isCritical: root.urgencyState === "critical"
                enableAnimations: Plasmoid.configuration.enableAnimations
            }

            // 5. TARGET DATE / TIME FOOTER
            Text {
                id: targetDateLabel
                visible: Plasmoid.configuration.showTargetDateTime && root.targetFormattedString !== ""
                text: root.targetFormattedString
                font.pixelSize: Plasmoid.configuration.detailsFontSize || 10
                font.letterSpacing: 1.4
                color: root.secondaryTextColor
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.85
            }
        }
    }
}
