// MetricRow.qml
// One metric line: uppercase micro-label · display-font percentage · dot meter.
// Matches the dashboard's system module language.

import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property string label: "CPU"
    property real percentage: 0
    property bool showPercent: true
    property bool warning: false
    property color primaryColor: "#ECEFF4"
    property color secondaryColor: "#7B889B"
    property color accentColor: "#D71920"
    property string bodyFont: ""
    property string displayFont: "monospace"
    property int labelSize: 11
    property int valueSize: 13
    property bool enableAnimations: true

    spacing: 10

    Text {
        text: root.label
        font.family: root.bodyFont
        font.pixelSize: root.labelSize
        font.bold: true
        font.letterSpacing: 2.0
        color: root.warning ? root.accentColor : root.secondaryColor
        Layout.preferredWidth: 34
    }

    DisplayValue {
        visible: root.showPercent
        text: Math.round(root.percentage) + "%"
        pixelSize: root.valueSize
        color: root.warning ? root.accentColor : root.primaryColor
        separatorColor: root.warning ? root.accentColor : root.primaryColor
        displayFamily: root.displayFont
        bodyFamily: root.bodyFont
        Layout.preferredWidth: 46
    }

    UsageIndicator {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        percentage: root.percentage
        primaryColor: root.primaryColor
        secondaryColor: root.secondaryColor
        accentColor: root.accentColor
        isWarning: root.warning
        enableAnimations: root.enableAnimations
    }
}
