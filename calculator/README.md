# Desktop Calculator Plasmoid for KDE Plasma 6

A minimal, 100% transparent desktop calculator widget for **KDE Plasma 6** crafted with an *Attack on Titan*-inspired military instrument-panel aesthetic.

Designed for desktop ricing on **Fedora 44 (Wayland)**, featuring a deterministic Shunting-Yard math engine, keyboard input, calculation history, smooth animations, and restrained crimson accents.

---

## ⚔️ Aesthetic & Design Principles

* **100% Transparent Root:** Sits directly on your desktop wallpaper with zero opaque or semi-opaque card background.
* **Military / Instrument HUD:** Clean letter-spaced uppercase typography, subtle bracket endcaps, and thin divider lines.
* **Restrained Crimson Accents:** Accent color (`#B72B2B` by default) highlights the equals button, error states, and active focus indicators.
* **Non-Blocking Keyboard First:** Full hardware keyboard support without stealing global desktop focus.
* **Subtle Transitions:** Smooth vertical slide-and-fade animations when results change, and tactile button press animations.

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

## 🧮 Deterministic Math Engine (`CalculatorEngine.js`)

Unlike naive widgets that rely on dangerous `eval()` or dynamic JavaScript code execution, this calculator implements a secure, deterministic **Shunting-Yard Parser & Reverse Polish Notation (RPN) Evaluator**:

- **No `eval()` or `Function()` execution.**
- **Operator Precedence & Associativity:** Handles `+`, `-`, `×`, `÷`, `%`, unary minus, and nested parentheses `(...)`.
- **Unary Minus Support:** Correctly distinguishes negative numbers (`-4 + 12 = 8`) from binary subtraction.
- **Postfix Percentage:** `50%` evaluates deterministically to `0.5`.
- **Floating-Point Artifact Cleaning:** Eliminates IEEE-754 noise (e.g. `0.1 + 0.2 = 0.3` instead of `0.30000000000000004`).
- **Controlled Error States:** Gracefully returns `DIVISION BY ZERO`, `UNMATCHED PARENTHESES`, or `INVALID EXPRESSION` without crashing.

---

## ⌨️ Keyboard Shortcuts & Interactions

Click anywhere on the calculator to focus:

| Key | Action |
| :--- | :--- |
| `0` – `9` / `.` | Digits and decimal point |
| `+` / `-` | Addition and Subtraction / Negative |
| `*` / `x` | Multiplication (`×`) |
| `/` | Division (`÷`) |
| `%` | Postfix Percentage |
| `(` / `)` | Parentheses |
| <kbd>Enter</kbd> / <kbd>Return</kbd> / `=` | Evaluate expression |
| <kbd>Backspace</kbd> | Delete last character (⌫) |
| <kbd>Escape</kbd> / <kbd>Delete</kbd> | Clear all (AC) |

---

## 📁 Project Structure

```
calculator/
├── .gitignore
├── LICENSE
├── README.md
├── package/
│   ├── metadata.json                 # Plasma 6 package manifest (com.mrudhuhas.calculator)
│   └── contents/
│       ├── config/
│       │   ├── main.xml              # KConfig schema definition
│       │   └── config.qml            # Configuration categories model
│       └── ui/
│           ├── main.qml              # PlasmoidItem root & keyboard handler
│           ├── configGeneral.qml     # General settings page
│           ├── configAppearance.qml  # Appearance & color settings page
│           ├── components/
│           │   ├── CalculatorButton.qml # Minimalist tactile HUD button
│           │   ├── AnimatedResult.qml   # Slide-and-fade result transition
│           │   └── HistoryItem.qml      # Clickable history recall item
│           └── js/
│               └── CalculatorEngine.js  # Deterministic Shunting-Yard evaluator
└── scripts/
    ├── install.sh                    # Automated Plasma 6 installer (--clean supported)
    └── uninstall.sh                  # Uninstaller
```

---

## 🚀 Installation

### Option A: Automated Install Script (Recommended)
```bash
cd kde-rice-widgets/calculator
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
plasmawindowed com.mrudhuhas.calculator
```

### 2. Add to Desktop
1. Right-click your empty desktop background $\to$ **Add Widgets...**
2. Search for **"Calculator"**.
3. Drag and drop it onto your desktop.
4. Click the widget and type on your physical keyboard or use the keypad.

### 3. Inspect Runtime Logs / QML Errors
```bash
journalctl -f --user -u plasma-plasmashell.service
```
Or when running via `plasmawindowed`:
```bash
QT_LOGGING_RULES="plasma*.debug=true" plasmawindowed com.mrudhuhas.calculator
```

---

## ⚙️ Configuration Options

| Setting | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `showTitle` | Bool | `true` | Display header title above expression |
| `title` | String | `FIELD CALCULATOR` | Title text |
| `uppercaseTitle` | Bool | `true` | Render title in uppercase |
| `showHistory` | Bool | `true` | Show calculation history below keypad |
| `maxHistoryItems` | Integer | `5` | Maximum number of stored history items |
| `resultPrecision`| Integer | `10` | Number of significant digits to format |
| `enableAnimations`| Bool | `true` | Button press and result slide transitions |
| `accentColor` | Hex String | `#B72B2B` | Crimson accent for equals button and focus |
| `customTextColor` | Hex String | `""` | Primary text color (defaults to Plasma theme) |
| `customSecondaryColor` | Hex String | `""` | Secondary text color (defaults to Plasma theme) |
| `titleFontSize` | Integer | `10` | Font size for title label |
| `expressionFontSize`| Integer | `14` | Font size for input expression |
| `resultFontSize`| Integer | `28` | Font size for main result number |
| `buttonFontSize`| Integer | `14` | Font size for keypad buttons |

---

## 🗑️ Uninstallation

To remove the calculator plasmoid:
```bash
./scripts/uninstall.sh
```

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
