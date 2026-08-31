import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_showWeekday: showWeekday.checked
    property alias cfg_showDate: showDate.checked
    property alias cfg_showSeconds: showSeconds.checked
    property alias cfg_use24Hour: use24Hour.checked
    property alias cfg_showAmPm: showAmPm.checked
    property int cfg_dateOrder: 0
    property alias cfg_timeFontSize: timeFontSize.value

    CheckBox {
        id: showWeekday
        Kirigami.FormData.label: i18n("Weekday:")
        text: i18n("Show weekday name")
    }
    CheckBox {
        id: showDate
        Kirigami.FormData.label: i18n("Date:")
        text: i18n("Show day and month")
    }

    ComboBox {
        id: dateOrder
        Kirigami.FormData.label: i18n("Order:")
        model: [i18n("WEEKDAY · DATE"), i18n("DATE · WEEKDAY")]
        currentIndex: page.cfg_dateOrder
        onActivated: page.cfg_dateOrder = currentIndex
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Time")
    }

    CheckBox {
        id: use24Hour
        Kirigami.FormData.label: i18n("Format:")
        text: i18n("Use 24-hour clock")
    }
    CheckBox {
        id: showAmPm
        Kirigami.FormData.label: i18n("AM/PM:")
        text: i18n("Show AM/PM suffix (12-hour only)")
        enabled: !use24Hour.checked
    }
    CheckBox {
        id: showSeconds
        Kirigami.FormData.label: i18n("Seconds:")
        text: i18n("Show seconds (updates every second)")
    }

    SpinBox {
        id: timeFontSize
        Kirigami.FormData.label: i18n("Time font size (px):")
        from: 16
        to: 72
        value: 36
    }
}
