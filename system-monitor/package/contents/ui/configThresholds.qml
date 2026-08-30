import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: thresholdsPage

    // KConfig property bindings
    property alias cfg_cpuWarningThreshold: cpuWarningSpin.value
    property alias cfg_ramWarningThreshold: ramWarningSpin.value
    property alias cfg_enableWarningAccent: enableWarningCheck.checked

    // -------------------------------------------------------------------------
    // WARNING THRESHOLDS
    // -------------------------------------------------------------------------
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Utilization Warning Thresholds")
    }

    CheckBox {
        id: enableWarningCheck
        Kirigami.FormData.label: i18n("Warning Accents:")
        text: i18n("Highlight metrics in crimson accent color when thresholds are exceeded")
    }

    SpinBox {
        id: cpuWarningSpin
        Kirigami.FormData.label: i18n("CPU Warning Threshold (%):")
        from: 10
        to: 100
        value: 80
        enabled: enableWarningCheck.checked
    }

    SpinBox {
        id: ramWarningSpin
        Kirigami.FormData.label: i18n("RAM Warning Threshold (%):")
        from: 10
        to: 100
        value: 85
        enabled: enableWarningCheck.checked
    }
}
