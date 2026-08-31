#!/usr/bin/env bash
# ==============================================================================
# Dashboard Widget (com.mrudhuhas.dashboard) - Plasma 6 Installer
# Target: Fedora 44 / KDE Plasma 6 (Wayland)
#
#   ./scripts/install.sh          install or upgrade
#   ./scripts/install.sh --clean  remove then reinstall (dev workflow)
# ==============================================================================

set -e

PLUGIN_ID="com.mrudhuhas.dashboard"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_DIR="${REPO_DIR}/package"
DEST_DIR="${HOME}/.local/share/plasma/plasmoids/${PLUGIN_ID}"

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

CLEAN_INSTALL=false
if [[ "$1" == "--clean" || "$1" == "-c" ]]; then
    CLEAN_INSTALL=true
fi

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}  Installing KDE Plasma 6 Dashboard Widget           ${NC}"
echo -e "${CYAN}  Plugin ID: ${PLUGIN_ID}${NC}"
echo -e "${CYAN}====================================================${NC}"

if [ ! -d "${PACKAGE_DIR}" ]; then
    echo -e "${RED}Error: Package directory not found at ${PACKAGE_DIR}${NC}"
    exit 1
fi

if command -v kpackagetool6 &> /dev/null; then
    if [ "$CLEAN_INSTALL" = true ]; then
        echo -e "${YELLOW}--> Clean reinstall (--clean)...${NC}"
        if kpackagetool6 -t Plasma/Applet --list | grep -q "${PLUGIN_ID}"; then
            kpackagetool6 -t Plasma/Applet --remove "${PLUGIN_ID}" || true
        fi
        rm -rf "${DEST_DIR}"
        kpackagetool6 -t Plasma/Applet --install "${PACKAGE_DIR}"
    else
        if kpackagetool6 -t Plasma/Applet --list | grep -q "${PLUGIN_ID}"; then
            echo -e "${YELLOW}--> Upgrading existing package...${NC}"
            kpackagetool6 -t Plasma/Applet --upgrade "${PACKAGE_DIR}"
        else
            echo -e "${GREEN}--> Installing new package...${NC}"
            kpackagetool6 -t Plasma/Applet --install "${PACKAGE_DIR}"
        fi
    fi
else
    echo -e "${YELLOW}Notice: kpackagetool6 not found. Direct user install...${NC}"
    mkdir -p "${HOME}/.local/share/plasma/plasmoids"
    rm -rf "${DEST_DIR}"
    cp -r "${PACKAGE_DIR}" "${DEST_DIR}"
fi

echo -e "\n${GREEN}✔ Dashboard installation / upgrade complete.${NC}"
echo -e "${CYAN}----------------------------------------------------${NC}"
echo -e "Add it:  right click desktop -> ${YELLOW}Add Widgets...${NC} -> search ${YELLOW}Dashboard${NC}"
echo -e ""
echo -e "If it does not refresh (needed after --clean or QML edits):"
echo -e "  ${YELLOW}kquitapp6 plasmashell && kstart plasmashell${NC}"
echo -e "  (Wayland-safe; do NOT use 'plasmashell --replace')"
echo -e "  Optional cache flush: ${YELLOW}rm -rf ~/.cache/plasma* ~/.cache/qmlcache${NC}"
echo -e "${CYAN}====================================================${NC}"
