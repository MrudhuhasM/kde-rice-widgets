// Calculator — com.mrudhuhas.calculator
// Keyboard-first, expression-first desktop calculator.
// Nothing-inspired: monochrome, display-font result anchor, bare-glyph keypad,
// one restrained red action. Sits directly on the wallpaper.
//
// TRANSPARENCY CONTRACT (unchanged):
//   Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
//   preferredRepresentation: fullRepresentation   (no compactRepresentation)
//
// All evaluation logic lives in js/CalculatorEngine.js and is untouched.

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "components"
import "js/CalculatorEngine.js" as Engine

PlasmoidItem {
    id: root

    Layout.minimumWidth: 220
    Layout.minimumHeight: 260
    Layout.preferredWidth: 300
    Layout.preferredHeight: 380

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    // ── Palette ─────────────────────────────────────────────────────────────
    readonly property color primaryTextColor: {
        const c = Plasmoid.configuration.customTextColor
        return (c && c !== "") ? c : (Kirigami.Theme.textColor || "#ECEFF4")
    }
    readonly property color secondaryTextColor: {
        const c = Plasmoid.configuration.customSecondaryColor
        return (c && c !== "") ? c : (Kirigami.Theme.disabledTextColor || "#7B889B")
    }
    readonly property color accentColor: {
        const c = Plasmoid.configuration.accentColor
        return (c && c !== "") ? c : "#D71920"
    }

    // ── Typography: DISPLAY (digits only) + BODY ─────────────────────────────
    readonly property string bodyFont: Kirigami.Theme.defaultFont.family
    function _fontAvailable(f) { return f && f.length > 0 && Qt.fontFamilies().indexOf(f) !== -1 }
    readonly property string displayFont: {
        if (Plasmoid.configuration.useDisplayFont === false) return "monospace"
        const want = (Plasmoid.configuration.displayFont || "").trim()
        const cands = want.length ? [want, want.replace(" ", ""), want.replace("NDot", "Ndot")] : []
        for (let i = 0; i < cands.length; ++i) if (root._fontAvailable(cands[i])) return cands[i]
        return "monospace"
    }

    readonly property bool enableAnimations: Plasmoid.configuration.enableAnimations !== false

    // ── State (unchanged) ───────────────────────────────────────────────────
    property string currentExpression: ""
    property string displayedResult: "0"
    property bool isError: false
    property var historyList: []

    // ── Actions (unchanged behaviour) ───────────────────────────────────────
    function appendInput(ch) {
        if (isError) { isError = false; currentExpression = ""; displayedResult = "0" }
        currentExpression += ch
    }
    function removeLastChar() {
        if (isError) { clearAll(); return }
        if (currentExpression.length > 0) currentExpression = currentExpression.slice(0, -1)
    }
    function clearAll() { currentExpression = ""; displayedResult = "0"; isError = false }
    function toggleSign() {
        if (isError) { clearAll(); return }
        if (currentExpression === "") { currentExpression = "-"; return }
        if (currentExpression.startsWith("-")) currentExpression = currentExpression.substring(1)
        else currentExpression = "-" + currentExpression
    }
    function smartParen() {
        let opens = (currentExpression.match(/\(/g) || []).length
        let closes = (currentExpression.match(/\)/g) || []).length
        let last = currentExpression.slice(-1)
        if (opens > closes && last !== "" && "0123456789)".indexOf(last) !== -1) appendInput(")")
        else appendInput("(")
    }
    function evaluateExpression() {
        if (currentExpression.trim() === "") return
        let res = Engine.evaluate(currentExpression, Plasmoid.configuration.resultPrecision || 10)
        if (res.ok) {
            isError = false
            let exprCopy = currentExpression
            displayedResult = res.result
            if (Plasmoid.configuration.showHistory) {
                let maxItems = Plasmoid.configuration.maxHistoryItems || 5
                let newHist = [{ expression: exprCopy, result: res.result }].concat(historyList)
                if (newHist.length > maxItems) newHist = newHist.slice(0, maxItems)
                historyList = newHist
            }
        } else {
            isError = true
            displayedResult = res.error
        }
    }
    function recallHistory(expr, res) {
        currentExpression = expr; displayedResult = res; isError = false
    }

    // ── Full representation ─────────────────────────────────────────────────
    fullRepresentation: FocusScope {
        id: view
        focus: true

        Layout.minimumWidth: 220
        Layout.minimumHeight: 260
        Layout.preferredWidth: 300
        Layout.preferredHeight: 380

        Component.onCompleted: view.forceActiveFocus()

        readonly property int rFont: Plasmoid.configuration.resultFontSize || 40
        readonly property int eFont: Plasmoid.configuration.expressionFontSize || 14
        readonly property int kFont: Plasmoid.configuration.buttonFontSize || 15
        readonly property int idFont: Plasmoid.configuration.titleFontSize || 10

        // Keyboard map — preserved verbatim from the previous implementation.
        Keys.onPressed: (event) => {
            if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                root.appendInput(event.text); event.accepted = true
            } else if (event.key === Qt.Key_Period || event.key === Qt.Key_Comma) {
                root.appendInput("."); event.accepted = true
            } else if (event.key === Qt.Key_Plus) {
                root.appendInput("+"); event.accepted = true
            } else if (event.key === Qt.Key_Minus) {
                root.appendInput("-"); event.accepted = true
            } else if (event.key === Qt.Key_Asterisk || event.text === "*") {
                root.appendInput("×"); event.accepted = true
            } else if (event.key === Qt.Key_Slash || event.text === "/") {
                root.appendInput("÷"); event.accepted = true
            } else if (event.key === Qt.Key_Percent || event.text === "%") {
                root.appendInput("%"); event.accepted = true
            } else if (event.key === Qt.Key_ParenLeft || event.text === "(") {
                root.appendInput("("); event.accepted = true
            } else if (event.key === Qt.Key_ParenRight || event.text === ")") {
                root.appendInput(")"); event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.text === "=") {
                root.evaluateExpression(); event.accepted = true
            } else if (event.key === Qt.Key_Backspace) {
                root.removeLastChar(); event.accepted = true
            } else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Delete) {
                root.clearAll(); event.accepted = true
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onPressed: (m) => { view.forceActiveFocus(); m.accepted = false }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 2
            spacing: 8

            // 1 · IDENTIFIER + focus dot
            RowLayout {
                Layout.fillWidth: true
                visible: Plasmoid.configuration.showTitle !== false
                spacing: 6

                Text {
                    text: {
                        const raw = Plasmoid.configuration.title || "CALC"
                        return Plasmoid.configuration.uppercaseTitle !== false ? raw.toUpperCase() : raw
                    }
                    font.family: root.bodyFont
                    font.pixelSize: view.idFont
                    font.letterSpacing: 3.0
                    font.bold: true
                    color: root.isError ? root.accentColor : root.secondaryTextColor
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 5; height: 5; radius: 0
                    Layout.alignment: Qt.AlignVCenter
                    color: view.activeFocus ? root.accentColor : root.secondaryTextColor
                    opacity: view.activeFocus ? 1.0 : 0.3
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
            }

            // 2 · EXPRESSION + caret
            RowLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    Layout.fillWidth: true
                    text: root.currentExpression === "" ? "" : root.currentExpression
                    font.family: root.bodyFont
                    font.pixelSize: view.eFont
                    font.letterSpacing: 0.8
                    color: root.secondaryTextColor
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideLeft
                }
                Rectangle {
                    width: 2
                    height: view.eFont * 1.1
                    color: root.accentColor
                    visible: view.activeFocus
                    opacity: 1.0
                    SequentialAnimation on opacity {
                        running: view.activeFocus && root.enableAnimations
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.0; duration: 520; easing.type: Easing.OutQuad }
                        PauseAnimation { duration: 120 }
                        NumberAnimation { to: 1.0; duration: 220 }
                        PauseAnimation { duration: 400 }
                    }
                }
            }

            // 3 · RESULT — the anchor
            ResultValue {
                Layout.fillWidth: true
                Layout.preferredHeight: view.rFont * 1.2
                text: root.displayedResult
                pixelSize: view.rFont
                textColor: root.primaryTextColor
                accentColor: root.accentColor
                isError: root.isError
                enableAnimations: root.enableAnimations
                displayFamily: root.displayFont
                bodyFamily: root.bodyFont
            }

            // 4 · hairline
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.isError ? root.accentColor : root.secondaryTextColor
                opacity: root.isError ? 0.7 : 0.15
                Layout.topMargin: 1
                Layout.bottomMargin: 3
            }

            // 5 · KEYPAD
            Keypad {
                Layout.fillWidth: true
                Layout.fillHeight: true
                primaryColor: root.primaryTextColor
                secondaryColor: root.secondaryTextColor
                accentColor: root.accentColor
                bodyFamily: root.bodyFont
                fontSize: view.kFont
                enableAnimations: root.enableAnimations

                onAppend: (token) => { view.forceActiveFocus(); if (token === "(") root.smartParen(); else root.appendInput(token) }
                onEquals:   { view.forceActiveFocus(); root.evaluateExpression() }
                onClear:    { view.forceActiveFocus(); root.clearAll() }
                onBackspace:{ view.forceActiveFocus(); root.removeLastChar() }
                onAns: {
                    view.forceActiveFocus()
                    if (!root.isError && root.displayedResult !== "0") root.appendInput(root.displayedResult)
                }
            }

            // 6 · HISTORY (tertiary)
            HistoryStrip {
                Layout.fillWidth: true
                visible: Plasmoid.configuration.showHistory && root.historyList.length > 0
                          && view.height >= 320
                model: root.historyList
                primaryColor: root.primaryTextColor
                secondaryColor: root.secondaryTextColor
                accentColor: root.accentColor
                bodyFamily: root.bodyFont
                enableAnimations: root.enableAnimations
                onRecall: (expr, res) => { view.forceActiveFocus(); root.recallHistory(expr, res) }
            }
        }
    }
}
