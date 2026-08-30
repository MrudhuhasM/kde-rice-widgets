# Desktop System Monitor Plasmoid for KDE Plasma 6

A minimal, 100% transparent desktop system monitor widget for **KDE Plasma 6** crafted with an *Attack on Titan*-inspired military instrument-panel aesthetic.

Designed for desktop ricing on **Fedora 44 (Wayland)**, providing live CPU, RAM, and Network throughput monitoring backed directly by native KDE Plasma 6 sensor facilities (`ksystemstats`).

---

## ⚔️ Aesthetic & Design Principles

* **100% Transparent Root:** Sits directly on your desktop wallpaper with zero opaque or semi-opaque card background.
* **Focused 3-Metric Scope:** Displays strictly CPU usage, RAM utilization, and Network throughput—no overwhelming sensor clutter.
* **Military / Instrument HUD:** Clean letter-spaced uppercase typography, terminal bracket endcaps, and ultra-thin metric lines.
* **Restrained Crimson Accents:** Accent color (`#B72B2B` by default) triggers on configurable thresholds (e.g. CPU > 80%, RAM > 85%).
* **Non-Polling Native Data Engine:** Uses native KDE Plasma 6 `org.kde.ksysguard.sensors` (KSystemStats) instead of repeated shell execution loops.

---

## 🛡️ Critical Transparency Guarantee

This widget is built strictly for the desktop:
```qml
Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
preferredRepresentation: fullRepresentation
```
- **No `compactRepresentation`:** Eliminates Plasma's default desktop applet wrapper.
- **No Background Surfaces:** Contains zero `Rectangle` backdrops, `Kirigami.Card`, `FrameSvg`, or `StandardBackground` elements.
- **Pure QML HUD Layout:** All visual elements float seamlessly over your wallpaper.

---

## 📊 Data Source Architecture (KSystemStats & Plasma 6)

The plasmoid connects directly to KDE Plasma 6's official sensor architecture (`org.kde.ksysguard.sensors` powered by `ksystemstats`):

| Metric | Sensor ID | Description & Derivation |
| :--- | :--- | :--- |
| **CPU Usage** | `cpu/all/usage` | Total aggregate CPU utilization across all cores (0–100%) |
| **RAM Used** | `memory/physical/used` | Physical memory currently in use (`total - available`) |
| **RAM Total** | `memory/physical/total` | Total installed physical RAM |
| **RAM %** | `memory/physical/usedPercent` | Percentage of physical memory in use (fallback: `used / total * 100`) |
| **Network Down**| `network/all/download` | Real-time aggregate download rate in Bytes/sec (excluding loopback) |
| **Network Up** | `network/all/upload` | Real-time aggregate upload rate in Bytes/sec (excluding loopback) |

### Memory Definition
Follows the modern Linux standard: $\text{Used} = \text{Total} - \text{Available}$. Cached file buffers are not counted as used memory, preventing misleading memory reporting.

### Network Throughput
Reports real-time transfer rates with automatic binary-prefix unit formatting ($1024$ base):
- `0 B/s`, `824 B/s`, `42.1 KB/s`, `3.8 MB/s`, `1.2 GB/s`

---

## 📁 Project Structure

```
system-monitor/
├── .gitignore
├── LICENSE
├── README.md
├── package/
│   ├── metadata.json                 # Plasma 6 package manifest (com.mrudhuhas.systemmonitor)
│   └── contents/
│       ├── config/
│       │   ├── main.xml              # KConfig schema definition
│       │   └── config.qml            # Configuration categories model
│       └── ui/
│           ├── main.qml              # PlasmoidItem root & sensor bindings
│           ├── configGeneral.qml     # General settings page
│           ├── configAppearance.qml  # Appearance & typography settings page
│           ├── configThresholds.qml  # Warning threshold settings page
│           └── components/
│               ├── MetricBar.qml     # Minimalist military HUD progress bar
│               └── NetworkThroughput.qml # Live network throughput display
└── scripts/
    ├── install.sh                    # Automated Plasma 6 installer (--clean supported)
    └── uninstall.sh                  # Uninstaller
```

---

## 🚀 Installation

### Prerequisites (Fedora 44 / KDE Plasma 6)
Ensure standard Plasma 6 sensor and package libraries are installed (default on Fedora KDE):
```bash
sudo dnf install kf6-kpackage kf6-kirigami qt6-qtdeclarative libksysguard-qt6
```

### Option A: Automated Install Script (Recommended)
```bash
cd kde-rice-widgets/system-monitor
chmod +x scripts/*.sh
./scripts/install.sh
```

*(For a clean reinstall during development: `./scripts/install.sh --clean`)*

### Option B: Manual Installation via `kpackagetool6`
```bash
kpackagetool6 -t Plasma/Applet --install package/
```

---

## 🧪 Testing on KDE Plasma 6

Follow this workflow on your Fedora 44 machine:

### 1. Test in a Standalone Window (Instant Feedback)
```bash
plasmawindowed com.mrudhuhas.systemmonitor
```

### 2. Add to Desktop
1. Right-click your empty desktop background $\to$ **Add Widgets...**
2. Search for **"System Monitor"**.
3. Drag and drop it onto your desktop.
4. Right-click the widget $\to$ **Configure System Monitor...** to adjust thresholds and styling.

### 3. Inspect Runtime Logs / QML Errors
```bash
journalctl -f --user -u plasma-plasmashell.service
```

---

## ⚙️ Configuration Options

| Setting | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `showTitle` | Bool | `true` | Display header title above metrics |
| `title` | String | `SYSTEM STATUS` | Title text |
| `uppercaseTitle` | Bool | `true` | Render title in uppercase |
| `showCpu` | Bool | `true` | Show CPU bar and percentage |
| `showRam` | Bool | `true` | Show RAM bar and percentage |
| `showRamUsedTotal`| Bool | `true` | Show formatted used/total memory (e.g. `6.2 / 15.7 GB`) |
| `showNetwork` | Bool | `true` | Show download/upload throughput |
| `showPercentages` | Bool | `true` | Display numeric percentages beside labels |
| `updateInterval` | Integer | `1` | Sensor refresh rate in seconds (1, 2, or 5) |
| `enableAnimations`| Bool | `true` | Smooth bar interpolation |
| `cpuWarningThreshold` | Integer | `80` | CPU utilization percentage threshold for crimson warning |
| `ramWarningThreshold` | Integer | `85` | RAM utilization percentage threshold for crimson warning |
| `enableWarningAccent` | Bool | `true` | Highlight metrics in crimson when thresholds exceeded |
| `accentColor` | Hex String | `#B72B2B` | Crimson accent for warning states and details |
| `barThickness` | Integer | `2` | Height in pixels for progress indicator bars |

---

## 🗑️ Uninstallation

To remove the system monitor plasmoid:
```bash
./scripts/uninstall.sh
```

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
