import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_showCpu: showCpu.checked
    property alias cfg_showRam: showRam.checked
    property alias cfg_showNetwork: showNetwork.checked
    property alias cfg_showBars: showBars.checked
    property alias cfg_enableWarningAccent: enableWarningAccent.checked
    property alias cfg_cpuWarningThreshold: cpuWarningThreshold.value
    property alias cfg_ramWarningThreshold: ramWarningThreshold.value

    CheckBox {
        id: showCpu
        Kirigami.FormData.label: i18n("CPU:")
        text: i18n("Show CPU usage")
    }
    CheckBox {
        id: showRam
        Kirigami.FormData.label: i18n("RAM:")
        text: i18n("Show memory usage")
    }
    CheckBox {
        id: showNetwork
        Kirigami.FormData.label: i18n("Network:")
        text: i18n("Show download / upload rates")
    }
    CheckBox {
        id: showBars
        Kirigami.FormData.label: i18n("Usage indicators:")
        text: i18n("Show segmented dot meters next to CPU / RAM")
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Warning Accent")
    }

    CheckBox {
        id: enableWarningAccent
        Kirigami.FormData.label: i18n("Warning accent:")
        text: i18n("Turn values red past a threshold")
    }
    SpinBox {
        id: cpuWarningThreshold
        Kirigami.FormData.label: i18n("CPU threshold (%):")
        from: 50
        to: 100
        value: 80
        enabled: enableWarningAccent.checked
    }
    SpinBox {
        id: ramWarningThreshold
        Kirigami.FormData.label: i18n("RAM threshold (%):")
        from: 50
        to: 100
        value: 85
        enabled: enableWarningAccent.checked
    }
}
