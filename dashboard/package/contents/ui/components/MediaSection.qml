// MediaSection.qml
// Now-playing block: artwork + title / artist / album + visualizer + controls.
//
// All media data comes from org.kde.plasma.private.mpris (Mpris2Model) in
// main.qml. This component is purely presentational; it emits signals for
// transport actions which main.qml forwards to the current MPRIS player.
//
// Metadata is pre-sanitised in main.qml (safeStr) so "undefined" / "null" /
// "NaN" never reach the UI. Empty strings collapse their rows.

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property color primaryColor: "#ECEFF4"
    property color secondaryColor: "#7B889B"
    property color accentColor: "#B72B2B"
    property bool enableAnimations: true
    property bool enableShadow: false
    property int metaFontSize: 11

    property string mediaTitle: ""
    property string mediaArtist: ""
    property string mediaAlbum: ""
    property string mediaArtUrl: ""
    property bool isPlaying: false
    property bool hasPlayer: false

    property bool showArtwork: true
    property bool showAlbum: true
    property bool showArtist: true
    property bool showVisualizer: true
    property bool showControls: true
    property bool collapseWhenNoMedia: false
    property int artworkSize: 64

    property bool canGoNext: true
    property bool canGoPrevious: true

    signal playPauseRequested()
    signal previousRequested()
    signal nextRequested()

    readonly property bool hasArt: root.mediaArtUrl.length > 0 && artImage.status === Image.Ready
    readonly property bool wantArt: root.showArtwork && root.mediaArtUrl.length > 0
    readonly property bool hasAnyMeta: root.mediaTitle.length > 0 || root.mediaArtist.length > 0
    readonly property bool collapsed: root.collapseWhenNoMedia && !root.hasPlayer && !root.hasAnyMeta

    implicitHeight: collapsed ? 0 : content.implicitHeight
    clip: true
    visible: !collapsed

    Behavior on implicitHeight {
        enabled: root.enableAnimations
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
        id: content
        anchors { left: parent.left; right: parent.right }
        spacing: 8

        // ── Artwork + text ────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Artwork — small, tiny corner radius, no shadow.
            Rectangle {
                Layout.preferredWidth: root.artworkSize
                Layout.preferredHeight: root.artworkSize
                visible: root.wantArt && root.hasArt
                radius: 3
                color: "transparent"
                clip: true

                Image {
                    id: artImage
                    anchors.fill: parent
                    source: root.wantArt ? root.mediaArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    sourceSize.width: root.artworkSize * 2
                    sourceSize.height: root.artworkSize * 2
                    opacity: status === Image.Ready ? 1.0 : 0.0

                    Behavior on opacity {
                        enabled: root.enableAnimations
                        NumberAnimation { duration: 240 }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                // Title (or NO ACTIVE MEDIA placeholder)
                MetadataLabel {
                    id: titleLabel
                    Layout.fillWidth: true
                    enableShadow: root.enableShadow
                    text: root.hasAnyMeta ? root.mediaTitle : "NO ACTIVE MEDIA"
                    uppercase: !root.hasAnyMeta
                    tracking: root.hasAnyMeta ? 0.3 : 2.0
                    font.pixelSize: root.hasAnyMeta ? root.metaFontSize + 3 : root.metaFontSize
                    font.bold: true
                    color: root.hasAnyMeta ? root.primaryColor : root.secondaryColor
                    opacity: root.hasAnyMeta ? 1.0 : 0.7

                    // Fade on track change (real MPRIS metadata change).
                    onTextChanged: if (root.enableAnimations) titleFade.restart()
                    NumberAnimation {
                        id: titleFade
                        target: titleLabel
                        property: "opacity"
                        running: false
                        from: 0.0
                        to: root.hasAnyMeta ? 1.0 : 0.7
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }

                MetadataLabel {
                    Layout.fillWidth: true
                    enableShadow: root.enableShadow
                    visible: root.showArtist && root.mediaArtist.length > 0
                    text: root.mediaArtist
                    tracking: 0.3
                    font.pixelSize: root.metaFontSize
                    color: root.secondaryColor
                }

                MetadataLabel {
                    Layout.fillWidth: true
                    enableShadow: root.enableShadow
                    visible: root.showAlbum && root.mediaAlbum.length > 0
                    text: root.mediaAlbum
                    uppercase: true
                    tracking: 1.5
                    font.pixelSize: Math.max(8, root.metaFontSize - 2)
                    color: root.secondaryColor
                    opacity: 0.75
                }
            }
        }

        // ── Visualizer ────────────────────────────────────────────────────
        MusicVisualizer {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            visible: root.showVisualizer && root.hasAnyMeta
            isPlaying: root.isPlaying
            enableAnimations: root.enableAnimations
            barColor: root.primaryColor
            accentColor: root.accentColor
        }

        // ── Controls ──────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            visible: root.showControls && root.hasAnyMeta
            spacing: 18

            // Playback state dot — the single restrained red accent.
            Rectangle {
                width: 6; height: 6; radius: 3
                Layout.alignment: Qt.AlignVCenter
                color: root.isPlaying ? root.accentColor : root.secondaryColor
                opacity: root.isPlaying ? 1.0 : 0.5
                SequentialAnimation on opacity {
                    running: root.isPlaying && root.enableAnimations
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.35; duration: 900; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 900; easing.type: Easing.InOutSine }
                }
            }

            Item { Layout.fillWidth: true }

            TransportButton {
                glyph: "‹‹"
                active: root.canGoPrevious
                baseColor: root.primaryColor
                mutedColor: root.secondaryColor
                pixel: root.metaFontSize + 4
                onActivated: root.previousRequested()
            }
            TransportButton {
                glyph: root.isPlaying ? "❚❚" : "▶"
                baseColor: root.primaryColor
                mutedColor: root.secondaryColor
                pixel: root.metaFontSize + 4
                onActivated: root.playPauseRequested()
            }
            TransportButton {
                glyph: "››"
                active: root.canGoNext
                baseColor: root.primaryColor
                mutedColor: root.secondaryColor
                pixel: root.metaFontSize + 4
                onActivated: root.nextRequested()
            }
        }
    }

    // Minimal transport button — text glyph, no button chrome. Self-contained.
    component TransportButton: Text {
        id: tb
        property string glyph: ""
        property bool active: true
        property color baseColor: "#ECEFF4"
        property color mutedColor: "#7B889B"
        property int pixel: 15
        signal activated()
        text: glyph
        font.pixelSize: pixel
        color: tb.active ? tb.baseColor : tb.mutedColor
        opacity: tb.active ? (hover.hovered ? 1.0 : 0.8) : 0.35
        Behavior on opacity { NumberAnimation { duration: 120 } }
        HoverHandler { id: hover; enabled: tb.active; cursorShape: Qt.PointingHandCursor }
        TapHandler {
            enabled: tb.active
            margin: 6
            onTapped: tb.activated()
        }
    }
}
