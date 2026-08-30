import QtQuick

Item {
    id: root

    property string text: "0"
    property font font
    property color textColor: "#ECEFF4"
    property color accentColor: "#B72B2B"
    property bool isError: false
    property bool enableAnimations: true

    implicitWidth: Math.max(currentTextItem.implicitWidth, oldTextItem.implicitWidth)
    implicitHeight: Math.max(currentTextItem.implicitHeight, oldTextItem.implicitHeight)
    clip: true

    property string _prevText: ""

    onTextChanged: {
        if (!root.enableAnimations || root._prevText === "") {
            currentTextItem.text = root.text;
            currentTextItem.y = 0;
            currentTextItem.opacity = 1.0;
            oldTextItem.text = "";
            oldTextItem.opacity = 0.0;
            root._prevText = root.text;
            return;
        }

        if (root.text === root._prevText) {
            return;
        }

        oldTextItem.text = root._prevText;
        currentTextItem.text = root.text;
        root._prevText = root.text;

        animTransition.stop();
        oldTextItem.y = 0;
        oldTextItem.opacity = 1.0;
        currentTextItem.y = root.height * 0.35;
        currentTextItem.opacity = 0.0;
        animTransition.start();
    }

    onIsErrorChanged: {
        if (root.isError && root.enableAnimations) {
            errorPulse.start();
        }
    }

    ParallelAnimation {
        id: animTransition

        NumberAnimation {
            target: oldTextItem
            property: "y"
            to: -root.height * 0.35
            duration: 180
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: oldTextItem
            property: "opacity"
            to: 0.0
            duration: 180
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: currentTextItem
            property: "y"
            to: 0
            duration: 180
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: currentTextItem
            property: "opacity"
            to: 1.0
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    // Subtle single pulse on error
    SequentialAnimation {
        id: errorPulse
        NumberAnimation {
            target: currentTextItem
            property: "scale"
            to: 1.06
            duration: 100
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: currentTextItem
            property: "scale"
            to: 1.0
            duration: 140
            easing.type: Easing.OutQuad
        }
    }

    Text {
        id: oldTextItem
        anchors.right: parent.right
        font: root.font
        color: root.isError ? root.accentColor : root.textColor
        horizontalAlignment: Text.AlignRight
        opacity: 0.0
        y: 0
    }

    Text {
        id: currentTextItem
        anchors.right: parent.right
        font: root.font
        color: root.isError ? root.accentColor : root.textColor
        horizontalAlignment: Text.AlignRight
        opacity: 1.0
        y: 0
    }

    Component.onCompleted: {
        root._prevText = root.text;
        currentTextItem.text = root.text;
    }
}
