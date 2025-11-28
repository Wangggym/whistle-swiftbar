#!/bin/bash

# Whistle SwiftBar Plugin Uninstaller
# Removes the plugin from SwiftBar's plugin directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SWIFTBAR_PLUGIN_DIR="$HOME/Library/Application Support/SwiftBar"

echo "===================================="
echo "Whistle SwiftBar Plugin Uninstaller"
echo "===================================="
echo ""

# Check if plugin is installed
if [ ! -f "$SWIFTBAR_PLUGIN_DIR/whistle.30s.sh" ]; then
    echo -e "${YELLOW}⚠️  Plugin not found in SwiftBar directory${NC}"
    echo "Nothing to uninstall."
    exit 0
fi

# Confirm uninstallation
echo "This will remove the Whistle plugin from SwiftBar."
echo ""
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Remove plugin script
echo "🗑️  Removing plugin..."
rm -f "$SWIFTBAR_PLUGIN_DIR/whistle.30s.sh"

# Remove utils directory
if [ -d "$SWIFTBAR_PLUGIN_DIR/utils" ]; then
    echo "🗑️  Removing utilities..."
    rm -rf "$SWIFTBAR_PLUGIN_DIR/utils"
fi

# Ask about config file
if [ -f "$SWIFTBAR_PLUGIN_DIR/config.sh" ]; then
    echo ""
    read -p "Do you want to remove the config file? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$SWIFTBAR_PLUGIN_DIR/config.sh"
        echo -e "${GREEN}✓${NC} Config file removed"
    else
        echo "Config file kept at: $SWIFTBAR_PLUGIN_DIR/config.sh"
    fi
fi

echo ""
echo -e "${GREEN}✓ Uninstallation complete!${NC}"
echo ""

# Try to refresh SwiftBar
if pgrep -x "SwiftBar" > /dev/null; then
    echo "🔄 Refreshing SwiftBar..."
    open "swiftbar://refreshallplugins"
    echo -e "${GREEN}✓${NC} SwiftBar refreshed!"
fi

echo ""
echo "===================================="
echo "Plugin removed successfully! 👋"
echo "===================================="

