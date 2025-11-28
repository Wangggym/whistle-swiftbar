#!/bin/bash

# Whistle SwiftBar Plugin Installer
# Installs the plugin to SwiftBar's plugin directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=================================="
echo "Whistle SwiftBar Plugin Installer"
echo "=================================="
echo ""

# Check if SwiftBar is installed
SWIFTBAR_PLUGIN_DIR="$HOME/Library/Application Support/SwiftBar"

if [ ! -d "$SWIFTBAR_PLUGIN_DIR" ]; then
    echo -e "${YELLOW}⚠️  SwiftBar not found!${NC}"
    echo ""
    echo "SwiftBar is required to use this plugin."
    echo "Install it using Homebrew:"
    echo ""
    echo "  brew install swiftbar"
    echo ""
    echo "Or download from: https://github.com/swiftbar/SwiftBar"
    echo ""
    read -p "Do you want to install SwiftBar now using Homebrew? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &> /dev/null; then
            echo "Installing SwiftBar..."
            brew install swiftbar
            # Create plugin directory
            mkdir -p "$SWIFTBAR_PLUGIN_DIR"
        else
            echo -e "${RED}❌ Homebrew not found. Please install SwiftBar manually.${NC}"
            exit 1
        fi
    else
        exit 1
    fi
fi

# Create plugin directory if it doesn't exist
mkdir -p "$SWIFTBAR_PLUGIN_DIR"

# Check if config exists, if not create from example
CONFIG_FILE="${SCRIPT_DIR}/config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "📝 Creating config file from example..."
    cp "${SCRIPT_DIR}/config.example.sh" "$CONFIG_FILE"
    echo -e "${GREEN}✓${NC} Config file created: $CONFIG_FILE"
    echo ""
    echo -e "${YELLOW}⚠️  Please edit config.sh to set your Whistle host and port!${NC}"
    echo ""
fi

# Copy main script to SwiftBar plugin directory
echo "📦 Installing plugin..."
cp "${SCRIPT_DIR}/whistle.30s.sh" "$SWIFTBAR_PLUGIN_DIR/"
chmod +x "$SWIFTBAR_PLUGIN_DIR/whistle.30s.sh"

# Copy utils directory
echo "📦 Installing utilities..."
cp -r "${SCRIPT_DIR}/utils" "$SWIFTBAR_PLUGIN_DIR/"
chmod +x "$SWIFTBAR_PLUGIN_DIR/utils/"*.sh

# Copy config to SwiftBar directory
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$SWIFTBAR_PLUGIN_DIR/"
    echo -e "${GREEN}✓${NC} Config file copied to SwiftBar directory"
fi

echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Edit the config file:"
echo "   $SWIFTBAR_PLUGIN_DIR/config.sh"
echo ""
echo "2. Set your Whistle host and port (default: 127.0.0.1:8899)"
echo ""
echo "3. Launch or refresh SwiftBar"
echo ""
echo "4. Look for the 🔧 icon in your menu bar!"
echo ""

# Ask if user wants to open config file
read -p "Do you want to edit the config now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ${EDITOR:-nano} "$SWIFTBAR_PLUGIN_DIR/config.sh"
fi

# Try to refresh SwiftBar
if pgrep -x "SwiftBar" > /dev/null; then
    echo "🔄 Refreshing SwiftBar..."
    open "swiftbar://refreshallplugins"
    echo -e "${GREEN}✓${NC} SwiftBar refreshed!"
else
    echo "💡 Please launch SwiftBar to see the plugin"
fi

echo ""
echo "=================================="
echo "Installation complete! 🎉"
echo "=================================="

