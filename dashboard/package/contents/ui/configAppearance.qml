import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_accentColor: accentColorField.text
    property alias cfg_customTextColor: customTextColorField.text
    property alias cfg_customSecondaryColor: customSecondaryColorField.text
    property alias cfg_metaFontSize: metaFontSize.value
    property alias cfg_systemFontSize: systemFontSize.value
    property alias cfg_separatorOpacity: separatorOpacity.value
    property alias cfg_enableTextShadow: enableTextShadow.checked
    property int cfg_spacingDensity: 1

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Colours")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Accent colour (hex):")
        spacing: 6
        TextField {
            id: accentColorField
            placeholderText: "#D71920"
            Layout.preferredWidth: 120
        }
        Rectangle {
            width: 24; height: 24; radius: 3
            color: accentColorField.text.trim().length > 0 ? accentColorField.text.trim() : "#D71920"
            border.color: "#333"; border.width: 1
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Accent presets:")
        spacing: 6
        Button { text: "Nothing Red"; onClicked: accentColorField.text = "#D71920" }
        Button { text: "Muted Red";   onClicked: accentColorField.text = "#B72B2B" }
        Button { text: "Mono";        onClicked: accentColorField.text = "#8A8A8A" }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Primary text override:")
        spacing: 6
        TextField {
            id: customTextColorField
            placeholderText: i18n("blank = Plasma theme")
            Layout.fillWidth: true
        }
        Button { text: i18n("Clear"); onClicked: customTextColorField.text = "" }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Secondary text override:")
        spacing: 6
        TextField {
            id: customSecondaryColorField
            placeholderText: i18n("blank = Plasma theme")
            Layout.fillWidth: true
        }
        Button { text: i18n("Clear"); onClicked: customSecondaryColorField.text = "" }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Typography & Layout")
    }

    SpinBox {
        id: metaFontSize
        Kirigami.FormData.label: i18n("Music metadata size (px):")
        from: 8
        to: 20
        value: 11
    }
    SpinBox {
        id: systemFontSize
        Kirigami.FormData.label: i18n("System text size (px):")
        from: 8
        to: 18
        value: 10
    }

    ComboBox {
        id: spacingDensity
        Kirigami.FormData.label: i18n("Spacing:")
        model: [i18n("Compact"), i18n("Normal")]
        currentIndex: page.cfg_spacingDensity
        onActivated: page.cfg_spacingDensity = currentIndex
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Separator opacity:")
        Slider {
            id: separatorOpacity
            from: 0.0
            to: 0.6
            stepSize: 0.05
            value: 0.20
            Layout.preferredWidth: 160
        }
        Label { text: separatorOpacity.value.toFixed(2) }
    }

    CheckBox {
        id: enableTextShadow
        Kirigami.FormData.label: i18n("Text shadow:")
        text: i18n("Add a soft shadow for readability on bright wallpapers")
    }
}
