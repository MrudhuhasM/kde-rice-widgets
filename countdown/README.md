# Countdown Plasmoid for KDE Plasma 6

A minimal, transparent desktop countdown widget for **KDE Plasma 6** crafted with an *Attack on Titan*-inspired military instrument-panel aesthetic.

Designed for desktop ricing on **Fedora 44 (Wayland)**, featuring restrained crimson accents, geometric HUD progress indicators, smooth digit transitions, and drift-free time calculations.

---

## ⚔️ Aesthetic & Design Principles

* **100% Transparent Root:** No opaque card or panel background—your wallpaper remains completely visible.
* **Military / Instrument HUD:** Clean letter-spaced uppercase typography, subtle bracket endcaps, and precision reticle markers.
* **Restrained Crimson Accents:** Accent color (`#B72B2B` by default) highlights progress, urgency, and completion without overwhelming the screen.
* **Subtle Transitions:** Smooth vertical slide-and-fade animations when digits or value groups update.
* **Urgency States:** Rhythmic, slow breathing pulse on the progress marker when reaching the final countdown threshold.

---

## ✨ Features

- **Drift-Free Countdown:** Calculates difference directly against the system clock (`targetDateTime - currentDateTime`) on each timer cycle rather than naive decrements.
- **Dynamic Multi-Day Support:** Automatically hides the days counter when under 24 hours (e.g. `02 : 14 : 36`). For longer deadlines, displays a dedicated `04 DAYS` indicator.
- **Objective Completion State:** Transitions cleanly to a customizable message (e.g., `OBJECTIVE COMPLETE` / `00 : 00 : 00`) with no negative counters.
- **Elapsed Progress Line:** Visualizes real timeline progress `(now - start) / (target - start)` with a precision diamond marker and end-cap brackets.
- **Urgency Levels:**
  - **Normal:** > 10 minutes remaining (restrained theme accent).
  - **Urgent:** ≤ 10 minutes remaining (accent color highlights time separators).
  - **Critical:** ≤ 1 minute remaining (slow breathing opacity pulse on progress indicator).
- **Comprehensive Configuration UI:** Native Kirigami / Plasma 6 settings dialog with quick presets (`+1h`, `+24h`, `Today`, `Tomorrow`), color palettes, custom font sizes, and animation toggles.

---

## 📁 Project Structure

```
rice-plasma-widgets/
├── .gitignore
├── LICENSE
├── README.md
├── package/
│   ├── metadata.json                 # Plasma 6 package manifest (com.mrudhuhas.countdown)
│   └── contents/
│       ├── config/
│       │   ├── main.xml              # KConfig schema definition
│       │   └── config.qml            # Configuration categories model
│       └── ui/
│           ├── main.qml              # PlasmoidItem root & countdown engine
│           ├── configGeneral.qml     # General settings page
│           ├── configAppearance.qml  # Appearance & color settings page
│           └── components/
│               ├── AnimatedValue.qml # Slide-and-fade digit transitions
│               └── ProgressLine.qml  # Military HUD progress line & reticle
└── scripts/
    ├── install.sh                    # Automated Plasma 6 installer
    └── uninstall.sh                  # Uninstaller
```

---

## 🚀 Installation

### Prerequisites (Fedora 44 / KDE Plasma 6)
Ensure standard KDE Plasma 6 development packages are present (typically installed by default on Fedora KDE):
```bash
sudo dnf install kf6-kpackage kf6-kirigami qt6-qtdeclarative
```

### Option A: Automated Install Script (Recommended)
```bash
git clone https://github.com/mrudhuhas/rice-plasma-widgets.git
cd rice-plasma-widgets
chmod +x scripts/*.sh
./scripts/install.sh
```

### Option B: Manual Installation via `kpackagetool6`
```bash
kpackagetool6 -t Plasma/Applet --install package/
```
*(To update an existing installation: `kpackagetool6 -t Plasma/Applet --upgrade package/`)*

---

## 🧪 Testing on KDE Plasma 6

Since code development occurs on source control, follow this exact workflow when testing and verifying on your Fedora 44 machine:

### 1. Test in a Standalone Window (Instant Feedback)
You can launch and test the widget in a standalone test window without reloading your desktop shell:
```bash
plasmawindowed com.mrudhuhas.countdown
```

### 2. Add to Desktop
1. Right-click anywhere on your empty desktop background.
2. Select **Add Widgets...** (or press <kbd>Meta</kbd>+<kbd>Alt</kbd>+<kbd>P</kbd>).
3. Search for **"Countdown"**.
4. Drag and drop the widget onto your desktop.
5. Right-click the widget and select **Configure Countdown...** to open the settings dialog.

### 3. Inspect Runtime Logs / QML Errors
To monitor live QML rendering warnings or debug outputs from Plasma:
```bash
journalctl -f --user -u plasma-plasmashell.service
```
Or when running via `plasmawindowed`:
```bash
QT_LOGGING_RULES="plasma*.debug=true;qt.qml.binding*.debug=true" plasmawindowed com.mrudhuhas.countdown
```

### 4. Live Reloading After Code Edits
When modifying files locally in `package/`:
```bash
./scripts/install.sh
# To restart Plasma Shell if necessary:
systemctl --user restart plasma-plasmashell.service
```

---

## ⚙️ Configuration Options

| Setting | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `title` | String | `MISSION ENDS IN` | Header label above countdown |
| `targetDate` | String | *(Tomorrow)* | Date in `YYYY-MM-DD` format |
| `targetTime` | String | `18:00:00` | Target time in `HH:MM:SS` format |
| `startDate` / `startTime` | String | *(Now - 24h)* | Reference baseline for percentage progress |
| `showSeconds` | Bool | `true` | Display seconds column |
| `enableAnimations` | Bool | `true` | Enable digit transitions & critical urgency pulse |
| `showProgressLine` | Bool | `true` | Display military HUD progress marker |
| `showTargetDateTime` | Bool | `true` | Display `UNTIL 19:00` footer label |
| `completedText` | String | `OBJECTIVE COMPLETE` | Header text when target timestamp is reached |
| `accentColor` | Hex String | `#B72B2B` | Restrained crimson or custom hex color |
| `customTextColor` | Hex String | `""` | Primary text color (defaults to Plasma theme) |
| `customSecondaryColor` | Hex String | `""` | Secondary text color (defaults to Plasma theme) |
| `titleFontSize` | Integer | `10` | Font size in pixels for objective title |
| `countdownFontSize` | Integer | `28` | Font size in pixels for countdown digits |
| `detailsFontSize` | Integer | `10` | Font size in pixels for target date footer |
| `urgentThresholdMinutes` | Integer | `10` | Threshold in minutes for urgent accenting |
| `criticalThresholdMinutes`| Integer | `1` | Threshold in minutes for pulsing indicator |

---

## 🗑️ Uninstallation

To remove the widget completely:
```bash
./scripts/uninstall.sh
```

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
