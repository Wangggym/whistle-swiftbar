#!/bin/bash

# <xbar.title>Whistle Rules Manager</xbar.title>
# <xbar.version>v1.0.0</xbar.version>
# <xbar.author>Whistle SwiftBar</xbar.author>
# <xbar.author.github>your-github-username</xbar.author.github>
# <xbar.desc>Manage and toggle Whistle proxy rules from the menu bar</xbar.desc>
# <xbar.image>https://raw.githubusercontent.com/your-username/whistle-swiftbar/main/screenshots/menu.png</xbar.image>
# <xbar.dependencies>bash,curl</xbar.dependencies>
# <xbar.abouturl>https://github.com/your-username/whistle-swiftbar</xbar.abouturl>

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load configuration
CONFIG_FILE="${SCRIPT_DIR}/config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Use default configuration if config.sh doesn't exist
    WHISTLE_HOST="${WHISTLE_HOST:-127.0.0.1}"
    WHISTLE_PORT="${WHISTLE_PORT:-8899}"
    MENU_BAR_ICON="${MENU_BAR_ICON:-🔧}"
    SHOW_NOTIFICATIONS="${SHOW_NOTIFICATIONS:-true}"
    MAX_RULES_DISPLAY="${MAX_RULES_DISPLAY:-20}"
    SHOW_RULE_VALUES="${SHOW_RULE_VALUES:-false}"
fi

# Build base URL
BASE_URL="http://${WHISTLE_HOST}:${WHISTLE_PORT}"

# Load utility functions
source "${SCRIPT_DIR}/utils/whistle-api.sh"
source "${SCRIPT_DIR}/utils/notifier.sh"

# Handle toggle action
if [ "$1" = "toggle" ]; then
    RULE_NAME="$2"
    
    # Get client ID
    CLIENT_ID=$(get_client_id "$BASE_URL")
    
    if [ -z "$CLIENT_ID" ]; then
        if [ "$SHOW_NOTIFICATIONS" = "true" ]; then
            show_error "Cannot connect to Whistle"
        fi
        exit 1
    fi
    
    # Get rules list
    RULES_DATA=$(get_rules_list "$BASE_URL")
    
    if [ -z "$RULES_DATA" ]; then
        if [ "$SHOW_NOTIFICATIONS" = "true" ]; then
            show_error "Failed to get rules list"
        fi
        exit 1
    fi
    
    # Parse and find the rule
    FOUND=false
    while IFS='|' read -r name selected value key; do
        if [ "$name" = "$RULE_NAME" ]; then
            FOUND=true
            
            # Toggle the rule
            if toggle_rule "$BASE_URL" "$CLIENT_ID" "$name" "$selected" "$value" "$key"; then
                if [ "$SHOW_NOTIFICATIONS" = "true" ]; then
                    if [ "$selected" = "true" ]; then
                        show_rule_toggle_notification "$name" "false"
                    else
                        show_rule_toggle_notification "$name" "true"
                    fi
                fi
            else
                if [ "$SHOW_NOTIFICATIONS" = "true" ]; then
                    show_error "Failed to toggle rule: $name"
                fi
                exit 1
            fi
            break
        fi
    done < <(parse_rules "$RULES_DATA")
    
    if [ "$FOUND" = false ]; then
        if [ "$SHOW_NOTIFICATIONS" = "true" ]; then
            show_error "Rule not found: $RULE_NAME"
        fi
        exit 1
    fi
    
    exit 0
fi

# Handle open web UI action
if [ "$1" = "open" ]; then
    open "$BASE_URL"
    exit 0
fi

# Display menu bar content
echo "$MENU_BAR_ICON"
echo "---"

# Check if Whistle is accessible
if ! check_whistle_connection "$BASE_URL"; then
    echo "❌ Whistle not connected"
    echo "---"
    echo "Host: $WHISTLE_HOST:$WHISTLE_PORT"
    echo "---"
    echo "⚙️ Edit Config | bash='$0' param1=edit-config terminal=false"
    echo "🔄 Refresh | refresh=true"
    exit 0
fi

# Get rules list
RULES_DATA=$(get_rules_list "$BASE_URL")

if [ -z "$RULES_DATA" ]; then
    echo "❌ Failed to get rules"
    echo "---"
    echo "🔄 Refresh | refresh=true"
    exit 0
fi

# Count and display rules
RULE_COUNT=0
ENABLED_COUNT=0

while IFS='|' read -r name selected value key; do
    ((RULE_COUNT++))
    
    # Check max display limit
    if [ "$MAX_RULES_DISPLAY" -gt 0 ] && [ "$RULE_COUNT" -gt "$MAX_RULES_DISPLAY" ]; then
        echo "... ($(($RULE_COUNT - $MAX_RULES_DISPLAY)) more rules not shown)"
        break
    fi
    
    # Display rule with appropriate icon
    if [ "$selected" = "true" ]; then
        echo "✓ $name | bash='$0' param1=toggle param2='$name' terminal=false refresh=true"
        ((ENABLED_COUNT++))
    else
        echo "○ $name | bash='$0' param1=toggle param2='$name' terminal=false refresh=true"
    fi
    
    # Optionally show rule value as submenu
    if [ "$SHOW_RULE_VALUES" = "true" ] && [ -n "$value" ]; then
        # Decode and display first 100 chars of rule value
        DISPLAY_VALUE=$(echo "$value" | cut -c1-100)
        echo "--$DISPLAY_VALUE | size=10 color=#666666"
    fi
done < <(parse_rules "$RULES_DATA")

# Show summary if no rules displayed yet
if [ "$RULE_COUNT" -eq 0 ]; then
    echo "No rules found"
fi

# Menu footer
echo "---"
echo "📊 $ENABLED_COUNT/$RULE_COUNT rules enabled | size=12 color=#666666"
echo "---"
echo "🔄 Refresh | refresh=true"
echo "🌐 Open Whistle Web UI | bash='$0' param1=open terminal=false"
echo "⚙️ Settings"
echo "--Host: $WHISTLE_HOST:$WHISTLE_PORT | size=12"
echo "--Edit Config | bash='open' param1='$CONFIG_FILE' terminal=false"
echo "--Copy Config Example | bash='cp' param1='${SCRIPT_DIR}/config.example.sh' param2='$CONFIG_FILE' terminal=false refresh=true"

