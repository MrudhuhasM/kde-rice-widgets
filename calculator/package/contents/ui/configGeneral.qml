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
    property alias cfg_showHistory: showHistoryCheck.checked
    property alias cfg_maxHistoryItems: maxHistorySpin.value
    property alias cfg_resultPrecision: resultPrecisionSpin.value
    property alias cfg_enableAnimations: enableAnimationsCheck.checked

    // -------------------------------------------------------------------------
    // TITLE & DISPLAY
    // -------------------------------------------------------------------------
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Header & Title")
    }

    CheckBox {
        id: showTitleCheck
        Kirigami.FormData.label: i18n("Show Title:")
        text: i18n("Display header label above calculator expression")
    }

    TextField {
        id: titleField
        Kirigami.FormData.label: i18n("Title Text:")
        placeholderText: "e.g., FIELD CALCULATOR, INSTRUMENT CALC"
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
    // CALCULATION & ENGINE
    // -------------------------------------------------------------------------
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Calculation Engine")
    }

    SpinBox {
        id: resultPrecisionSpin
        Kirigami.FormData.label: i18n("Result Precision (Significant Digits):")
        from: 4
        to: 16
        value: 10
    }

    // -------------------------------------------------------------------------
    // HISTORY & ANIMATIONS
    // -------------------------------------------------------------------------
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("History & Motion")
    }

    CheckBox {
        id: showHistoryCheck
        Kirigami.FormData.label: i18n("Calculation History:")
        text: i18n("Show small in-memory history of recent calculations below keypad")
    }

    SpinBox {
        id: maxHistorySpin
        Kirigami.FormData.label: i18n("Max History Entries:")
        from: 1
        to: 10
        value: 5
        enabled: showHistoryCheck.checked
    }

    CheckBox {
        id: enableAnimationsCheck
        Kirigami.FormData.label: i18n("Enable Animations:")
        text: i18n("Animate keypad clicks and result transitions")
    }
}
