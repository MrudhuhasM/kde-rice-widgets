// System Monitor — com.mrudhuhas.systemmonitor
// Standalone Nothing-inspired alternative to the dashboard's system module:
// same typography, same segmented-dot indicator language, same red-accent
// discipline. The SENSOR ARCHITECTURE below is unchanged.
//
// TRANSPARENCY CONTRACT (unchanged):
//   Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
//   preferredRepresentation: fullRepresentation   (no compactRepresentation)

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

import "components"

PlasmoidItem {
    id: root

    Layout.minimumWidth: 170
    Layout.minimumHeight: 130
    Layout.preferredWidth: 240
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
    readonly property int sensorUpdateIntervalMs: Math.max(1000, (Plasmoid.configuration.updateInterval || 1) * 1000)

    // ── Sensors (UNCHANGED) ─────────────────────────────────────────────────
    Sensors.Sensor { id: cpuSensor;       sensorId: "cpu/all/usage";               updateRateLimit: root.sensorUpdateIntervalMs }
    Sensors.Sensor { id: ramUsedSensor;   sensorId: "memory/physical/used";        updateRateLimit: root.sensorUpdateIntervalMs }
    Sensors.Sensor { id: ramTotalSensor;  sensorId: "memory/physical/total";       updateRateLimit: root.sensorUpdateIntervalMs }
    Sensors.Sensor { id: ramPercentSensor;sensorId: "memory/physical/usedPercent"; updateRateLimit: root.sensorUpdateIntervalMs }
    Sensors.Sensor { id: netDownSensor;   sensorId: "network/all/download";        updateRateLimit: root.sensorUpdateIntervalMs }
    Sensors.Sensor { id: netUpSensor;     sensorId: "network/all/upload";          updateRateLimit: root.sensorUpdateIntervalMs }

    readonly property real cpuPercentage: {
        let v = Number(cpuSensor.value)
        return (isNaN(v) || v < 0) ? 0.0 : Math.min(100.0, v)
    }
    readonly property real ramPercentage: {
        let pct = Number(ramPercentSensor.value)
        if (!isNaN(pct) && pct > 0) return Math.min(100.0, pct)
        let used = Number(ramUsedSensor.value), total = Number(ramTotalSensor.value)
        if (!isNaN(used) && !isNaN(total) && total > 0) return Math.min(100.0, (used / total) * 100.0)
        return 0.0
    }
    readonly property real ramUsedBytes:  { let v = Number(ramUsedSensor.value);  return (!isNaN(v) && v > 0) ? v : 0 }
    readonly property real ramTotalBytes: { let v = Number(ramTotalSensor.value); return (!isNaN(v) && v > 0) ? v : 0 }
    readonly property real netDownBytesPerSec: { let v = Number(netDownSensor.value); return (!isNaN(v) && v > 0) ? v : 0.0 }
    readonly property real netUpBytesPerSec:   { let v = Number(netUpSensor.value);   return (!isNaN(v) && v > 0) ? v : 0.0 }

    readonly property bool isCpuWarning: Plasmoid.configuration.enableWarningAccent &&
        (root.cpuPercentage >= (Plasmoid.configuration.cpuWarningThreshold || 80))
    readonly property bool isRamWarning: Plasmoid.configuration.enableWarningAccent &&
        (root.ramPercentage >= (Plasmoid.configuration.ramWarningThreshold || 85))

    function formatBytes(bytes) {
        if (typeof bytes !== "number" || isNaN(bytes) || bytes <= 0) return "--"
        const gb = bytes / (1024 * 1024 * 1024)
        if (gb >= 1.0) return gb.toFixed(1) + " GB"
        return Math.round(bytes / (1024 * 1024)) + " MB"
    }

    // ── Presentation ────────────────────────────────────────────────────────
    fullRepresentation: Item {
        id: view
        Layout.minimumWidth: 170
        Layout.minimumHeight: 130
        Layout.preferredWidth: 240
        Layout.preferredHeight: 190

        readonly property int labelFont: Plasmoid.configuration.metricLabelFontSize || 11
        readonly property int valueFont: Plasmoid.configuration.metricValueFontSize || 13
        readonly property int metaFont:  Plasmoid.configuration.secondaryFontSize || 10
        readonly property int titleFont: Plasmoid.configuration.titleFontSize || 10

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            // TITLE
            RowLayout {
                visible: Plasmoid.configuration.showTitle
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: {
                        const raw = Plasmoid.configuration.title || "SYSTEM"
                        return Plasmoid.configuration.uppercaseTitle ? raw.toUpperCase() : raw
                    }
                    font.family: root.bodyFont
                    font.pixelSize: view.titleFont
                    font.letterSpacing: 3.0
                    font.bold: true
                    color: (root.isCpuWarning || root.isRamWarning) ? root.accentColor : root.secondaryTextColor
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: root.secondaryTextColor
                    opacity: 0.15
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            // CPU
            MetricRow {
                visible: Plasmoid.configuration.showCpu
                Layout.fillWidth: true
                label: "CPU"
                percentage: root.cpuPercentage
                showPercent: Plasmoid.configuration.showPercentages
                warning: root.isCpuWarning
                primaryColor: root.primaryTextColor
                secondaryColor: root.secondaryTextColor
                accentColor: root.accentColor
                bodyFont: root.bodyFont
                displayFont: root.displayFont
                labelSize: view.labelFont
                valueSize: view.valueFont
                enableAnimations: root.enableAnimations
            }

            // RAM
            ColumnLayout {
                visible: Plasmoid.configuration.showRam
                Layout.fillWidth: true
                spacing: 2
                MetricRow {
                    Layout.fillWidth: true
                    label: "RAM"
                    percentage: root.ramPercentage
                    showPercent: Plasmoid.configuration.showPercentages
                    warning: root.isRamWarning
                    primaryColor: root.primaryTextColor
                    secondaryColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    bodyFont: root.bodyFont
                    displayFont: root.displayFont
                    labelSize: view.labelFont
                    valueSize: view.valueFont
                    enableAnimations: root.enableAnimations
                }
                Text {
                    visible: Plasmoid.configuration.showRamUsedTotal && root.ramTotalBytes > 0
                    text: root.formatBytes(root.ramUsedBytes) + "  /  " + root.formatBytes(root.ramTotalBytes)
                    font.family: root.bodyFont
                    font.pixelSize: view.metaFont
                    font.letterSpacing: 0.5
                    color: root.secondaryTextColor
                    opacity: 0.8
                    Layout.leftMargin: 2
                }
            }

            // NETWORK
            ColumnLayout {
                visible: Plasmoid.configuration.showNetwork
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "NET"
                        font.family: root.bodyFont
                        font.pixelSize: view.labelFont
                        font.bold: true
                        font.letterSpacing: 2.0
                        color: root.secondaryTextColor
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.secondaryTextColor
                        opacity: 0.15
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                NetworkThroughput {
                    Layout.fillWidth: true
                    downloadRate: root.netDownBytesPerSec
                    uploadRate: root.netUpBytesPerSec
                    textColor: root.primaryTextColor
                    secondaryColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    fontSize: view.metaFont
                    enableAnimations: root.enableAnimations
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
