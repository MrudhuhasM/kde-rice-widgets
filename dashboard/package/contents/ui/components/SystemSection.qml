// SystemSection.qml
// CPU % / RAM % / network throughput.
//
// Sensor data is supplied by main.qml, which reads it from
// org.kde.ksysguard.sensors (ksystemstats) using the exact same sensor IDs
// as the standalone system-monitor widget:
//   cpu/all/usage, memory/physical/usedPercent, memory/physical/used,
//   memory/physical/total, network/all/download, network/all/upload
//
// This section only lays the numbers out in the Nothing-inspired style:
// uppercase micro-labels, monospaced numeric values, dotted meters instead
// of thick progress bars.

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property color primaryColor: "#ECEFF4"
    property color secondaryColor: "#7B889B"
    property color accentColor: "#B72B2B"
    property bool enableAnimations: true
    property bool enableShadow: false
    property int sysFontSize: 10

    property bool showCpu: true
    property bool showRam: true
    property bool showNetwork: true
    property bool showBars: true

    property real cpuPct: 0
    property real ramPct: 0
    property real netDownBps: 0
    property real netUpBps: 0
    property string netDownText: "0 B/s"
    property string netUpText: "0 B/s"
    property string ramUsedText: "--"
    property string ramTotalText: "--"

    property bool cpuWarning: false
    property bool ramWarning: false

    readonly property int labelSize: Math.max(8, root.sysFontSize - 1)

    spacing: 6

    // ── CPU ────────────────────────────────────────────────────────────────
    RowLayout {
        visible: root.showCpu
        Layout.fillWidth: true
        spacing: 10

        MetadataLabel {
            text: "CPU"
            uppercase: true
            enableShadow: root.enableShadow
            tracking: 2.0
            font.pixelSize: root.labelSize
            font.bold: true
            color: root.cpuWarning ? root.accentColor : root.secondaryColor
        }

        MetadataLabel {
            id: cpuVal
            text: Math.round(root.cpuPct) + "%"
            enableShadow: root.enableShadow
            font.family: "monospace"
            font.pixelSize: root.sysFontSize + 1
            font.bold: true
            color: root.cpuWarning ? root.accentColor : root.primaryColor
            Layout.preferredWidth: 42
        }

        UsageIndicator {
            visible: root.showBars
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            percentage: root.cpuPct
            primaryColor: root.primaryColor
            secondaryColor: root.secondaryColor
            accentColor: root.accentColor
            isWarning: root.cpuWarning
            enableAnimations: root.enableAnimations
        }
    }

    // ── RAM ────────────────────────────────────────────────────────────────
    RowLayout {
        visible: root.showRam
        Layout.fillWidth: true
        spacing: 10

        MetadataLabel {
            text: "RAM"
            uppercase: true
            enableShadow: root.enableShadow
            tracking: 2.0
            font.pixelSize: root.labelSize
            font.bold: true
            color: root.ramWarning ? root.accentColor : root.secondaryColor
        }

        MetadataLabel {
            id: ramVal
            text: Math.round(root.ramPct) + "%"
            enableShadow: root.enableShadow
            font.family: "monospace"
            font.pixelSize: root.sysFontSize + 1
            font.bold: true
            color: root.ramWarning ? root.accentColor : root.primaryColor
            Layout.preferredWidth: 42
        }

        UsageIndicator {
            visible: root.showBars
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            percentage: root.ramPct
            primaryColor: root.primaryColor
            secondaryColor: root.secondaryColor
            accentColor: root.accentColor
            isWarning: root.ramWarning
            enableAnimations: root.enableAnimations
        }
    }

    // ── NETWORK ────────────────────────────────────────────────────────────
    RowLayout {
        visible: root.showNetwork
        Layout.fillWidth: true
        Layout.topMargin: 2
        spacing: 10

        MetadataLabel {
            text: "NET"
            uppercase: true
            enableShadow: root.enableShadow
            tracking: 2.0
            font.pixelSize: root.labelSize
            font.bold: true
            color: root.secondaryColor
        }

        RowLayout {
            spacing: 4
            MetadataLabel {
                text: "↓"
                font.pixelSize: root.sysFontSize
                font.bold: true
                color: root.accentColor
            }
            MetadataLabel {
                text: root.netDownText
                font.family: "monospace"
                font.pixelSize: root.sysFontSize
                color: root.primaryColor
                Behavior on text { enabled: false }
            }
        }

        RowLayout {
            spacing: 4
            MetadataLabel {
                text: "↑"
                font.pixelSize: root.sysFontSize
                font.bold: true
                color: root.secondaryColor
            }
            MetadataLabel {
                text: root.netUpText
                font.family: "monospace"
                font.pixelSize: root.sysFontSize
                color: root.secondaryColor
            }
        }

        Item { Layout.fillWidth: true }
    }
}
