import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "components"
import "js/CalculatorEngine.js" as Engine

PlasmoidItem {
    id: root

    // Desktop widget sizing hints
    Layout.minimumWidth: 200
    Layout.minimumHeight: 240
    Layout.preferredWidth: 250
    Layout.preferredHeight: 360

    // Force transparent background with no Plasma-provided container background
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    // -------------------------------------------------------------------------
    // THEME & COLORS
    // -------------------------------------------------------------------------
    readonly property color primaryTextColor: {
        if (Plasmoid.configuration.customTextColor && Plasmoid.configuration.customTextColor !== "") {
            return Plasmoid.configuration.customTextColor;
        }
        return Kirigami.Theme.textColor ? Kirigami.Theme.textColor : "#ECEFF4";
    }

    readonly property color secondaryTextColor: {
        if (Plasmoid.configuration.customSecondaryColor && Plasmoid.configuration.customSecondaryColor !== "") {
            return Plasmoid.configuration.customSecondaryColor;
        }
        return Kirigami.Theme.disabledTextColor ? Kirigami.Theme.disabledTextColor : "#7B889B";
    }

    readonly property color accentColor: {
        if (Plasmoid.configuration.accentColor && Plasmoid.configuration.accentColor !== "") {
            return Plasmoid.configuration.accentColor;
        }
        return "#B72B2B"; // Restrained crimson
    }

    // -------------------------------------------------------------------------
    // STATE PROPERTIES
    // -------------------------------------------------------------------------
    property string currentExpression: ""
    property string displayedResult: "0"
    property bool isError: false
    property var historyList: []

    // -------------------------------------------------------------------------
    // CALCULATOR ACTIONS
    // -------------------------------------------------------------------------
    function appendInput(char) {
        if (isError) {
            isError = false;
            currentExpression = "";
            displayedResult = "0";
        }
        currentExpression += char;
    }

    function removeLastChar() {
        if (isError) {
            clearAll();
            return;
        }
        if (currentExpression.length > 0) {
            currentExpression = currentExpression.slice(0, -1);
        }
    }

    function clearAll() {
        currentExpression = "";
        displayedResult = "0";
        isError = false;
    }

    function toggleSign() {
        if (isError) {
            clearAll();
            return;
        }
        if (currentExpression === "") {
            currentExpression = "-";
            return;
        }
        if (currentExpression.startsWith("-")) {
            currentExpression = currentExpression.substring(1);
        } else {
            currentExpression = "-" + currentExpression;
        }
    }

    function evaluateExpression() {
        if (currentExpression.trim() === "") {
            return;
        }

        let res = Engine.evaluate(currentExpression, Plasmoid.configuration.resultPrecision || 10);

        if (res.ok) {
            isError = false;
            let exprCopy = currentExpression;
            displayedResult = res.result;

            // Update in-memory history (last N items)
            if (Plasmoid.configuration.showHistory) {
                let maxItems = Plasmoid.configuration.maxHistoryItems || 5;
                let newHist = [{ expression: exprCopy, result: res.result }].concat(historyList);
                if (newHist.length > maxItems) {
                    newHist = newHist.slice(0, maxItems);
                }
                historyList = newHist;
            }
        } else {
            isError = true;
            displayedResult = res.error;
        }
    }

    function recallHistory(expr, res) {
        currentExpression = expr;
        displayedResult = res;
        isError = false;
    }

    // -------------------------------------------------------------------------
    // FULL REPRESENTATION (DESKTOP WIDGET)
    // -------------------------------------------------------------------------
    fullRepresentation: Item {
        id: desktopRepresentation
        focus: true

        Layout.minimumWidth: 200
        Layout.minimumHeight: 240
        Layout.preferredWidth: 250
        Layout.preferredHeight: 360

        // Handle keyboard interaction cleanly
        Keys.onPressed: (event) => {
            if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                root.appendInput(event.text);
                event.accepted = true;
            } else if (event.key === Qt.Key_Period || event.key === Qt.Key_Comma) {
                root.appendInput(".");
                event.accepted = true;
            } else if (event.key === Qt.Key_Plus) {
                root.appendInput("+");
                event.accepted = true;
            } else if (event.key === Qt.Key_Minus) {
                root.appendInput("-");
                event.accepted = true;
            } else if (event.key === Qt.Key_Asterisk || event.text === "*") {
                root.appendInput("×");
                event.accepted = true;
            } else if (event.key === Qt.Key_Slash || event.text === "/") {
                root.appendInput("÷");
                event.accepted = true;
            } else if (event.key === Qt.Key_Percent || event.text === "%") {
                root.appendInput("%");
                event.accepted = true;
            } else if (event.key === Qt.Key_ParenLeft || event.text === "(") {
                root.appendInput("(");
                event.accepted = true;
            } else if (event.key === Qt.Key_ParenRight || event.text === ")") {
                root.appendInput(")");
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.text === "=") {
                root.evaluateExpression();
                event.accepted = true;
            } else if (event.key === Qt.Key_Backspace) {
                root.removeLastChar();
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Delete) {
                root.clearAll();
                event.accepted = true;
            }
        }

        // Focus on click
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: desktopRepresentation.forceActiveFocus()
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 6

            // 1. TITLE (AoT Military HUD style)
            RowLayout {
                visible: Plasmoid.configuration.showTitle
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Rectangle {
                    width: 10
                    height: 1
                    color: desktopRepresentation.activeFocus ? root.accentColor : root.secondaryTextColor
                    opacity: 0.5
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    id: titleLabel
                    text: {
                        let raw = Plasmoid.configuration.title || "FIELD CALCULATOR";
                        return Plasmoid.configuration.uppercaseTitle ? raw.toUpperCase() : raw;
                    }
                    font.pixelSize: Plasmoid.configuration.titleFontSize || 10
                    font.capitalization: Plasmoid.configuration.uppercaseTitle ? Font.AllUppercase : Font.MixedCase
                    font.letterSpacing: 1.8
                    font.bold: true
                    color: root.isError ? root.accentColor : (desktopRepresentation.activeFocus ? root.accentColor : root.secondaryTextColor)
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    width: 10
                    height: 1
                    color: desktopRepresentation.activeFocus ? root.accentColor : root.secondaryTextColor
                    opacity: 0.5
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            // 2. EXPRESSION LINE
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: expressionText.implicitHeight + 2

                Text {
                    id: expressionText
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.currentExpression === "" ? " " : root.currentExpression
                    font.pixelSize: Plasmoid.configuration.expressionFontSize || 14
                    font.letterSpacing: 0.8
                    color: root.secondaryTextColor
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideLeft
                }
            }

            // 3. MAIN RESULT / ERROR DISPLAY
            AnimatedResult {
                id: resultDisplay
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(34, (Plasmoid.configuration.resultFontSize || 28) + 6)
                text: root.displayedResult
                font.pixelSize: root.isError ? Math.min(16, Plasmoid.configuration.resultFontSize || 28) : (Plasmoid.configuration.resultFontSize || 28)
                font.bold: true
                font.letterSpacing: 1.0
                textColor: root.primaryTextColor
                accentColor: root.accentColor
                isError: root.isError
                enableAnimations: Plasmoid.configuration.enableAnimations
            }

            // 4. THIN HUD DIVIDER LINE
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.isError ? root.accentColor : root.secondaryTextColor
                opacity: root.isError ? 0.8 : 0.25
                Layout.topMargin: 2
                Layout.bottomMargin: 4
            }

            // 5. KEYPAD GRID
            GridLayout {
                id: keypadGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 4
                rowSpacing: 4
                columnSpacing: 4

                // ROW 1
                CalculatorButton {
                    text: "AC"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.accentColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.clearAll(); }
                }
                CalculatorButton {
                    text: "("
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    isOperator: true
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("("); }
                }
                CalculatorButton {
                    text: ")"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    isOperator: true
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput(")"); }
                }
                CalculatorButton {
                    text: "⌫"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.removeLastChar(); }
                }

                // ROW 2
                CalculatorButton {
                    text: "7"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.primaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("7"); }
                }
                CalculatorButton {
                    text: "8"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.primaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("8"); }
                }
                CalculatorButton {
                    text: "9"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.primaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("9"); }
                }
                CalculatorButton {
                    text: "÷"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    isOperator: true
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("÷"); }
                }

                // ROW 3
                CalculatorButton {
                    text: "4"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.primaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("4"); }
                }
                CalculatorButton {
                    text: "5"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.primaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("5"); }
                }
                CalculatorButton {
                    text: "6"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.primaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("6"); }
                }
                CalculatorButton {
                    text: "×"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    isOperator: true
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("×"); }
                }

                // ROW 4
                CalculatorButton {
                    text: "1"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.primaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("1"); }
                }
                CalculatorButton {
                    text: "2"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.primaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("2"); }
                }
                CalculatorButton {
                    text: "3"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.primaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("3"); }
                }
                CalculatorButton {
                    text: "−"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    isOperator: true
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("−"); }
                }

                // ROW 5
                CalculatorButton {
                    text: "±"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.toggleSign(); }
                }
                CalculatorButton {
                    text: "0"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.primaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("0"); }
                }
                CalculatorButton {
                    text: "."
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.primaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("."); }
                }
                CalculatorButton {
                    text: "+"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    isOperator: true
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("+"); }
                }

                // ROW 6
                CalculatorButton {
                    text: "%"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Plasmoid.configuration.buttonFontSize || 14
                    textColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    isOperator: true
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.appendInput("%"); }
                }
                CalculatorButton {
                    text: "ANS"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Math.round((Plasmoid.configuration.buttonFontSize || 14) * 0.8)
                    textColor: root.secondaryTextColor
                    accentColor: root.accentColor
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: {
                        desktopRepresentation.forceActiveFocus();
                        if (!root.isError && root.displayedResult !== "0") {
                            root.appendInput(root.displayedResult);
                        }
                    }
                }
                CalculatorButton {
                    text: "="
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fontSize: Math.round((Plasmoid.configuration.buttonFontSize || 14) * 1.2)
                    textColor: "#FFFFFF"
                    accentColor: root.accentColor
                    isAccent: true
                    enableAnimations: Plasmoid.configuration.enableAnimations
                    onClicked: { desktopRepresentation.forceActiveFocus(); root.evaluateExpression(); }
                }
            }

            // 6. HISTORY SECTION (Optional & hidden when small)
            ColumnLayout {
                id: historySection
                visible: Plasmoid.configuration.showHistory && root.historyList.length > 0 && desktopRepresentation.height >= 300
                Layout.fillWidth: true
                spacing: 2
                Layout.topMargin: 4

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: root.secondaryTextColor
                    opacity: 0.15
                    Layout.bottomMargin: 2
                }

                Repeater {
                    model: root.historyList
                    delegate: HistoryItem {
                        Layout.fillWidth: true
                        expression: modelData.expression
                        result: modelData.result
                        textColor: root.secondaryTextColor
                        resultColor: root.primaryTextColor
                        onSelected: (expr, res) => root.recallHistory(expr, res)
                    }
                }
            }
        }
    }
}
