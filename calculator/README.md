# Calculator

A keyboard-first, expression-first KDE Plasma 6 desktop calculator, redesigned
around the same Nothing-inspired language as the `dashboard` widget.

Plugin ID: `com.mrudhuhas.calculator`

## Composition

```
CALC                              ·      ← identifier + focus dot (red when focused)
                        245 × 18 ▏       ← expression (system font) + blinking caret
                            4 4 1 0      ← RESULT — display font, right-anchored, auto-shrinks
────────────────────────────────
 7  8  9     ÷                           ← bare-glyph digit cluster + operator rail
 4  5  6     ×
 1  2  3     −
 0  .  ⌫     +
 AC ( ) % ANS            =               ← utility strip + restrained red equals
 12 × 4  ·  48                           ← history: last line only, click to expand
```

No bordered keys, no card, no grid of rounded rectangles. Keys are transparent;
hover shows a faint geometric backing, press does a short scale/opacity dip, and
`=` is the only red accent.

## Preserved

The entire evaluation engine (`js/CalculatorEngine.js`: tokeniser, shunting-yard,
RPN evaluator, operator precedence, parentheses, unary minus, `%` postfix,
precision/formatting, division-by-zero and error strings) and the full keyboard
map are unchanged. Only the presentation was rewritten.

## Typography

Digits of the **result** use a configurable display font (`NDot 57` by default);
`.` and `-` in the result are drawn as geometry, never through the display font.
Everything else — expression, operators, labels, history — uses the system font.
If the display family is not installed it falls back to `monospace`.

## Install

```bash
./scripts/install.sh --clean
```
