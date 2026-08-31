// ClockSection.qml
// Shows: WEEKDAY · DATE  (configurable order) and the current time.
// Uses Qt.formatTime/Qt.formatDate – no external services.
// Timer fires every second when seconds are shown, otherwise every minute.

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property color primaryColor:   "#ECEFF4"
    property color secondaryColor: "#7B889B"
    property color accentColor:    "#B72B2B"
    property bool  enableAnimations: true
    property bool  enableShadow: false

    property bool  showWeekday:  true
    property bool  showDate:     true
    property bool  showSeconds:  false
    property bool  use24Hour:    true
    property bool  showAmPm:     false
    property int   dateOrder:    0     // 0 = WEEKDAY·DATE, 1 = DATE·WEEKDAY
    property int   timeFontSize: 36

    implicitHeight: mainCol.implicitHeight
    implicitWidth:  200

    // ── Private: Date/time properties updated by timer ────────────────────
    property var _now: new Date()

    readonly property string _timeStr: {
        const d = root._now
        let h = d.getHours()
        const min = String(d.getMinutes()).padStart(2, "0")
        const sec = String(d.getSeconds()).padStart(2, "0")
        if (!root.use24Hour) {
            const suffix = h >= 12 ? "PM" : "AM"
            h = h % 12 || 12
            const hStr = String(h).padStart(2, "0")
            const base = root.showSeconds ? hStr + ":" + min + ":" + sec : hStr + ":" + min
            return root.showAmPm ? base + " " + suffix : base
        }
        const hStr = String(h).padStart(2, "0")
        return root.showSeconds ? hStr + ":" + min + ":" + sec : hStr + ":" + min
    }

    readonly property string _weekdayStr: {
        const days = ["SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"]
        return days[root._now.getDay()]
    }

    readonly property string _dateStr: {
        const d = root._now
        const months = ["JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE",
                        "JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"]
        return d.getDate() + " " + months[d.getMonth()]
    }

    readonly property string _datelineStr: {
        if (!root.showWeekday && !root.showDate) return ""
        if (root.showWeekday && root.showDate) {
            return root.dateOrder === 0
                ? root._weekdayStr + "  ·  " + root._dateStr
                : root._dateStr + "  ·  " + root._weekdayStr
        }
        if (root.showWeekday) return root._weekdayStr
        return root._dateStr
    }

    // ── Clock timer ────────────────────────────────────────────────────────
    Timer {
        id: clockTimer
        interval: root.showSeconds ? 1000 : 60000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            root._now = new Date()
            // Realign minute timer to actual minute boundary
            if (!root.showSeconds) {
                const s = root._now.getSeconds()
                interval = (60 - s) * 1000
            }
        }
    }

    // ── Layout ─────────────────────────────────────────────────────────────
    ColumnLayout {
        id: mainCol
        anchors { left: parent.left; right: parent.right }
        spacing: 2

        // Date/weekday line
        Text {
            id: dateLine
            visible: root._datelineStr.length > 0
            text: root._datelineStr
            font.pixelSize: Math.max(9, Math.round(root.timeFontSize * 0.30))
            font.letterSpacing: 2.0
            font.capitalization: Font.AllUppercase
            color: root.secondaryColor
            Layout.alignment: Qt.AlignLeft
            style: root.enableShadow ? Text.Raised : Text.Normal
            styleColor: Qt.rgba(0, 0, 0, 0.45)
        }

        // Time
        Text {
            id: timeLabel
            text: root._timeStr
            font.pixelSize: root.timeFontSize
            font.weight: Font.Medium
            font.letterSpacing: 1.0
            color: root.primaryColor
            Layout.alignment: Qt.AlignLeft
            renderType: Text.NativeRendering
            style: root.enableShadow ? Text.Raised : Text.Normal
            styleColor: Qt.rgba(0, 0, 0, 0.45)
        }
    }
}
