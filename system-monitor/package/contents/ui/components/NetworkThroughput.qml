import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property real downloadRate: 0.0 // bytes per second
    property real uploadRate: 0.0   // bytes per second
    property color textColor: "#ECEFF4"
    property color secondaryColor: "#7B889B"
    property color accentColor: "#B72B2B"
    property int fontSize: 11
    property bool enableAnimations: true

    implicitWidth: 200
    implicitHeight: contentColumn.implicitHeight

    function formatSpeed(bytesPerSec) {
        if (typeof bytesPerSec !== "number" || isNaN(bytesPerSec) || bytesPerSec <= 0) {
            return "0 B/s";
        }
        const units = ["B/s", "KB/s", "MB/s", "GB/s", "TB/s"];
        let i = 0;
        let val = bytesPerSec;
        while (val >= 1024 && i < units.length - 1) {
            val /= 1024;
            i++;
        }
        if (i === 0) {
            return Math.round(val) + " B/s";
        } else if (val < 10) {
            return val.toFixed(1) + " " + units[i];
        } else {
            return Math.round(val) + " " + units[i];
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: 3

        // Download row
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "↓"
                font.pixelSize: root.fontSize
                font.bold: true
                color: root.accentColor
            }

            Text {
                text: root.formatSpeed(root.downloadRate)
                font.pixelSize: root.fontSize
                font.bold: true
                font.letterSpacing: 0.5
                color: root.textColor
                Layout.fillWidth: true
            }
        }

        // Upload row
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "↑"
                font.pixelSize: root.fontSize
                font.bold: true
                color: root.secondaryColor
                opacity: 0.8
            }

            Text {
                text: root.formatSpeed(root.uploadRate)
                font.pixelSize: root.fontSize
                font.letterSpacing: 0.5
                color: root.secondaryColor
                Layout.fillWidth: true
            }
        }
    }
}
