#!/usr/bin/env bash
# ==============================================================================
# Dashboard Widget (com.mrudhuhas.dashboard) - Uninstaller
# Target: Fedora 44 / KDE Plasma 6 (Wayland)
# ==============================================================================

set -e

PLUGIN_ID="com.mrudhuhas.dashboard"
DEST_DIR="${HOME}/.local/share/plasma/plasmoids/${PLUGIN_ID}"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}  Uninstalling Dashboard Plasmoid (${PLUGIN_ID})${NC}"
echo -e "${CYAN}====================================================${NC}"

if command -v kpackagetool6 &> /dev/null; then
    if kpackagetool6 -t Plasma/Applet --list | grep -q "${PLUGIN_ID}"; then
        echo -e "${YELLOW}--> Removing via kpackagetool6...${NC}"
        kpackagetool6 -t Plasma/Applet --remove "${PLUGIN_ID}"
    fi
fi

if [ -d "${DEST_DIR}" ]; then
    echo -e "${YELLOW}--> Cleaning up ${DEST_DIR}...${NC}"
    rm -rf "${DEST_DIR}"
fi

echo -e "\n${GREEN}✔ Dashboard plasmoid uninstalled.${NC}"
echo -e "Restart Plasma if the widget is still on screen:"
echo -e "  ${YELLOW}kquitapp6 plasmashell && kstart plasmashell${NC}"
echo -e "${CYAN}====================================================${NC}"
