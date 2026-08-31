// SectionDivider.qml
// A thin horizontal rule between clock / media / system sections.
// Intentionally minimal — no FrameSvg, no background, just a 1px line.
// `color` and `opacity` are the built-in Rectangle properties, set by the caller.

import QtQuick

Rectangle {
    implicitHeight: 1
    height: 1
    color: "#D71920"
    opacity: 0.20
}
