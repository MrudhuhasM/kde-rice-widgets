// BatteryTag.qml
// Tiny battery indicator: NN% + a short segmented bar. Native UPower data via
// org.kde.plasma.private.battery — no icon-theme dependency, no shell calls.
// Hidden entirely on machines without an internal battery.

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.private.battery as Battery

RowLayout {
    id: root

    property color primaryColor: "#FFFFFF"
    property color secondaryColor: "#B9B9B9"
    property color accentColor: "#D71920"
    property string bodyFont: ""

    spacing: 8
    visible: batteryModel.hasInternalBatteries && batteryModel.hasCumulative

    Battery.BatteryControlModel { id: batteryModel }

    readonly property int pct: batteryModel.percent
    readonly property bool low: pct <= 15 && !batteryModel.pluggedIn

    Text {
        text: root.pct + "%"
        font.family: root.bodyFont
        font.pixelSize: 11
        font.letterSpacing: 1.5
        color: root.low ? root.accentColor : root.secondaryColor
        style: Text.Raised
        styleColor: Qt.rgba(0, 0, 0, 0.5)
    }

    Row {
        Layout.alignment: Qt.AlignVCenter
        spacing: 2
        Repeater {
            model: 10
            delegate: Rectangle {
                width: 3; height: 6
                readonly property bool lit: index < Math.round(root.pct / 10)
                color: lit ? (root.low ? root.accentColor : root.primaryColor) : root.secondaryColor
                opacity: lit ? 0.85 : 0.25
            }
        }
    }

    Text {
        visible: batteryModel.pluggedIn
        text: "↯"
        font.pixelSize: 11
        color: root.secondaryColor
    }
}
