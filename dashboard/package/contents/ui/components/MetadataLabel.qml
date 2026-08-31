// MetadataLabel.qml
// A single line of text that elides cleanly instead of clipping or wrapping.
// Used for song title / artist / album and system labels.
// No background, no chrome — just type.

import QtQuick

Text {
    id: root

    property bool uppercase: false
    property real tracking: 0.0
    property bool enableShadow: false

    elide: Text.ElideRight
    maximumLineCount: 1
    wrapMode: Text.NoWrap
    textFormat: Text.PlainText
    renderType: Text.NativeRendering

    font.letterSpacing: root.tracking
    font.capitalization: root.uppercase ? Font.AllUppercase : Font.MixedCase

    style: root.enableShadow ? Text.Raised : Text.Normal
    styleColor: Qt.rgba(0, 0, 0, 0.45)
}
