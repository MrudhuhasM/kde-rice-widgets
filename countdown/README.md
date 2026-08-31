# Countdown

A Nothing-inspired countdown / timeline instrument for the KDE Plasma 6 desktop,
redesigned to match the `dashboard` widget.

Plugin ID: `com.mrudhuhas.countdown`

## Composition

```
UNTIL
03 SEP · 18:00           ← target (system font, restrained)

04  DAYS                 ← only shown while ≥ 1 day remains

07:13:42                 ← HERO remaining time — display font, geometry colons

············●···········  ← segmented timeline = real elapsed progress
```

The hero adapts to the remaining scale, predictably:

| Remaining | Hero |
| --------- | ---- |
| ≥ 1 day   | `NN DAYS` line + `HH:MM:SS` |
| < 1 day   | `HH:MM:SS` |
| < 1 hour  | `MM:SS` (enlarged) |
| < 1 min   | `MM:SS` (enlarged) + one-element opacity pulse |
| reached   | `COMPLETE` / configured text, timeline full |

## Progress & urgency

The timeline is a row of geometric segments; the filled count is
`elapsed / total-span` — actual progress, no decorative motion. Normal state is
monochrome; **urgent** turns the leading segment red; **critical** turns the hero
digits and the leading segment red with a slow ~2 s breath.

## Preserved

`parseTargetDate`, `parseStartDate`, the countdown decomposition, `countdownProgress`,
the timer cadence (1 s with seconds shown, 5 s otherwise), the config re-parse
hooks, and the urgent/critical threshold logic are all unchanged. Only the
presentation is new. All config keys are retained.

## Typography

Remaining-time digits use a configurable display font (`NDot 57` by default);
the `:` separators are drawn as stacked dots in QML, never through the font.
Falls back to `monospace` when the family is missing.

## Install

```bash
./scripts/install.sh --clean
```
