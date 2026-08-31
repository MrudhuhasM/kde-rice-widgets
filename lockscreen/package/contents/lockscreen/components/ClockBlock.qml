// ClockBlock.qml
// Date micro-line (body font) + time (display font, geometry ':').
// Updates every second only when seconds are shown, otherwise re-aligns to the
// next minute boundary. No external services.

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property bool use24Hour: true
    property bool showSeconds: false
    property bool showDate: true
    property string displayFont: "monospace"
    property string bodyFont: ""
    property color primaryColor: "#FFFFFF"
    property color secondaryColor: "#B9B9B9"
    property color accentColor: "#D71920"
    property int timePixelSize: 92
    property bool enableAnimations: true

    spacing: Math.round(timePixelSize * 0.10)

    property var _now: new Date()

    Timer {
        interval: root.showSeconds ? 1000 : 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root._now = new Date()
            if (!root.showSeconds)
                interval = (60 - root._now.getSeconds()) * 1000
        }
    }

    readonly property string _dateStr: {
        const d = root._now
        const days = ["SUN","MON","TUE","WED","THU","FRI","SAT"]
        const months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"]
        return days[d.getDay()] + "  ·  " + String(d.getDate()).padStart(2, "0") + " " + months[d.getMonth()]
    }
    readonly property string _timeCore: {
        const d = root._now
        let h = d.getHours()
        const mm = String(d.getMinutes()).padStart(2, "0")
        const ss = String(d.getSeconds()).padStart(2, "0")
        if (!root.use24Hour) h = h % 12 || 12
        const hh = String(h).padStart(2, "0")
        return root.showSeconds ? hh + ":" + mm + ":" + ss : hh + ":" + mm
    }
    readonly property string _ampm: root.use24Hour ? "" : (root._now.getHours() >= 12 ? "PM" : "AM")

    Text {
        visible: root.showDate
        Layout.alignment: Qt.AlignHCenter
        text: root._dateStr
        font.family: root.bodyFont
        font.pixelSize: Math.max(11, Math.round(root.timePixelSize * 0.14))
        font.letterSpacing: 3.5
        font.capitalization: Font.AllUppercase
        color: root.secondaryColor
        style: Text.Raised
        styleColor: Qt.rgba(0, 0, 0, 0.5)
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Math.round(root.timePixelSize * 0.14)

        DisplayValue {
            text: root._timeCore
            pixelSize: root.timePixelSize
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
            font.pixelSize: Math.max(11, Math.round(root.timePixelSize * 0.16))
            font.letterSpacing: 2.0
            font.bold: true
            color: root.secondaryColor
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
