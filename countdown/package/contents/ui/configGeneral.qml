import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: generalPage

    // KConfig property bindings
    property alias cfg_title: titleField.text
    property alias cfg_targetDate: targetDateField.text
    property alias cfg_targetTime: targetTimeField.text
    property alias cfg_startDate: startDateField.text
    property alias cfg_startTime: startTimeField.text
    property alias cfg_showSeconds: showSecondsCheck.checked
    property alias cfg_enableAnimations: enableAnimationsCheck.checked
    property alias cfg_showProgressLine: showProgressLineCheck.checked
    property alias cfg_showTargetDateTime: showTargetDateTimeCheck.checked
    property alias cfg_completedText: completedTextField.text

    function padZero(num) {
        return (num < 10 ? "0" : "") + num;
    }

    function setQuickTarget(hoursToAdd) {
        let now = new Date();
        let target = new Date(now.getTime() + hoursToAdd * 3600000);

        // Update Start date/time to now for accurate progress line calculation
        let startY = now.getFullYear();
        let startM = padZero(now.getMonth() + 1);
        let startD = padZero(now.getDate());
        startDateField.text = startY + "-" + startM + "-" + startD;
        startTimeField.text = padZero(now.getHours()) + ":" + padZero(now.getMinutes()) + ":" + padZero(now.getSeconds());

        // Update Target date/time
        let targetY = target.getFullYear();
        let targetM = padZero(target.getMonth() + 1);
        let targetD = padZero(target.getDate());
        targetDateField.text = targetY + "-" + targetM + "-" + targetD;
        targetTimeField.text = padZero(target.getHours()) + ":" + padZero(target.getMinutes()) + ":00";
    }

    // -------------------------------------------------------------------------
    // COUNTDOWN OBJECTIVE
    // -------------------------------------------------------------------------
    TextField {
        id: titleField
        Kirigami.FormData.label: i18n("Countdown Title:")
        placeholderText: "e.g., MISSION ENDS IN, DEEP WORK, NEXT OBJECTIVE"
        Layout.fillWidth: true
    }

    TextField {
        id: completedTextField
        Kirigami.FormData.label: i18n("Completed Text:")
        placeholderText: "e.g., OBJECTIVE COMPLETE, TIME REACHED"
        Layout.fillWidth: true
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Target Date & Time")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Target Date (YYYY-MM-DD):")
        Layout.fillWidth: true
        spacing: 6

        TextField {
            id: targetDateField
            placeholderText: "YYYY-MM-DD"
            Layout.fillWidth: true
        }

        Button {
            text: i18n("Today")
            onClicked: {
                let d = new Date();
                targetDateField.text = d.getFullYear() + "-" + padZero(d.getMonth() + 1) + "-" + padZero(d.getDate());
            }
        }

        Button {
            text: i18n("Tomorrow")
            onClicked: {
                let d = new Date();
                d.setDate(d.getDate() + 1);
                targetDateField.text = d.getFullYear() + "-" + padZero(d.getMonth() + 1) + "-" + padZero(d.getDate());
            }
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Target Time (HH:MM:SS):")
        Layout.fillWidth: true
        spacing: 6

        TextField {
            id: targetTimeField
            placeholderText: "18:00:00"
            Layout.fillWidth: true
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Quick Presets:")
        spacing: 6

        Button {
            text: "+1 Hour"
            onClicked: generalPage.setQuickTarget(1)
        }
        Button {
            text: "+2 Hours"
            onClicked: generalPage.setQuickTarget(2)
        }
        Button {
            text: "+4 Hours"
            onClicked: generalPage.setQuickTarget(4)
        }
        Button {
            text: "+24 Hours"
            onClicked: generalPage.setQuickTarget(24)
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Progress Baseline (Optional)")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Start Date & Time:")
        Layout.fillWidth: true
        spacing: 6

        TextField {
            id: startDateField
            placeholderText: "Start Date (YYYY-MM-DD)"
            Layout.fillWidth: true
        }

        TextField {
            id: startTimeField
            placeholderText: "Start Time (HH:MM:SS)"
            Layout.preferredWidth: 120
        }

        Button {
            text: i18n("Set to Now")
            onClicked: {
                let now = new Date();
                startDateField.text = now.getFullYear() + "-" + padZero(now.getMonth() + 1) + "-" + padZero(now.getDate());
                startTimeField.text = padZero(now.getHours()) + ":" + padZero(now.getMinutes()) + ":" + padZero(now.getSeconds());
            }
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Display Options")
    }

    CheckBox {
        id: showSecondsCheck
        Kirigami.FormData.label: i18n("Show Seconds:")
        text: i18n("Display seconds in the countdown clock")
    }

    CheckBox {
        id: showProgressLineCheck
        Kirigami.FormData.label: i18n("Progress Marker Line:")
        text: i18n("Display the military HUD progress bar and indicator")
    }

    CheckBox {
        id: showTargetDateTimeCheck
        Kirigami.FormData.label: i18n("Target Timestamp Label:")
        text: i18n("Display the target date/time footer (e.g. UNTIL 19:00)")
    }

    CheckBox {
        id: enableAnimationsCheck
        Kirigami.FormData.label: i18n("Enable Animations:")
        text: i18n("Animate digit transitions and urgency indicator")
    }
}
