#!/bin/bash

# Notification utility functions for macOS
# Provides functions for displaying notifications and alerts

# Show macOS notification
# Args: title, message, [subtitle]
show_notification() {
    local title="$1"
    local message="$2"
    local subtitle="${3:-}"
    
    if [ -z "$subtitle" ]; then
        osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null
    else
        osascript -e "display notification \"$message\" with title \"$title\" subtitle \"$subtitle\"" 2>/dev/null
    fi
}

# Show alert dialog
# Args: title, message
show_alert() {
    local title="$1"
    local message="$2"
    
    osascript -e "display alert \"$title\" message \"$message\"" 2>/dev/null
}

# Show error notification
# Args: message
show_error() {
    local message="$1"
    show_notification "Whistle Error" "$message"
}

# Show success notification
# Args: message
show_success() {
    local message="$1"
    show_notification "Whistle" "$message"
}

# Show rule toggle notification
# Args: rule_name, enabled (true/false)
show_rule_toggle_notification() {
    local rule_name="$1"
    local enabled="$2"
    
    if [ "$enabled" = "true" ]; then
        show_notification "Whistle" "Enabled: $rule_name" "✓"
    else
        show_notification "Whistle" "Disabled: $rule_name" "○"
    fi
}

