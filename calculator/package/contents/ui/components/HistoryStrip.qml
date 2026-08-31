// HistoryStrip.qml
// Tertiary. Collapsed = only the most recent calculation, dimmed.
// Click anywhere on the strip to expand the small stack; click a row to
// recall it into the expression. No drawer, no popover.

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property var model: []
    property color primaryColor: "#ECEFF4"
    property color secondaryColor: "#7B889B"
    property color accentColor: "#D71920"
    property string bodyFamily: ""
    property int fontSize: 11
    property bool enableAnimations: true

    signal recall(string expr, string res)

    property bool expanded: false

    spacing: 2

    Repeater {
        model: root.expanded ? root.model : root.model.slice(0, 1)

        delegate: Item {
            Layout.fillWidth: true
            implicitHeight: rowText.implicitHeight + 5
            opacity: index === 0 ? 0.8 : 0.5

            RowLayout {
                id: rowLine
                anchors.fill: parent
                spacing: 6

                Text {
                    id: rowText
                    Layout.fillWidth: true
                    text: modelData.expression
                    font.family: root.bodyFamily
                    font.pixelSize: root.fontSize
                    font.letterSpacing: 0.4
                    color: root.secondaryColor
                    elide: Text.ElideLeft
                    horizontalAlignment: Text.AlignRight
                }
                Rectangle {   // tiny separator dot instead of '='
                    width: 3; height: 3
                    color: root.accentColor
                    opacity: 0.7
                    Layout.alignment: Qt.AlignVCenter
                }
                Text {
                    text: modelData.result
                    font.family: root.bodyFamily
                    font.pixelSize: root.fontSize
                    font.bold: true
                    font.letterSpacing: 0.4
                    color: root.primaryColor
                }
            }

            TapHandler {
                onTapped: {
                    if (!root.expanded) root.expanded = true
                    else root.recall(modelData.expression, modelData.result)
                }
            }
            HoverHandler { cursorShape: Qt.PointingHandCursor }
        }
    }

    // Collapse affordance when expanded
    Text {
        visible: root.expanded && root.model.length > 1
        Layout.alignment: Qt.AlignRight
        text: "···"
        font.pixelSize: root.fontSize
        color: root.secondaryColor
        opacity: 0.5
        TapHandler { onTapped: root.expanded = false }
        HoverHandler { cursorShape: Qt.PointingHandCursor }
    }
}
