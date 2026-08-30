import QtQuick

Item {
    id: root

    property string text: ""
    property font font
    property color color: "#ffffff"
    property bool enableAnimations: true
    property int horizontalAlignment: Text.AlignHCenter

    implicitWidth: Math.max(textItemCurrent.implicitWidth, textItemOld.implicitWidth)
    implicitHeight: Math.max(textItemCurrent.implicitHeight, textItemOld.implicitHeight)
    clip: true

    property string _prevText: ""

    onTextChanged: {
        if (!root.enableAnimations || root._prevText === "") {
            textItemCurrent.text = root.text;
            textItemCurrent.y = 0;
            textItemCurrent.opacity = 1.0;
            textItemOld.text = "";
            textItemOld.opacity = 0.0;
            root._prevText = root.text;
            return;
        }

        if (root.text === root._prevText) {
            return;
        }

        textItemOld.text = root._prevText;
        textItemCurrent.text = root.text;
        root._prevText = root.text;

        animTransition.stop();
        textItemOld.y = 0;
        textItemOld.opacity = 1.0;
        textItemCurrent.y = root.height * 0.35;
        textItemCurrent.opacity = 0.0;
        animTransition.start();
    }

    ParallelAnimation {
        id: animTransition

        NumberAnimation {
            target: textItemOld
            property: "y"
            to: -root.height * 0.35
            duration: 180
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: textItemOld
            property: "opacity"
            to: 0.0
            duration: 180
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: textItemCurrent
            property: "y"
            to: 0
            duration: 180
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: textItemCurrent
            property: "opacity"
            to: 1.0
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Text {
        id: textItemOld
        anchors.horizontalCenter: parent.horizontalCenter
        font: root.font
        color: root.color
        horizontalAlignment: root.horizontalAlignment
        opacity: 0.0
        y: 0
    }

    Text {
        id: textItemCurrent
        anchors.horizontalCenter: parent.horizontalCenter
        font: root.font
        color: root.color
        horizontalAlignment: root.horizontalAlignment
        opacity: 1.0
        y: 0
    }

    Component.onCompleted: {
        root._prevText = root.text;
        textItemCurrent.text = root.text;
    }
}
