#!/usr/bin/env bash
# ==============================================================================
# Countdown Widget (com.mrudhuhas.countdown) - Plasma 6 Installer
# Target: Fedora 44 / KDE Plasma 6 (Wayland)
# ==============================================================================

set -e

PLUGIN_ID="com.mrudhuhas.countdown"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_DIR="${REPO_DIR}/package"
DEST_DIR="${HOME}/.local/share/plasma/plasmoids/${PLUGIN_ID}"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}  Installing KDE Plasma 6 Countdown Widget           ${NC}"
echo -e "${CYAN}  Plugin ID: ${PLUGIN_ID}${NC}"
echo -e "${CYAN}====================================================${NC}"

if [ ! -d "${PACKAGE_DIR}" ]; then
    echo -e "${RED}Error: Package directory not found at ${PACKAGE_DIR}${NC}"
    exit 1
fi

# Method 1: Using kpackagetool6 (Recommended KDE Plasma 6 tool)
if command -v kpackagetool6 &> /dev/null; then
    echo -e "${YELLOW}--> Checking for existing installation via kpackagetool6...${NC}"
    if kpackagetool6 -t Plasma/Applet --list | grep -q "${PLUGIN_ID}"; then
        echo -e "${YELLOW}--> Upgrading existing plasmoid package...${NC}"
        kpackagetool6 -t Plasma/Applet --upgrade "${PACKAGE_DIR}"
    else
        echo -e "${GREEN}--> Installing new plasmoid package...${NC}"
        kpackagetool6 -t Plasma/Applet --install "${PACKAGE_DIR}"
    fi
else
    # Method 2: Fallback direct user directory deployment
    echo -e "${YELLOW}Notice: 'kpackagetool6' not found in PATH. Performing direct user installation...${NC}"
    mkdir -p "${HOME}/.local/share/plasma/plasmoids"
    if [ -d "${DEST_DIR}" ]; then
        echo -e "${YELLOW}--> Removing previous version at ${DEST_DIR}...${NC}"
        rm -rf "${DEST_DIR}"
    fi
    echo -e "${GREEN}--> Copying package files to ${DEST_DIR}...${NC}"
    cp -r "${PACKAGE_DIR}" "${DEST_DIR}"
fi

echo -e "\n${GREEN}✔ Installation / Upgrade complete!${NC}"
echo -e "${CYAN}----------------------------------------------------${NC}"
echo -e "Next steps on Fedora 44 / KDE Plasma 6:"
echo -e "  1. Right click your desktop -> ${YELLOW}Add Widgets...${NC}"
echo -e "  2. Search for ${YELLOW}'Countdown'${NC}"
echo -e "  3. Drag and drop it onto your desktop."
echo -e "  4. Right click the widget -> ${YELLOW}Configure Countdown...${NC} to set your target."
echo -e ""
echo -e "To reload Plasma if the widget does not appear immediately:"
echo -e "  ${YELLOW}kquitapp6 plasmashell && kstart plasmashell${NC}"
echo -e "  (or: ${YELLOW}systemctl --user restart plasma-plasmashell.service${NC})"
echo -e "${CYAN}====================================================${NC}"
