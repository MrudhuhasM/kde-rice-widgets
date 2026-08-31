// ClockSection.qml
// WEEKDAY · DATE micro-line (body font) + the time in DISPLAY font.
// Uses Date + a QML Timer — no external services.
// Timer fires every second only when seconds are shown, otherwise re-aligns
// to the next minute boundary.

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property color primaryColor:   "#ECEFF4"
    property color secondaryColor: "#7B889B"
    property color accentColor:    "#D71920"
    property bool  enableAnimations: true
    property bool  enableShadow: false
    property string displayFont: "monospace"
    property string bodyFont: ""

    property bool  showWeekday:  true
    property bool  showDate:     true
    property bool  showSeconds:  false
    property bool  use24Hour:    true
    property bool  showAmPm:     false
    property int   dateOrder:    0     // 0 = WEEKDAY·DATE, 1 = DATE·WEEKDAY
    property int   timeFontSize: 36

    implicitHeight: mainCol.implicitHeight
    implicitWidth:  200

    property var _now: new Date()

    // Time string WITHOUT am/pm suffix (suffix rendered separately in body font)
    readonly property string _timeCore: {
        const d = root._now
        let h = d.getHours()
        const min = String(d.getMinutes()).padStart(2, "0")
        const sec = String(d.getSeconds()).padStart(2, "0")
        if (!root.use24Hour) h = h % 12 || 12
        const hStr = String(h).padStart(2, "0")
        return root.showSeconds ? hStr + ":" + min + ":" + sec : hStr + ":" + min
    }
    readonly property string _ampm: (!root.use24Hour && root.showAmPm)
        ? (root._now.getHours() >= 12 ? "PM" : "AM") : ""

    readonly property string _weekdayStr: {
        const days = ["SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"]
        return days[root._now.getDay()]
    }
    readonly property string _dateStr: {
        const d = root._now
        const months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"]
        return String(d.getDate()).padStart(2, "0") + " " + months[d.getMonth()]
    }
    readonly property string _datelineStr: {
        if (!root.showWeekday && !root.showDate) return ""
        if (root.showWeekday && root.showDate)
            return root.dateOrder === 0
                ? root._weekdayStr + "   ·   " + root._dateStr
                : root._dateStr + "   ·   " + root._weekdayStr
        return root.showWeekday ? root._weekdayStr : root._dateStr
    }

    Timer {
        id: clockTimer
        interval: root.showSeconds ? 1000 : 60000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            root._now = new Date()
            if (!root.showSeconds) {
                const s = root._now.getSeconds()
                interval = (60 - s) * 1000
            }
        }
    }

    ColumnLayout {
        id: mainCol
        anchors { left: parent.left; right: parent.right }
        spacing: 3

        Text {
            id: dateLine
            visible: root._datelineStr.length > 0
            text: root._datelineStr
            font.family: root.bodyFont
            font.pixelSize: Math.max(9, Math.round(root.timeFontSize * 0.26))
            font.letterSpacing: 2.4
            font.capitalization: Font.AllUppercase
            color: root.secondaryColor
            style: root.enableShadow ? Text.Raised : Text.Normal
            styleColor: Qt.rgba(0, 0, 0, 0.45)
            Layout.alignment: Qt.AlignLeft
        }

        RowLayout {
            spacing: Math.round(root.timeFontSize * 0.22)
            Layout.topMargin: 1

            DisplayValue {
                id: timeValue
                text: root._timeCore
                pixelSize: root.timeFontSize
                color: root.primaryColor
                separatorColor: root.accentColor
                displayFamily: root.displayFont
                bodyFamily: root.bodyFont
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                visible: root._ampm.length > 0
                text: root._ampm
                font.family: root.bodyFont
                font.pixelSize: Math.max(9, Math.round(root.timeFontSize * 0.24))
                font.letterSpacing: 1.5
                font.bold: true
                color: root.secondaryColor
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
