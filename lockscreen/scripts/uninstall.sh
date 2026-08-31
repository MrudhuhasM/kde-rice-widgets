#!/usr/bin/env bash
# ==============================================================================
# Nothing Lock (com.mrudhuhas.nothinglock) — uninstaller
# Reverts activation first, then removes the package. No sudo.
# ==============================================================================
set -e

PLUGIN_ID="com.mrudhuhas.nothinglock"
DEST_DIR="${HOME}/.local/share/plasma/shells/${PLUGIN_ID}"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}  Uninstalling Nothing Lock (${PLUGIN_ID})${NC}"
echo -e "${CYAN}==================================================${NC}"

# 1. Revert activation so the next lock uses the stock greeter.
CURRENT="$(kreadconfig6 --file plasmashellrc --group Shell --key ShellPackage 2>/dev/null || true)"
if [ "${CURRENT}" = "${PLUGIN_ID}" ]; then
    echo -e "${YELLOW}--> Reverting plasmashellrc [Shell] ShellPackage...${NC}"
    kwriteconfig6 --file plasmashellrc --group Shell --key ShellPackage --delete || true
fi

# 2. Remove the package.
if command -v kpackagetool6 >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Shell --remove "${PLUGIN_ID}" 2>/dev/null || true
fi
rm -rf "${DEST_DIR}"

echo -e "\n${GREEN}✔ Removed.${NC} The stock lock screen is active again on your next lock."
echo -e "  Verify with:  ${YELLOW}$(command -v kscreenlocker_greet || echo kscreenlocker_greet) --testing${NC}"
echo -e "${CYAN}==================================================${NC}"
