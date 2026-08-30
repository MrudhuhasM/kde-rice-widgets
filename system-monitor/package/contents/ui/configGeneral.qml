import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: generalPage

    // KConfig property bindings
    property alias cfg_title: titleField.text
    property alias cfg_showTitle: showTitleCheck.checked
    property alias cfg_uppercaseTitle: uppercaseTitleCheck.checked
    property alias cfg_showCpu: showCpuCheck.checked
    property alias cfg_showRam: showRamCheck.checked
    property alias cfg_showNetwork: showNetworkCheck.checked
    property alias cfg_showRamUsedTotal: showRamUsedTotalCheck.checked
    property alias cfg_showPercentages: showPercentagesCheck.checked
    property alias cfg_updateInterval: updateIntervalSpin.value
    property alias cfg_enableAnimations: enableAnimationsCheck.checked

    // -------------------------------------------------------------------------
    // HEADER & TITLE
    // -------------------------------------------------------------------------
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Header & Title")
    }

    CheckBox {
        id: showTitleCheck
        Kirigami.FormData.label: i18n("Show Title:")
        text: i18n("Display header label above system metrics")
    }

    TextField {
        id: titleField
        Kirigami.FormData.label: i18n("Title Text:")
        placeholderText: "e.g., SYSTEM STATUS, VITALS"
        Layout.fillWidth: true
        enabled: showTitleCheck.checked
    }

    CheckBox {
        id: uppercaseTitleCheck
        Kirigami.FormData.label: i18n("Uppercase Title:")
        text: i18n("Format header title in ALL CAPS (AoT military aesthetic)")
        enabled: showTitleCheck.checked
    }

    // -------------------------------------------------------------------------
    // METRICS TO DISPLAY
    // -------------------------------------------------------------------------
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Monitored Metrics")
    }

    CheckBox {
        id: showCpuCheck
        Kirigami.FormData.label: i18n("CPU Usage:")
        text: i18n("Show total CPU utilization bar and percentage")
    }

    CheckBox {
        id: showRamCheck
        Kirigami.FormData.label: i18n("RAM Usage:")
        text: i18n("Show physical RAM utilization bar and percentage")
    }

    CheckBox {
        id: showRamUsedTotalCheck
        Kirigami.FormData.label: i18n("RAM Used/Total:")
        text: i18n("Show formatted used/total memory (e.g. 6.2 / 15.7 GB)")
        enabled: showRamCheck.checked
    }

    CheckBox {
        id: showNetworkCheck
        Kirigami.FormData.label: i18n("Network:")
        text: i18n("Show real-time download and upload throughput")
    }

    CheckBox {
        id: showPercentagesCheck
        Kirigami.FormData.label: i18n("Percentages:")
        text: i18n("Show numerical percentages alongside metric bars")
    }

    // -------------------------------------------------------------------------
    // SAMPLING & MOTION
    // -------------------------------------------------------------------------
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Refresh & Animation")
    }

    SpinBox {
        id: updateIntervalSpin
        Kirigami.FormData.label: i18n("Refresh Interval (Seconds):")
        from: 1
        to: 10
        value: 1
    }

    CheckBox {
        id: enableAnimationsCheck
        Kirigami.FormData.label: i18n("Enable Animations:")
        text: i18n("Smoothly interpolate metric bars when values update")
    }
}
