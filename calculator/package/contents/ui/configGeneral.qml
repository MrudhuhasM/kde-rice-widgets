import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_title: titleField.text
    property alias cfg_showTitle: showTitleCheck.checked
    property alias cfg_uppercaseTitle: uppercaseTitleCheck.checked
    property alias cfg_showHistory: showHistoryCheck.checked
    property alias cfg_maxHistoryItems: maxHistorySpin.value
    property alias cfg_resultPrecision: resultPrecisionSpin.value
    property alias cfg_enableAnimations: enableAnimationsCheck.checked

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Identifier")
    }

    CheckBox {
        id: showTitleCheck
        Kirigami.FormData.label: i18n("Show identifier:")
        text: i18n("Small label above the expression")
    }
    TextField {
        id: titleField
        Kirigami.FormData.label: i18n("Text:")
        placeholderText: "CALC"
        Layout.fillWidth: true
        enabled: showTitleCheck.checked
    }
    CheckBox {
        id: uppercaseTitleCheck
        Kirigami.FormData.label: i18n("Uppercase:")
        text: i18n("Force ALL CAPS")
        enabled: showTitleCheck.checked
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Engine")
    }

    SpinBox {
        id: resultPrecisionSpin
        Kirigami.FormData.label: i18n("Result precision (significant digits):")
        from: 4
        to: 16
        value: 10
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("History & Motion")
    }

    CheckBox {
        id: showHistoryCheck
        Kirigami.FormData.label: i18n("History:")
        text: i18n("Keep a small recall stack beneath the keypad")
    }
    SpinBox {
        id: maxHistorySpin
        Kirigami.FormData.label: i18n("Max entries:")
        from: 1
        to: 10
        value: 5
        enabled: showHistoryCheck.checked
    }
    CheckBox {
        id: enableAnimationsCheck
        Kirigami.FormData.label: i18n("Animations:")
        text: i18n("Result transition, key press feedback, caret blink")
    }
}
