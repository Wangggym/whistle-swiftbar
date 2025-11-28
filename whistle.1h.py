#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# <xbar.title>Whistle Rules Manager</xbar.title>
# <xbar.version>v1.1.0</xbar.version>
# <xbar.author>Whistle SwiftBar</xbar.author>
# <xbar.desc>Manage and toggle Whistle proxy rules from the menu bar</xbar.desc>
# <xbar.dependencies>python3</xbar.dependencies>

import sys
import json
import urllib.request
import urllib.parse
import subprocess
import os
from pathlib import Path

# Configuration
WHISTLE_HOST = "127.0.0.1"
WHISTLE_PORT = "8899"
MENU_BAR_ICON = "🔧"
SHOW_NOTIFICATIONS = True
MAX_RULES_DISPLAY = 20

BASE_URL = f"http://{WHISTLE_HOST}:{WHISTLE_PORT}"
TIMEOUT = 2  # 2 seconds timeout


def show_notification(title, message):
    """Show macOS notification"""
    if SHOW_NOTIFICATIONS:
        try:
            subprocess.run(
                ['osascript', '-e', f'display notification "{message}" with title "{title}"'],
                timeout=1,
                capture_output=True
            )
        except:
            pass


def api_call(endpoint, method='GET', data=None):
    """Make API call to Whistle"""
    try:
        url = f"{BASE_URL}{endpoint}"
        
        if method == 'POST' and data:
            # Use quote instead of quote_plus to preserve spaces as %20, not +
            # This prevents whistle rules from being corrupted
            data_encoded = urllib.parse.urlencode(data, quote_via=urllib.parse.quote).encode('utf-8')
            req = urllib.request.Request(url, data=data_encoded, method='POST')
            req.add_header('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
        else:
            req = urllib.request.Request(url)
        
        with urllib.request.urlopen(req, timeout=TIMEOUT) as response:
            return json.loads(response.read().decode('utf-8'))
    except Exception as e:
        return None


def get_client_id():
    """Get Whistle client ID"""
    import time
    timestamp = int(time.time() * 1000)
    result = api_call(f"/cgi-bin/init?_={timestamp}")
    return result.get('clientId') if result else None


def get_rules_list():
    """Get all rules"""
    import time
    timestamp = int(time.time() * 1000)
    result = api_call(f"/cgi-bin/rules/list?_={timestamp}")
    return result.get('list', []) if result else []


def toggle_rule(rule_name):
    """Toggle a rule"""
    show_notification("Whistle", f"Toggling {rule_name}...")
    
    client_id = get_client_id()
    if not client_id:
        show_notification("Whistle Error", "Cannot connect to Whistle")
        return False
    
    rules = get_rules_list()
    rule = next((r for r in rules if r['name'] == rule_name), None)
    
    if not rule:
        show_notification("Whistle Error", f"Rule not found: {rule_name}")
        return False
    
    action = 'unselect' if rule['selected'] else 'select'
    
    data = {
        'clientId': client_id,
        'name': rule['name'],
        'value': rule.get('data', ''),
        'selected': str(rule['selected']).lower(),
        'active': 'true',
        'key': f"w-reactkey-{rule['index']}",
        'icon': 'checkbox'
    }
    
    result = api_call(f"/cgi-bin/rules/{action}", method='POST', data=data)
    
    if result and result.get('ec') == 0:
        new_state = "Disabled" if rule['selected'] else "Enabled"
        show_notification("Whistle", f"{new_state}: {rule_name}")
        
        # Trigger refresh
        subprocess.run(['open', 'swiftbar://refreshallplugins'], 
                      capture_output=True, timeout=1)
        return True
    else:
        show_notification("Whistle Error", f"Failed to toggle: {rule_name}")
        return False


def display_menu():
    """Display SwiftBar menu"""
    print(MENU_BAR_ICON)
    print("---")
    
    # Get rules (this also checks connection)
    rules = get_rules_list()
    
    if rules is None:
        print("❌ Whistle not connected")
        print("---")
        print(f"Host: {WHISTLE_HOST}:{WHISTLE_PORT}")
        print("---")
        print("🔄 Refresh | refresh=true")
        return
    
    if not rules:
        print("No rules found")
        print("---")
        print("🔄 Refresh | refresh=true")
        return
    
    # Display rules
    enabled_count = 0
    for i, rule in enumerate(rules[:MAX_RULES_DISPLAY]):
        icon = "✓" if rule['selected'] else "○"
        script_path = os.path.abspath(__file__)
        print(f"{icon} {rule['name']} | bash='{sys.executable}' param1='{script_path}' param2=toggle param3='{rule['name']}' terminal=false refresh=true")
        
        if rule['selected']:
            enabled_count += 1
    
    if len(rules) > MAX_RULES_DISPLAY:
        print(f"... ({len(rules) - MAX_RULES_DISPLAY} more rules not shown)")
    
    # Footer
    print("---")
    print(f"📊 {enabled_count}/{len(rules)} rules enabled | size=12 color=#666666")
    print("---")
    print("🔄 Refresh | refresh=true")
    print(f"🌐 Open Whistle Web UI | href={BASE_URL}")


def main():
    if len(sys.argv) > 1:
        action = sys.argv[1]
        
        if action == "toggle" and len(sys.argv) > 2:
            rule_name = sys.argv[2]
            toggle_rule(rule_name)
        else:
            display_menu()
    else:
        display_menu()


if __name__ == "__main__":
    main()

