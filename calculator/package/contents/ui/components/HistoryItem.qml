import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string expression: ""
    property string result: ""
    property color textColor: "#7B889B"
    property color resultColor: "#ECEFF4"
    property int fontSize: 11

    signal selected(string expr, string res)

    implicitWidth: 200
    implicitHeight: 20

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        radius: 2
        color: mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        spacing: 6

        Text {
            text: root.expression
            font.pixelSize: root.fontSize
            font.letterSpacing: 0.5
            color: root.textColor
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            text: "="
            font.pixelSize: root.fontSize
            color: root.textColor
            opacity: 0.6
        }

        Text {
            text: root.result
            font.pixelSize: root.fontSize
            font.bold: true
            font.letterSpacing: 0.5
            color: root.resultColor
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.selected(root.expression, root.result)
    }
}
