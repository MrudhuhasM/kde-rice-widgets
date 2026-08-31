import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_accentColor: accentColorField.text
    property alias cfg_customTextColor: customTextColorField.text
    property alias cfg_customSecondaryColor: customSecondaryColorField.text
    property alias cfg_useDisplayFont: useDisplayFontCheck.checked
    property alias cfg_displayFont: displayFontField.text
    property alias cfg_titleFontSize: titleFontSizeSpin.value
    property alias cfg_countdownFontSize: countdownFontSizeSpin.value
    property alias cfg_detailsFontSize: detailsFontSizeSpin.value
    property alias cfg_urgentThresholdMinutes: urgentThresholdSpin.value
    property alias cfg_criticalThresholdMinutes: criticalThresholdSpin.value

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Colour")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Accent (hex):")
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
        Kirigami.FormData.label: i18n("Presets:")
        spacing: 6
        Button { text: "Nothing Red"; onClicked: accentColorField.text = "#D71920" }
        Button { text: "Muted Red";   onClicked: accentColorField.text = "#B72B2B" }
        Button { text: "Mono";        onClicked: accentColorField.text = "#8A8A8A" }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Primary text override:")
        spacing: 6
        TextField { id: customTextColorField; placeholderText: i18n("blank = Plasma theme"); Layout.fillWidth: true }
        Button { text: i18n("Clear"); onClicked: customTextColorField.text = "" }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Secondary text override:")
        spacing: 6
        TextField { id: customSecondaryColorField; placeholderText: i18n("blank = Plasma theme"); Layout.fillWidth: true }
        Button { text: i18n("Clear"); onClicked: customSecondaryColorField.text = "" }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Display font (remaining-time digits)")
    }

    CheckBox {
        id: useDisplayFontCheck
        Kirigami.FormData.label: i18n("Use display font:")
        text: i18n("Falls back to monospace when the family is not installed")
    }
    TextField {
        id: displayFontField
        Kirigami.FormData.label: i18n("Family:")
        placeholderText: "NDot 57"
        Layout.fillWidth: true
        enabled: useDisplayFontCheck.checked
    }
    Label {
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        wrapMode: Text.WordWrap
        opacity: 0.7
        font: Kirigami.Theme.smallFont
        text: i18n("NDot / dot-matrix fonts are not bundled. Only digits use it — the ':' separators are drawn geometrically.")
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Sizes (px)")
    }

    SpinBox { id: titleFontSizeSpin;     Kirigami.FormData.label: i18n("Labels:");         from: 8;  to: 20; value: 10 }
    SpinBox { id: countdownFontSizeSpin; Kirigami.FormData.label: i18n("Remaining time:"); from: 18; to: 72; value: 34 }
    SpinBox { id: detailsFontSizeSpin;   Kirigami.FormData.label: i18n("Target details:"); from: 8;  to: 20; value: 10 }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Urgency thresholds")
    }

    SpinBox {
        id: urgentThresholdSpin
        Kirigami.FormData.label: i18n("Urgent (minutes):")
        from: 1
        to: 240
        value: 10
    }
    SpinBox {
        id: criticalThresholdSpin
        Kirigami.FormData.label: i18n("Critical (minutes):")
        from: 1
        to: 60
        value: 1
    }
}
