# Nothing Lock

A minimal, Nothing-inspired lock screen for **KDE Plasma 6** (Fedora 44 / Wayland),
matching the `dashboard`, `countdown` and `calculator` widgets in this repo.

Package ID: `com.mrudhuhas.nothinglock`

```
              MON · 31 AUG

                 13:24

              ────────────

                 mrudhuhas
                 PASSWORD
               ────────────  ·        ← thin underline, small red focus dot

               CAPS LOCK IS ON        ← status / PAM messages (red on error)

  87% ▍▍▍▍▍▍▍▍░░              SLEEP   SWITCH USER
```

## Why a *shell* package, not a Look-and-Feel package

In current Plasma 6 the lock screen QML is **no longer part of the Look-and-Feel
package** — the `Plasma/LookAndFeel` package structure defines `splashmainscript`,
`windowswitchermainscript`, `logoutmainscript` but **not** `lockscreenmainscript`.
`kscreenlocker` loads `lockscreen/LockScreen.qml` from the active **`Plasma/Shell`
package** (`plasmashellrc → [Shell] → ShellPackage`, default `org.kde.plasma.desktop`).

So this is a `Plasma/Shell` package that declares
`"X-Plasma-FallbackPackage": "org.kde.plasma.desktop"`. Plasma's `ShellPackage`
structure automatically falls back to the stock desktop package for every file
this one does **not** ship — and this one ships **only** `contents/lockscreen/`.
Activating it therefore changes **only the lock screen**: not the global theme,
colour scheme, icons, window decorations, panels, or desktop layout.

## Authentication

Uses the `authenticator` context object provided by `kscreenlocker`
(`org.kde.kscreenlocker` / `PamAuthenticators`):

| Call / signal | Use |
| --- | --- |
| `authenticator.startAuthenticating()` | open the PAM conversation — **once**, when the UI is first revealed (and again after a failure) |
| `authenticator.respond(password)` | submit the secret against that conversation on Enter / unlock |
| `onSucceeded()` | `Qt.quit()` — hands back to the normal Plasma unlock flow |
| `onFailed(kind)` (`kind === 0`) | wrong password → red `UNLOCKING FAILED`, clear field, restart auth |
| `onErrorMessageChanged` / `onInfoMessageChanged` / `onPromptChanged` / `onPromptForSecretChanged` | live PAM conversation text (expired password, fingerprint prompts, lock-out delays, …) |

The password string only ever reaches `authenticator.respond()`. It is never
logged, printed, or written to any config. `echoMode: TextInput.Password`.

## Fonts

`font.family: "Ndot"` for the **time digits only** (`:` is drawn as two dots in
QML, never through the font). Weekday/date, user name, prompt, status, actions
and battery use the Plasma system sans. If `Ndot` is not installed the time
falls back to `monospace`. **The font is not bundled.** Configurable family and
an on/off switch in the settings panel.

## Configuration

`System Settings → Screen Locking → Appearance` shows this package's panel
(clock format, seconds, date, user name, battery, actions, display font, accent
colour, overlay darkness). Stored in `kscreenlockerrc [Greeter][LnF]`.

## Install

```bash
cd lockscreen && ./scripts/install.sh
```

Installs to `~/.local/share/plasma/shells/com.mrudhuhas.nothinglock/` via
`kpackagetool6 --type Plasma/Shell`. **No sudo. Nothing is activated yet.**

`./scripts/install.sh --clean` — remove + reinstall (development).

## Test safely (does NOT lock your session)

```bash
kscreenlocker_greet --testing --shell com.mrudhuhas.nothinglock
```

(binary path varies — `rpm -ql kscreenlocker | grep kscreenlocker_greet`, often
`/usr/libexec/kscreenlocker_greet` or `/usr/lib64/libexec/kscreenlocker_greet`.)
This opens the greeter in a normal window. Type your password; on success the
test window just closes. Also lint first:

```bash
qmllint6 package/contents/lockscreen/*.qml package/contents/lockscreen/components/*.qml
```

## Activate

```bash
./scripts/install.sh --activate      # sets plasmashellrc [Shell] ShellPackage
loginctl lock-session                # try it for real
```

No plasmashell restart is needed — the greeter is a fresh process each lock.

## Revert / recover

```bash
./scripts/install.sh --deactivate    # or: ./scripts/uninstall.sh
```

If the custom lock screen ever fails to load, **kscreenlocker automatically
loads its built-in fallback locker** — you are not locked out. If it loads but
misbehaves, recover from a TTY:

1. `Ctrl`+`Alt`+`F3` → log in as your user.
2. `kwriteconfig6 --file plasmashellrc --group Shell --key ShellPackage --delete`
3. `loginctl unlock-session $(loginctl --value -p Sessions show-user "$USER" | awk '{print $1}')`
   (or just `loginctl list-sessions`, then `loginctl unlock-session <ID>`).
4. `Ctrl`+`Alt`+`F2` (or `F1`) back to the graphical session.
5. Optionally `rm -rf ~/.local/share/plasma/shells/com.mrudhuhas.nothinglock`.

No system files are ever modified; the stock Breeze packages are untouched.
