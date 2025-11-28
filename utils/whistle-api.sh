#!/bin/bash

# Whistle API wrapper functions
# Provides functions for interacting with Whistle HTTP API

# Get Whistle client ID
# Returns: clientId string
get_client_id() {
    local base_url="$1"
    local timestamp=$(date +%s)000
    local response=$(curl -s -m 5 "${base_url}/cgi-bin/init?_=${timestamp}" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        echo ""
        return 1
    fi
    
    # Extract clientId from JSON response
    local client_id=$(echo "$response" | grep -o '"clientId":"[^"]*"' | cut -d'"' -f4)
    echo "$client_id"
}

# Get list of all rules
# Returns: JSON response with rules list
get_rules_list() {
    local base_url="$1"
    local response=$(curl -s -m 5 "${base_url}/cgi-bin/rules/list" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        echo ""
        return 1
    fi
    
    echo "$response"
}

# Parse rules from JSON and output formatted data
# Format: name|selected|data|index
parse_rules() {
    local rules_json="$1"
    
    # Extract each rule object from the list array
    echo "$rules_json" | grep -o '{"index":[0-9]*,"name":"[^"]*","data":"[^"]*","selected":[^}]*}' | while IFS= read -r line; do
        local name=$(echo "$line" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
        local selected=$(echo "$line" | grep -o '"selected":[^,}]*' | cut -d':' -f2)
        local data=$(echo "$line" | grep -o '"data":"[^"]*"' | head -1 | cut -d'"' -f4)
        local index=$(echo "$line" | grep -o '"index":[0-9]*' | cut -d':' -f2)
        
        # Use index as key for API calls
        echo "${name}|${selected}|${data}|${index}"
    done
}

# Toggle rule (enable/disable)
# Args: base_url, client_id, rule_name, current_selected, rule_data, rule_index
toggle_rule() {
    local base_url="$1"
    local client_id="$2"
    local rule_name="$3"
    local current_selected="$4"
    local rule_data="$5"
    local rule_index="$6"
    
    # Determine action based on current state
    local action
    if [ "$current_selected" = "true" ]; then
        action="unselect"
    else
        action="select"
    fi
    
    # URL encode the rule data
    local encoded_data=$(echo -n "$rule_data" | jq -sRr @uri 2>/dev/null || echo -n "$rule_data" | sed 's/%/%25/g' | sed 's/ /%20/g' | sed 's/!/%21/g' | sed 's/"/%22/g' | sed 's/#/%23/g' | sed 's/\$/%24/g' | sed 's/&/%26/g' | sed "s/'/%27/g" | sed 's/(/%28/g' | sed 's/)/%29/g' | sed 's/\*/%2A/g' | sed 's/+/%2B/g' | sed 's/,/%2C/g' | sed 's/\//%2F/g' | sed 's/:/%3A/g' | sed 's/;/%3B/g' | sed 's/=/%3D/g' | sed 's/?/%3F/g' | sed 's/@/%40/g' | sed 's/\[/%5B/g' | sed 's/\\/%5C/g' | sed 's/\]/%5D/g' | sed 's/\^/%5E/g')
    
    # Build request body (use 'value' in request even though response has 'data')
    local request_data="clientId=${client_id}&name=${rule_name}&value=${encoded_data}&selected=${current_selected}&active=true&key=w-reactkey-${rule_index}&icon=checkbox"
    
    # Execute API call with timeout
    local response=$(curl -s -m 10 -X POST "${base_url}/cgi-bin/rules/${action}" \
        -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
        -d "${request_data}" 2>/dev/null)
    
    # Check if response contains success indicator
    if echo "$response" | grep -q '"ec":0'; then
        return 0
    else
        return 1
    fi
}

# Enable specific rule
# Args: base_url, client_id, rule_name, rule_data, rule_index
enable_rule() {
    local base_url="$1"
    local client_id="$2"
    local rule_name="$3"
    local rule_data="$4"
    local rule_index="$5"
    
    # URL encode the rule data
    local encoded_data=$(echo -n "$rule_data" | jq -sRr @uri 2>/dev/null || echo -n "$rule_data")
    
    # Build request body
    local data="clientId=${client_id}&name=${rule_name}&value=${encoded_data}&selected=false&active=true&key=w-reactkey-${rule_index}&icon=checkbox"
    
    # Execute API call with timeout
    local response=$(curl -s -m 10 -X POST "${base_url}/cgi-bin/rules/select" \
        -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
        -d "${data}" 2>/dev/null)
    
    if echo "$response" | grep -q '"ec":0'; then
        return 0
    else
        return 1
    fi
}

# Disable specific rule
# Args: base_url, client_id, rule_name, rule_data, rule_index
disable_rule() {
    local base_url="$1"
    local client_id="$2"
    local rule_name="$3"
    local rule_data="$4"
    local rule_index="$5"
    
    # URL encode the rule data
    local encoded_data=$(echo -n "$rule_data" | jq -sRr @uri 2>/dev/null || echo -n "$rule_data")
    
    # Build request body
    local data="clientId=${client_id}&name=${rule_name}&value=${encoded_data}&selected=true&active=true&key=w-reactkey-${rule_index}&icon=checkbox"
    
    # Execute API call with timeout
    local response=$(curl -s -m 10 -X POST "${base_url}/cgi-bin/rules/unselect" \
        -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
        -d "${data}" 2>/dev/null)
    
    if echo "$response" | grep -q '"ec":0'; then
        return 0
    else
        return 1
    fi
}

# Check if Whistle is accessible
# Args: base_url
# Returns: 0 if accessible, 1 if not
check_whistle_connection() {
    local base_url="$1"
    local response=$(curl -s -m 3 -o /dev/null -w "%{http_code}" "${base_url}/" 2>/dev/null)
    
    if [ "$response" = "200" ] || [ "$response" = "302" ]; then
        return 0
    else
        return 1
    fi
}

