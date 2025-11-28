#!/bin/bash

# Whistle SwiftBar Plugin Configuration
# Copy this file to config.sh and customize for your setup

# Whistle server host (default: 127.0.0.1 for local, or use LAN IP for remote)
WHISTLE_HOST="127.0.0.1"

# Whistle server port (default: 8899)
WHISTLE_PORT="8899"

# Menu bar icon (emoji or text)
# Examples: 🔧 🌐 🔌 ⚡ 🛠 W
MENU_BAR_ICON="🔧"

# Auto refresh interval (seconds)
# This is controlled by the script filename (e.g., whistle.30s.sh for 30 seconds)
# Set to "true" to enable auto-refresh, "false" to disable
AUTO_REFRESH="true"

# Show desktop notifications when toggling rules
# Set to "true" to enable, "false" to disable
SHOW_NOTIFICATIONS="true"

# Maximum number of rules to display in menu
# Set to 0 for unlimited
MAX_RULES_DISPLAY=20

# Show rule values in menu (can be lengthy)
# Set to "true" to show, "false" to hide
SHOW_RULE_VALUES="false"

# Connection timeout (seconds)
CONNECTION_TIMEOUT=5

