import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

import "components"

PlasmoidItem {
    id: root

    // Desktop widget sizing hints
    Layout.minimumWidth: 160
    Layout.minimumHeight: 140
    Layout.preferredWidth: 220
    Layout.preferredHeight: 220

    // Force transparent background with no Plasma-provided container background
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

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
    // REFRESH INTERVAL
    // -------------------------------------------------------------------------
    readonly property int sensorUpdateIntervalMs: Math.max(1000, (Plasmoid.configuration.updateInterval || 1) * 1000)

    // -------------------------------------------------------------------------
    // NATIVE PLASMA 6 SENSORS (KSYSTEMSTATS)
    // -------------------------------------------------------------------------
    // 1. CPU Sensor (Aggregate total usage 0 - 100%)
    Sensors.Sensor {
        id: cpuSensor
        sensorId: "cpu/all/usage"
        updateRateLimit: root.sensorUpdateIntervalMs
    }

    // 2. RAM Sensors (Used bytes, Total bytes, Used percentage)
    Sensors.Sensor {
        id: ramUsedSensor
        sensorId: "memory/physical/used"
        updateRateLimit: root.sensorUpdateIntervalMs
    }

    Sensors.Sensor {
        id: ramTotalSensor
        sensorId: "memory/physical/total"
        updateRateLimit: root.sensorUpdateIntervalMs
    }

    Sensors.Sensor {
        id: ramPercentSensor
        sensorId: "memory/physical/usedPercent"
        updateRateLimit: root.sensorUpdateIntervalMs
    }

    // 3. Network Sensors (Aggregate download and upload throughput in bytes/s)
    Sensors.Sensor {
        id: netDownSensor
        sensorId: "network/all/download"
        updateRateLimit: root.sensorUpdateIntervalMs
    }

    Sensors.Sensor {
        id: netUpSensor
        sensorId: "network/all/upload"
        updateRateLimit: root.sensorUpdateIntervalMs
    }

    // -------------------------------------------------------------------------
    // NORMALIZED DATA PROPERTIES
    // -------------------------------------------------------------------------
    readonly property real cpuPercentage: {
        let val = Number(cpuSensor.value);
        if (isNaN(val) || val < 0) return 0.0;
        return Math.min(100.0, val);
    }

    readonly property real ramPercentage: {
        let pct = Number(ramPercentSensor.value);
        if (!isNaN(pct) && pct > 0) {
            return Math.min(100.0, pct);
        }
        // Fallback calculation: used / total * 100
        let used = Number(ramUsedSensor.value);
        let total = Number(ramTotalSensor.value);
        if (!isNaN(used) && !isNaN(total) && total > 0) {
            return Math.min(100.0, (used / total) * 100.0);
        }
        return 0.0;
    }

    readonly property real ramUsedBytes: {
        let val = Number(ramUsedSensor.value);
        return (!isNaN(val) && val > 0) ? val : 0;
    }

    readonly property real ramTotalBytes: {
        let val = Number(ramTotalSensor.value);
        return (!isNaN(val) && val > 0) ? val : 0;
    }

    readonly property real netDownBytesPerSec: {
        let val = Number(netDownSensor.value);
        return (!isNaN(val) && val > 0) ? val : 0.0;
    }

    readonly property real netUpBytesPerSec: {
        let val = Number(netUpSensor.value);
        return (!isNaN(val) && val > 0) ? val : 0.0;
    }

    // -------------------------------------------------------------------------
    // WARNING STATES
    // -------------------------------------------------------------------------
    readonly property bool isCpuWarning: Plasmoid.configuration.enableWarningAccent &&
        (root.cpuPercentage >= (Plasmoid.configuration.cpuWarningThreshold || 80))

    readonly property bool isRamWarning: Plasmoid.configuration.enableWarningAccent &&
        (root.ramPercentage >= (Plasmoid.configuration.ramWarningThreshold || 85))

    // -------------------------------------------------------------------------
    // FORMATTING HELPERS
    // -------------------------------------------------------------------------
    function formatBytes(bytes) {
        if (typeof bytes !== "number" || isNaN(bytes) || bytes <= 0) {
            return "--";
        }
        const gb = bytes / (1024 * 1024 * 1024);
        if (gb >= 1.0) {
            return gb.toFixed(1) + " GB";
        }
        const mb = bytes / (1024 * 1024);
        return Math.round(mb) + " MB";
    }

    // -------------------------------------------------------------------------
    // FULL REPRESENTATION (DESKTOP WIDGET)
    // -------------------------------------------------------------------------
    fullRepresentation: Item {
        id: desktopRepresentation

        Layout.minimumWidth: 160
        Layout.minimumHeight: 140
        Layout.preferredWidth: 220
        Layout.preferredHeight: 220

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            spacing: 8

            // 1. TITLE (AoT Military HUD style)
            RowLayout {
                visible: Plasmoid.configuration.showTitle
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Rectangle {
                    width: 10
                    height: 1
                    color: (root.isCpuWarning || root.isRamWarning) ? root.accentColor : root.secondaryTextColor
                    opacity: 0.5
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    id: titleLabel
                    text: {
                        let raw = Plasmoid.configuration.title || "SYSTEM STATUS";
                        return Plasmoid.configuration.uppercaseTitle ? raw.toUpperCase() : raw;
                    }
                    font.pixelSize: Plasmoid.configuration.titleFontSize || 10
                    font.capitalization: Plasmoid.configuration.uppercaseTitle ? Font.AllUppercase : Font.MixedCase
                    font.letterSpacing: 1.8
                    font.bold: true
                    color: (root.isCpuWarning || root.isRamWarning) ? root.accentColor : root.secondaryTextColor
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    width: 10
                    height: 1
                    color: (root.isCpuWarning || root.isRamWarning) ? root.accentColor : root.secondaryTextColor
                    opacity: 0.5
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            // 2. CPU SECTION
            ColumnLayout {
                visible: Plasmoid.configuration.showCpu
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "CPU"
                        font.pixelSize: Plasmoid.configuration.metricLabelFontSize || 11
                        font.bold: true
                        font.letterSpacing: 1.0
                        color: root.isCpuWarning ? root.accentColor : root.primaryTextColor
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        visible: Plasmoid.configuration.showPercentages
                        text: Math.round(root.cpuPercentage) + "%"
                        font.pixelSize: Plasmoid.configuration.metricValueFontSize || 12
                        font.bold: true
                        font.letterSpacing: 0.5
                        color: root.isCpuWarning ? root.accentColor : root.primaryTextColor
                    }
                }

                MetricBar {
                    Layout.fillWidth: true
                    percentage: root.cpuPercentage
                    barColor: root.primaryTextColor
                    trackColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    barHeight: Plasmoid.configuration.barThickness || 2
                    isWarning: root.isCpuWarning
                    enableAnimations: Plasmoid.configuration.enableAnimations
                }
            }

            // 3. RAM SECTION
            ColumnLayout {
                visible: Plasmoid.configuration.showRam
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "RAM"
                        font.pixelSize: Plasmoid.configuration.metricLabelFontSize || 11
                        font.bold: true
                        font.letterSpacing: 1.0
                        color: root.isRamWarning ? root.accentColor : root.primaryTextColor
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        visible: Plasmoid.configuration.showPercentages
                        text: Math.round(root.ramPercentage) + "%"
                        font.pixelSize: Plasmoid.configuration.metricValueFontSize || 12
                        font.bold: true
                        font.letterSpacing: 0.5
                        color: root.isRamWarning ? root.accentColor : root.primaryTextColor
                    }
                }

                // RAM Used / Total Subtitle
                Text {
                    visible: Plasmoid.configuration.showRamUsedTotal && root.ramTotalBytes > 0
                    text: root.formatBytes(root.ramUsedBytes) + " / " + root.formatBytes(root.ramTotalBytes)
                    font.pixelSize: Plasmoid.configuration.secondaryFontSize || 10
                    font.letterSpacing: 0.5
                    color: root.secondaryTextColor
                    opacity: 0.85
                }

                MetricBar {
                    Layout.fillWidth: true
                    percentage: root.ramPercentage
                    barColor: root.primaryTextColor
                    trackColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    barHeight: Plasmoid.configuration.barThickness || 2
                    isWarning: root.isRamWarning
                    enableAnimations: Plasmoid.configuration.enableAnimations
                }
            }

            // 4. NETWORK SECTION
            ColumnLayout {
                visible: Plasmoid.configuration.showNetwork
                Layout.fillWidth: true
                spacing: 4
                Layout.topMargin: 2

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "NETWORK"
                        font.pixelSize: Plasmoid.configuration.metricLabelFontSize || 11
                        font.bold: true
                        font.letterSpacing: 1.0
                        color: root.primaryTextColor
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.secondaryTextColor
                        opacity: 0.2
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 4
                    }
                }

                NetworkThroughput {
                    Layout.fillWidth: true
                    downloadRate: root.netDownBytesPerSec
                    uploadRate: root.netUpBytesPerSec
                    textColor: root.primaryTextColor
                    secondaryColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    fontSize: Plasmoid.configuration.secondaryFontSize || 10
                    enableAnimations: Plasmoid.configuration.enableAnimations
                }
            }
        }
    }
}
