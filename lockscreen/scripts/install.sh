#!/usr/bin/env bash
# ==============================================================================
# Nothing Lock (com.mrudhuhas.nothinglock) — Plasma 6 lock screen installer
# Target: Fedora 44 / KDE Plasma 6 (Wayland)
#
#   ./scripts/install.sh              install or upgrade the package (no activation)
#   ./scripts/install.sh --clean      remove then reinstall
#   ./scripts/install.sh --activate   also set it as the active shell/lockscreen
#   ./scripts/install.sh --deactivate revert to the stock lock screen
#
# This is a Plasma/Shell package that falls back to org.kde.plasma.desktop for
# everything except contents/lockscreen/, so activating it changes ONLY the lock
# screen — not the global theme, colours, icons, panels or window decorations.
# No sudo. No system files touched.
# ==============================================================================
set -e

PLUGIN_ID="com.mrudhuhas.nothinglock"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)/package"
DEST_DIR="${HOME}/.local/share/plasma/shells/${PLUGIN_ID}"

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

MODE="install"
case "${1:-}" in
    --clean|-c)      MODE="clean" ;;
    --activate)      MODE="activate" ;;
    --deactivate)    MODE="deactivate" ;;
    "")              MODE="install" ;;
    *) echo -e "${RED}Unknown option: $1${NC}"; exit 1 ;;
esac

activate() {
    kwriteconfig6 --file plasmashellrc --group Shell --key ShellPackage "${PLUGIN_ID}"
    echo -e "${GREEN}--> Activated.${NC} plasmashellrc [Shell] ShellPackage = ${PLUGIN_ID}"
    echo -e "    The lock-screen greeter is a fresh process each time you lock,"
    echo -e "    so it takes effect on your NEXT lock — no plasmashell restart needed."
}
deactivate() {
    kwriteconfig6 --file plasmashellrc --group Shell --key ShellPackage --delete || true
    echo -e "${GREEN}--> Reverted to the stock lock screen.${NC}"
}

if [ "${MODE}" = "activate" ];   then activate;   exit 0; fi
if [ "${MODE}" = "deactivate" ]; then deactivate; exit 0; fi

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}  Installing Nothing Lock  (${PLUGIN_ID})${NC}"
echo -e "${CYAN}==================================================${NC}"

[ -d "${PACKAGE_DIR}" ] || { echo -e "${RED}Package dir not found: ${PACKAGE_DIR}${NC}"; exit 1; }

if command -v kpackagetool6 >/dev/null 2>&1; then
    if [ "${MODE}" = "clean" ]; then
        echo -e "${YELLOW}--> Clean reinstall...${NC}"
        kpackagetool6 --type Plasma/Shell --remove "${PLUGIN_ID}" 2>/dev/null || true
        rm -rf "${DEST_DIR}"
        kpackagetool6 --type Plasma/Shell --install "${PACKAGE_DIR}"
    elif kpackagetool6 --type Plasma/Shell --list 2>/dev/null | grep -q "${PLUGIN_ID}"; then
        echo -e "${YELLOW}--> Upgrading...${NC}"
        kpackagetool6 --type Plasma/Shell --upgrade "${PACKAGE_DIR}"
    else
        echo -e "${GREEN}--> Installing...${NC}"
        kpackagetool6 --type Plasma/Shell --install "${PACKAGE_DIR}"
    fi
else
    echo -e "${YELLOW}kpackagetool6 not found — copying directly.${NC}"
    mkdir -p "${HOME}/.local/share/plasma/shells"
    rm -rf "${DEST_DIR}"
    cp -r "${PACKAGE_DIR}" "${DEST_DIR}"
fi

echo -e "\n${GREEN}✔ Installed.${NC} Nothing is active yet — the stock lock screen is untouched."
echo -e "${CYAN}--------------------------------------------------${NC}"
echo -e "TEST it safely first (windowed, does NOT lock your session):"
echo -e "  ${YELLOW}\$(rpm -ql kscreenlocker | grep -m1 kscreenlocker_greet) --testing --shell ${PLUGIN_ID}${NC}"
echo -e ""
echo -e "ACTIVATE for real:"
echo -e "  ${YELLOW}./scripts/install.sh --activate${NC}   then lock with  ${YELLOW}loginctl lock-session${NC}"
echo -e ""
echo -e "REVERT:"
echo -e "  ${YELLOW}./scripts/install.sh --deactivate${NC}"
echo -e "${CYAN}==================================================${NC}"
