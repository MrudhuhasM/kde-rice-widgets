import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_showClock: showClock.checked
    property alias cfg_showMusic: showMusic.checked
    property alias cfg_showSystem: showSystem.checked
    property alias cfg_enableAnimations: enableAnimations.checked
    property alias cfg_updateInterval: updateInterval.value

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Modules")
    }

    CheckBox {
        id: showClock
        Kirigami.FormData.label: i18n("Clock:")
        text: i18n("Show date / day / time")
    }
    CheckBox {
        id: showMusic
        Kirigami.FormData.label: i18n("Music:")
        text: i18n("Show now-playing media")
    }
    CheckBox {
        id: showSystem
        Kirigami.FormData.label: i18n("System:")
        text: i18n("Show CPU / RAM / network")
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Behaviour")
    }

    CheckBox {
        id: enableAnimations
        Kirigami.FormData.label: i18n("Animations:")
        text: i18n("Enable subtle transitions")
    }

    SpinBox {
        id: updateInterval
        Kirigami.FormData.label: i18n("System refresh (seconds):")
        from: 1
        to: 10
        value: 1
    }
}
