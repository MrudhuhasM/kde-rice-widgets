#!/usr/bin/env bash
# ==============================================================================
# Calculator Widget (com.mrudhuhas.calculator) - Uninstaller
# Target: Fedora 44 / KDE Plasma 6 (Wayland)
# ==============================================================================

set -e

PLUGIN_ID="com.mrudhuhas.calculator"
DEST_DIR="${HOME}/.local/share/plasma/plasmoids/${PLUGIN_ID}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}  Uninstalling Calculator Plasmoid (${PLUGIN_ID})     ${NC}"
echo -e "${CYAN}====================================================${NC}"

if command -v kpackagetool6 &> /dev/null; then
    if kpackagetool6 -t Plasma/Applet --list | grep -q "${PLUGIN_ID}"; then
        echo -e "${YELLOW}--> Removing via kpackagetool6...${NC}"
        kpackagetool6 -t Plasma/Applet --remove "${PLUGIN_ID}" || true
    fi
fi

if [ -d "${DEST_DIR}" ]; then
    echo -e "${YELLOW}--> Cleaning up user directory: ${DEST_DIR}...${NC}"
    rm -rf "${DEST_DIR}"
fi

echo -e "\n${GREEN}✔ Calculator plasmoid successfully uninstalled.${NC}"
echo -e "${CYAN}====================================================${NC}"
