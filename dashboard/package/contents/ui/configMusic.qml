import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_showArtwork: showArtwork.checked
    property alias cfg_showArtist: showArtist.checked
    property alias cfg_showAlbum: showAlbum.checked
    property alias cfg_showVisualizer: showVisualizer.checked
    property alias cfg_showControls: showControls.checked
    property alias cfg_collapseWhenNoMedia: collapseWhenNoMedia.checked
    property alias cfg_artworkSize: artworkSize.value

    CheckBox {
        id: showArtwork
        Kirigami.FormData.label: i18n("Artwork:")
        text: i18n("Show album art")
    }
    SpinBox {
        id: artworkSize
        Kirigami.FormData.label: i18n("Artwork size (px):")
        from: 48
        to: 96
        stepSize: 4
        value: 64
        enabled: showArtwork.checked
    }
    CheckBox {
        id: showArtist
        Kirigami.FormData.label: i18n("Artist:")
        text: i18n("Show artist name")
    }
    CheckBox {
        id: showAlbum
        Kirigami.FormData.label: i18n("Album:")
        text: i18n("Show album name")
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Visualizer & Controls")
    }

    CheckBox {
        id: showVisualizer
        Kirigami.FormData.label: i18n("Visualizer:")
        text: i18n("Show playback visualizer")
    }
    CheckBox {
        id: showControls
        Kirigami.FormData.label: i18n("Controls:")
        text: i18n("Show previous / play-pause / next")
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("No Media")
    }

    CheckBox {
        id: collapseWhenNoMedia
        Kirigami.FormData.label: i18n("When nothing is playing:")
        text: i18n("Collapse the module (otherwise show NO ACTIVE MEDIA)")
    }

    Label {
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 22
        wrapMode: Text.WordWrap
        opacity: 0.7
        font: Kirigami.Theme.smallFont
        text: i18n("The visualizer reacts to real playback state (play / pause / stop) but is an animated approximation — Plasma 6 exposes no pure-QML audio-amplitude API. See the widget README.")
    }
}
