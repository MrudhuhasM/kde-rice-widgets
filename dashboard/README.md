# Dashboard

A single transparent KDE Plasma 6 desktop widget that unifies three things that
would otherwise be three separate widgets:

1. **Clock** – weekday · date · time
2. **Music** – now playing (MPRIS): artwork, title, artist, album, visualizer, transport
3. **System** – CPU %, RAM %, network down/up

Plugin ID: `com.mrudhuhas.dashboard`

## Design

Nothing-inspired: monochrome first, one restrained red accent (`#D71920` by
default), generous spacing, uppercase micro-labels, monospaced numeric values,
segmented dot meters instead of thick progress bars, no gradients, no glass, no
big rounded card. The widget sits directly on the wallpaper:

```
Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
preferredRepresentation: fullRepresentation   // compactRepresentation is NOT defined
```

## Typography

Two font roles. **Display** — the clock digits only — uses a configurable
dot-matrix family (`NDot 57` by default, `Appearance → Display font`); the `:`
is drawn as stacked dots in QML so it never depends on the font, and the family
falls back to `monospace` when it is not installed. **Body** — everything else
(dates, media metadata, system labels and values) — uses the Plasma system font.
No proprietary font is bundled.

## Data sources

| Module | Mechanism |
| ------ | --------- |
| Clock  | `Date` + a QML `Timer` (minute-boundary aligned; 1 s only when seconds are shown). No network. |
| Music  | `org.kde.plasma.private.mpris` → `Mpris2Model.currentPlayer` (same API as the stock Plasma media controller applet). Methods: `Play() / Pause() / Next() / Previous()`. |
| System | `org.kde.ksysguard.sensors` (ksystemstats): `cpu/all/usage`, `memory/physical/usedPercent` (+ used/total fallback), `network/all/download`, `network/all/upload` — identical sensor IDs to the standalone `system-monitor` widget in this repo. |

### Player selection

`Mpris2Model.currentPlayer` already implements the selection policy used by
Plasma itself: the actively playing player wins; if none is playing it keeps the
most recently active player. Metadata is sanitised (`safeStr`) so `undefined` /
`null` / `NaN` never render — empty fields collapse their row, and with nothing
playing the module either collapses or shows `NO ACTIVE MEDIA` (configurable).

### Music visualizer — not real audio data

The visualizer is a **deterministic, playback-state-reactive animation**, not an
audio spectrum. It runs fixed per-bar sine oscillators (index-seeded, no
randomness) whose overall amplitude envelope tracks the real MPRIS play/pause
state and whose ticker stops entirely when idle.

Real amplitude/FFT data is not available from pure QML on Plasma 6 — PipeWire /
PulseAudio monitor capture needs a native helper (the KDE Store "Music Waves"
widget ships a compiled capture binary), and this repo's constraints forbid a
Python/Node/C++/daemon backend. The upgrade path is documented at the top of
`package/contents/ui/components/MusicVisualizer.qml`.

## Install (user-local, no sudo)

```bash
./scripts/install.sh            # install or upgrade
./scripts/install.sh --clean    # remove + reinstall (development)
./scripts/uninstall.sh
```

After `--clean` or any QML edit, refresh Plasma (Wayland-safe):

```bash
kquitapp6 plasmashell && kstart plasmashell
```

If QML still looks stale, clear the cache: `rm -rf ~/.cache/plasma* ~/.cache/qmlcache`

Then: right-click desktop → **Add Widgets…** → search **Dashboard**.

## Configuration

Five pages: General (module toggles, animations, refresh interval), Clock,
Music, System (metrics + warning thresholds), Appearance (accent / text colour
overrides, font sizes, spacing density, separator opacity, optional text
shadow). All persisted via KConfig (`config/main.xml`).
