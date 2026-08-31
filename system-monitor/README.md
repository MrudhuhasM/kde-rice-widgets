# System Monitor

A standalone Nothing-inspired transparent system monitor for KDE Plasma 6 —
CPU %, RAM %, network throughput. Shares the `dashboard` widget's typography,
segmented-dot indicator language and red-accent discipline.

Plugin ID: `com.mrudhuhas.systemmonitor`

```
SYSTEM ───────────────
CPU  18%  ●●○○○○○○○○
RAM  39%  ●●●●○○○○○○
         6.2 / 15.7 GB
NET ──────────────────
↓ 3.8 MB/s
↑ 620 KB/s
```

## Preserved

The sensor architecture is unchanged: `org.kde.ksysguard.sensors` (ksystemstats)
with sensor IDs `cpu/all/usage`, `memory/physical/usedPercent` (+ used/total
fallback), `memory/physical/used|total`, `network/all/download|upload`; the
`updateInterval` rate-limit and the warning-threshold logic are unchanged. All
config keys retained.

## Typography

Percentage values use a configurable display font (`NDot 57` default, falls back
to `monospace`); labels and byte counts use the system font. Thick progress bars
were replaced by segmented dot meters; red appears only on the leading dot in a
warning state.

## Install

```bash
./scripts/install.sh --clean
```
