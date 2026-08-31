import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: form

    // Stock keys (kept so the standard screen-locking UI stays consistent)
    property bool cfg_alwaysShowClock: true
    property bool cfg_alwaysShowClockDefault: true
    property bool cfg_hideClockWhenIdle: false
    property bool cfg_hideClockWhenIdleDefault: false
    property bool cfg_showMediaControls: false
    property bool cfg_showMediaControlsDefault: false

    // Nothing Lock keys
    property alias cfg_use24Hour: use24Hour.checked
    property bool cfg_use24HourDefault: true
    property alias cfg_showSeconds: showSeconds.checked
    property bool cfg_showSecondsDefault: false
    property alias cfg_showDate: showDate.checked
    property bool cfg_showDateDefault: true
    property alias cfg_showUserName: showUserName.checked
    property bool cfg_showUserNameDefault: true
    property alias cfg_showBattery: showBattery.checked
    property bool cfg_showBatteryDefault: true
    property alias cfg_showActions: showActions.checked
    property bool cfg_showActionsDefault: true
    property alias cfg_useDisplayFont: useDisplayFont.checked
    property bool cfg_useDisplayFontDefault: true
    property alias cfg_displayFont: displayFont.text
    property string cfg_displayFontDefault: "Ndot"
    property alias cfg_accentColor: accentColor.text
    property string cfg_accentColorDefault: "#D71920"
    property alias cfg_overlayOpacity: overlay.value
    property real cfg_overlayOpacityDefault: 0.22

    QQC2.CheckBox {
        id: showDate
        Kirigami.FormData.label: i18n("Clock:")
        text: i18n("Show weekday and date")
    }
    QQC2.CheckBox {
        id: use24Hour
        text: i18n("24-hour time")
    }
    QQC2.CheckBox {
        id: showSeconds
        text: i18n("Show seconds")
    }

    Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Details") }

    QQC2.CheckBox { id: showUserName; Kirigami.FormData.label: i18n("Show:"); text: i18n("User name") }
    QQC2.CheckBox { id: showBattery; text: i18n("Battery") }
    QQC2.CheckBox { id: showActions; text: i18n("Sleep / Switch User actions") }

    Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Appearance") }

    QQC2.CheckBox { id: useDisplayFont; Kirigami.FormData.label: i18n("Display font:"); text: i18n("Use a dot-matrix font for the time") }
    QQC2.TextField {
        id: displayFont
        Kirigami.FormData.label: i18n("Family:")
        placeholderText: "Ndot"
        enabled: useDisplayFont.checked
    }
    QQC2.TextField {
        id: accentColor
        Kirigami.FormData.label: i18n("Accent colour:")
        placeholderText: "#D71920"
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Overlay darkness:")
        QQC2.Slider {
            id: overlay
            from: 0.0; to: 0.6; stepSize: 0.02
            Layout.preferredWidth: Kirigami.Units.gridUnit * 10
        }
        QQC2.Label { text: overlay.value.toFixed(2) }
    }
}
