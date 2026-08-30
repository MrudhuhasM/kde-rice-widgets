import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: appearancePage

    // KConfig property bindings
    property alias cfg_accentColor: accentColorField.text
    property alias cfg_customTextColor: customTextColorField.text
    property alias cfg_customSecondaryColor: customSecondaryColorField.text
    property alias cfg_titleFontSize: titleFontSizeSpin.value
    property alias cfg_metricLabelFontSize: metricLabelFontSizeSpin.value
    property alias cfg_metricValueFontSize: metricValueFontSizeSpin.value
    property alias cfg_secondaryFontSize: secondaryFontSizeSpin.value
    property alias cfg_barThickness: barThicknessSpin.value

    // -------------------------------------------------------------------------
    // PALETTE & COLORS
    // -------------------------------------------------------------------------
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Theme & Colors")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Accent Color (Hex):")
        Layout.fillWidth: true
        spacing: 6

        TextField {
            id: accentColorField
            placeholderText: "#B72B2B"
            Layout.preferredWidth: 120
        }

        Rectangle {
            width: 24
            height: 24
            radius: 3
            color: {
                let col = accentColorField.text.trim();
                return col.length > 0 ? col : "#B72B2B";
            }
            border.color: "#333333"
            border.width: 1
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Color Presets:")
        spacing: 6

        Button {
            text: "AoT Crimson"
            onClicked: accentColorField.text = "#B72B2B"
        }
        Button {
            text: "Scout Green"
            onClicked: accentColorField.text = "#2E5B44"
        }
        Button {
            text: "Garrison Amber"
            onClicked: accentColorField.text = "#B8860B"
        }
        Button {
            text: "Military Steel"
            onClicked: accentColorField.text = "#6C7A89"
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Primary Text Color:")
        Layout.fillWidth: true
        spacing: 6

        TextField {
            id: customTextColorField
            placeholderText: "Leave blank for Plasma Theme"
            Layout.fillWidth: true
        }

        Button {
            text: i18n("Clear")
            onClicked: customTextColorField.text = ""
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Secondary Text Color:")
        Layout.fillWidth: true
        spacing: 6

        TextField {
            id: customSecondaryColorField
            placeholderText: "Leave blank for Plasma Theme"
            Layout.fillWidth: true
        }

        Button {
            text: i18n("Clear")
            onClicked: customSecondaryColorField.text = ""
        }
    }

    // -------------------------------------------------------------------------
    // TYPOGRAPHY & SIZES
    // -------------------------------------------------------------------------
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Typography & Bar Thickness")
    }

    SpinBox {
        id: titleFontSizeSpin
        Kirigami.FormData.label: i18n("Title Font Size (px):")
        from: 8
        to: 20
        value: 10
    }

    SpinBox {
        id: metricLabelFontSizeSpin
        Kirigami.FormData.label: i18n("Metric Label Font Size (px):")
        from: 8
        to: 20
        value: 11
    }

    SpinBox {
        id: metricValueFontSizeSpin
        Kirigami.FormData.label: i18n("Metric Value Font Size (px):")
        from: 9
        to: 24
        value: 12
    }

    SpinBox {
        id: secondaryFontSizeSpin
        Kirigami.FormData.label: i18n("Secondary Details Font Size (px):")
        from: 8
        to: 18
        value: 10
    }

    SpinBox {
        id: barThicknessSpin
        Kirigami.FormData.label: i18n("Progress Bar Thickness (px):")
        from: 1
        to: 8
        value: 2
    }
}
