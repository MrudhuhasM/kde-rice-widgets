// SPDX-License-Identifier: MIT
// Dashboard Plasmoid – com.mrudhuhas.dashboard
// Unified transparent desktop panel: clock + MPRIS media + system metrics
//
// MEDIA DATA SOURCE:
//   org.kde.plasma.private.mpris  — ships with plasma-workspace (libkmpris C++ plugin).
//   This is a private Plasma API. Properties accessed:
//     mpris2Model.currentPlayer?.track          – song title
//     mpris2Model.currentPlayer?.artist         – artist name
//     mpris2Model.currentPlayer?.album          – album name
//     mpris2Model.currentPlayer?.artUrl         – artwork URL (local file or http)
//     mpris2Model.currentPlayer?.playbackStatus – Mpris.PlaybackStatus.{Playing,Paused,Stopped}
//     mpris2Model.currentPlayer?.length         – track length in microseconds
//     mpris2Model.currentPlayer?.position       – current position in microseconds
//     mpris2Model.currentPlayer?.canPlay / canPause / canGoPrevious / canGoNext
//   Documented as private but used by many community plasmoids as the only viable pure-QML approach.
//
// SYSTEM DATA SOURCE:
//   org.kde.ksysguard.sensors — backed by ksystemstats D-Bus daemon.
//   Sensor IDs: cpu/all/usage, memory/physical/used, memory/physical/total,
//               memory/physical/usedPercent, network/all/download, network/all/upload
//
// TRANSPARENCY CONTRACT:
//   Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
//   preferredRepresentation: fullRepresentation
//   compactRepresentation: NOT defined

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QC
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors
import org.kde.plasma.private.mpris as Mpris

import "components"

PlasmoidItem {
    id: root

    // ── Sizing hints ──────────────────────────────────────────────────────────
    Layout.minimumWidth:  260
    Layout.minimumHeight: 320
    Layout.preferredWidth:  340
    Layout.preferredHeight: 480

    // ── Transparency ──────────────────────────────────────────────────────────
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    // compactRepresentation is intentionally omitted

    // ─────────────────────────────────────────────────────────────────────────
    // THEME / PALETTE
    // ─────────────────────────────────────────────────────────────────────────
    readonly property color primaryTextColor: {
        const custom = Plasmoid.configuration.customTextColor
        if (custom && custom !== "") return custom
        return Kirigami.Theme.textColor || "#ECEFF4"
    }
    readonly property color secondaryTextColor: {
        const custom = Plasmoid.configuration.customSecondaryColor
        if (custom && custom !== "") return custom
        return Kirigami.Theme.disabledTextColor || "#7B889B"
    }
    readonly property color accentColor: {
        const c = Plasmoid.configuration.accentColor
        if (c && c !== "") return c
        return "#B72B2B"
    }
    readonly property bool enableAnimations: Plasmoid.configuration.enableAnimations !== false
    readonly property bool enableTextShadow: Plasmoid.configuration.enableTextShadow === true

    // ── Typography: DISPLAY font (dot-matrix, digits only) + BODY font ────────
    readonly property string bodyFont: Kirigami.Theme.defaultFont.family
    function _fontAvailable(fam) {
        return fam && fam.length > 0 && Qt.fontFamilies().indexOf(fam) !== -1
    }
    readonly property string displayFont: {
        if (Plasmoid.configuration.useDisplayFont === false) return "monospace"
        const want = (Plasmoid.configuration.displayFont || "").trim()
        const candidates = want.length > 0
            ? [want, want.replace(" ", ""), want.replace("NDot", "Ndot")]
            : []
        for (let i = 0; i < candidates.length; ++i)
            if (root._fontAvailable(candidates[i])) return candidates[i]
        return "monospace"   // graceful fallback keeps digit alignment
    }
    readonly property bool displayFontActive: root.displayFont !== "monospace"
    readonly property int sectionSpacing: Plasmoid.configuration.spacingDensity === 0 ? 10 : 16

    // ─────────────────────────────────────────────────────────────────────────
    // SYSTEM SENSORS (reuse same pattern as system-monitor widget)
    // ─────────────────────────────────────────────────────────────────────────
    readonly property int sensorRateMs: Math.max(1000, (Plasmoid.configuration.updateInterval || 1) * 1000)

    Sensors.Sensor { id: cpuSensor;       sensorId: "cpu/all/usage";              updateRateLimit: root.sensorRateMs }
    Sensors.Sensor { id: ramUsedSensor;   sensorId: "memory/physical/used";       updateRateLimit: root.sensorRateMs }
    Sensors.Sensor { id: ramTotalSensor;  sensorId: "memory/physical/total";      updateRateLimit: root.sensorRateMs }
    Sensors.Sensor { id: ramPctSensor;    sensorId: "memory/physical/usedPercent"; updateRateLimit: root.sensorRateMs }
    Sensors.Sensor { id: netDownSensor;   sensorId: "network/all/download";       updateRateLimit: root.sensorRateMs }
    Sensors.Sensor { id: netUpSensor;     sensorId: "network/all/upload";         updateRateLimit: root.sensorRateMs }

    // Normalised sensor values
    readonly property real cpuPct: {
        const v = Number(cpuSensor.value)
        return (isNaN(v) || v < 0) ? 0.0 : Math.min(100.0, v)
    }
    readonly property real ramPct: {
        const p = Number(ramPctSensor.value)
        if (!isNaN(p) && p > 0) return Math.min(100.0, p)
        const used  = Number(ramUsedSensor.value)
        const total = Number(ramTotalSensor.value)
        if (!isNaN(used) && !isNaN(total) && total > 0) return Math.min(100.0, used / total * 100)
        return 0.0
    }
    readonly property real netDownBps: { const v = Number(netDownSensor.value); return (!isNaN(v) && v > 0) ? v : 0.0 }
    readonly property real netUpBps:   { const v = Number(netUpSensor.value);   return (!isNaN(v) && v > 0) ? v : 0.0 }

    // Warning states
    readonly property bool cpuWarning: Plasmoid.configuration.enableWarningAccent &&
                                       root.cpuPct >= (Plasmoid.configuration.cpuWarningThreshold || 80)
    readonly property bool ramWarning: Plasmoid.configuration.enableWarningAccent &&
                                       root.ramPct >= (Plasmoid.configuration.ramWarningThreshold || 85)

    // Formatting helpers
    function formatBps(bps) {
        if (typeof bps !== "number" || isNaN(bps) || bps <= 0) return "0 B/s"
        if (bps >= 1073741824) return (bps / 1073741824).toFixed(2) + " GB/s"
        if (bps >= 1048576)    return (bps / 1048576).toFixed(1) + " MB/s"
        if (bps >= 1024)       return (bps / 1024).toFixed(0) + " KB/s"
        return Math.round(bps) + " B/s"
    }
    function formatBytes(b) {
        if (typeof b !== "number" || isNaN(b) || b <= 0) return "--"
        if (b >= 1073741824) return (b / 1073741824).toFixed(1) + " GB"
        return Math.round(b / 1048576) + " MB"
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MPRIS — Media player data via org.kde.plasma.private.mpris
    //   mpris2Model is instantiated by the Mpris plugin automatically.
    //   currentPlayer tracks the highest-priority (playing) player.
    // ─────────────────────────────────────────────────────────────────────────
    Mpris.Mpris2Model { id: mpris2Model }

    // Convenient aliases; all use optional chaining so they silently degrade
    readonly property var mprisPlayer: mpris2Model.currentPlayer ?? null
    readonly property bool mediaIsPlaying: mprisPlayer?.playbackStatus === Mpris.PlaybackStatus.Playing
    readonly property bool mediaHasPlayer: mprisPlayer !== null
    readonly property string mediaTitle:   safeStr(mprisPlayer?.track)
    readonly property string mediaArtist:  safeStr(mprisPlayer?.artist)
    readonly property string mediaAlbum:   safeStr(mprisPlayer?.album)
    readonly property string mediaArtUrl:  safeStr(mprisPlayer?.artUrl)
    readonly property bool mediaCanNext:     mprisPlayer?.canGoNext ?? false
    readonly property bool mediaCanPrevious: mprisPlayer?.canGoPrevious ?? false

    // Sanitise value – never show undefined/null/NaN in the UI
    function safeStr(v) {
        if (v === undefined || v === null) return ""
        const s = String(v).trim()
        if (s === "undefined" || s === "null" || s === "NaN") return ""
        return s
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FULL REPRESENTATION
    // ─────────────────────────────────────────────────────────────────────────
    fullRepresentation: Item {
        id: fullRep

        Layout.minimumWidth:  260
        Layout.minimumHeight: 320
        Layout.preferredWidth:  340
        Layout.preferredHeight: 480

        ColumnLayout {
            id: mainCol
            anchors {
                fill: parent
                topMargin: 4
                bottomMargin: 4
            }
            spacing: root.sectionSpacing

            // ── CLOCK SECTION ─────────────────────────────────────────────
            ClockSection {
                id: clockSection
                visible: Plasmoid.configuration.showClock !== false
                Layout.fillWidth: true
                primaryColor:   root.primaryTextColor
                secondaryColor: root.secondaryTextColor
                accentColor:    root.accentColor
                enableAnimations: root.enableAnimations
                enableShadow:   root.enableTextShadow
                displayFont:    root.displayFont
                bodyFont:       root.bodyFont
                showWeekday:    Plasmoid.configuration.showWeekday !== false
                showDate:       Plasmoid.configuration.showDate !== false
                showSeconds:    Plasmoid.configuration.showSeconds === true
                use24Hour:      Plasmoid.configuration.use24Hour !== false
                showAmPm:       Plasmoid.configuration.showAmPm === true
                dateOrder:      Plasmoid.configuration.dateOrder || 0
                timeFontSize:   Plasmoid.configuration.timeFontSize || 36
            }

            // Separator
            SectionDivider {
                visible: Plasmoid.configuration.showClock !== false && Plasmoid.configuration.showMusic !== false
                Layout.fillWidth: true
                color: root.accentColor
                opacity: Plasmoid.configuration.separatorOpacity ?? 0.20
            }

            // ── MUSIC SECTION ─────────────────────────────────────────────
            MediaSection {
                id: mediaSection
                visible: Plasmoid.configuration.showMusic !== false
                Layout.fillWidth: true
                primaryColor:    root.primaryTextColor
                secondaryColor:  root.secondaryTextColor
                accentColor:     root.accentColor
                enableAnimations: root.enableAnimations
                enableShadow:    root.enableTextShadow
                metaFontSize:    Plasmoid.configuration.metaFontSize || 11

                // Media data bindings
                mediaTitle:     root.mediaTitle
                mediaArtist:    root.mediaArtist
                mediaAlbum:     root.mediaAlbum
                mediaArtUrl:    root.mediaArtUrl
                isPlaying:      root.mediaIsPlaying
                hasPlayer:      root.mediaHasPlayer
                canGoNext:      root.mediaCanNext
                canGoPrevious:  root.mediaCanPrevious

                // Config flags
                showArtwork:    Plasmoid.configuration.showArtwork !== false
                showAlbum:      Plasmoid.configuration.showAlbum !== false
                showArtist:     Plasmoid.configuration.showArtist !== false
                showVisualizer: Plasmoid.configuration.showVisualizer !== false
                showControls:   Plasmoid.configuration.showControls !== false
                collapseWhenNoMedia: Plasmoid.configuration.collapseWhenNoMedia === true
                artworkSize:    Plasmoid.configuration.artworkSize || 64

                // MPRIS control callbacks
                // MPRIS method names are capitalised (Play/Pause/Next/Previous),
                // matching applets/mediacontroller in plasma-workspace.
                onPlayPauseRequested: {
                    if (!root.mprisPlayer) return
                    if (root.mediaIsPlaying) {
                        root.mprisPlayer.Pause()
                    } else {
                        root.mprisPlayer.Play()
                    }
                }
                onPreviousRequested: { if (root.mprisPlayer?.canGoPrevious) root.mprisPlayer.Previous() }
                onNextRequested:     { if (root.mprisPlayer?.canGoNext)     root.mprisPlayer.Next() }
            }

            // Separator
            SectionDivider {
                visible: Plasmoid.configuration.showMusic !== false && Plasmoid.configuration.showSystem !== false
                Layout.fillWidth: true
                color: root.accentColor
                opacity: Plasmoid.configuration.separatorOpacity ?? 0.20
            }

            // ── SYSTEM SECTION ────────────────────────────────────────────
            SystemSection {
                id: systemSection
                visible: Plasmoid.configuration.showSystem !== false
                Layout.fillWidth: true
                primaryColor:   root.primaryTextColor
                secondaryColor: root.secondaryTextColor
                accentColor:    root.accentColor
                enableAnimations: root.enableAnimations
                enableShadow:    root.enableTextShadow
                sysFontSize:    Plasmoid.configuration.systemFontSize || 10

                showCpu:        Plasmoid.configuration.showCpu !== false
                showRam:        Plasmoid.configuration.showRam !== false
                showNetwork:    Plasmoid.configuration.showNetwork !== false
                showBars:       Plasmoid.configuration.showBars !== false

                cpuPct:         root.cpuPct
                ramPct:         root.ramPct
                netDownBps:     root.netDownBps
                netUpBps:       root.netUpBps
                netDownText:    root.formatBps(root.netDownBps)
                netUpText:      root.formatBps(root.netUpBps)
                ramUsedText:    root.formatBytes(Number(ramUsedSensor.value))
                ramTotalText:   root.formatBytes(Number(ramTotalSensor.value))

                cpuWarning:     root.cpuWarning
                ramWarning:     root.ramWarning
            }

            // Spacer
            Item { Layout.fillHeight: true }
        }
    }
}
