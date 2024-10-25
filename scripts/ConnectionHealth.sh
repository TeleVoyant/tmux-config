#!/bin/sh
# icon status
script_init="󰔌"
connection_changed="󱘖"
connection_healthy=""
connection_unhealthy="󰇨"

# Delay between checks in seconds (60 seconds = 1 minute)
DELAY=120

# Path to the file that stores both the timestamp and connection status
STATUS_FILE="/tmp/ConnectionHealth.cache"

# connection health checker
check_connection_health() {
    # Perform the connection health check (ping example)
    if ping -c 1 -s 0 -i 0.002 -W 1 google.com | grep -E "0% packet loss" >/dev/null 2>&1; then
        # update connection status
        sed -i "2s/.*/$connection_healthy/" "$STATUS_FILE"
    else
        # update connection status
        sed -i "2s/.*/$connection_unhealthy/" "$STATUS_FILE"
    fi
    # deactivate check now
    sed -i "4s/.*/0/" "$STATUS_FILE"
}

# Get the number of devices currently with state UP
COUNT=$(ip a | grep -E -c 'state (UP|UNKNOWN)')
# if file exists
if [ -f "$STATUS_FILE" ]; then
    LAST_COUNT=$(sed -n '3p' "$STATUS_FILE")
else
    LAST_COUNT=0
fi
# check for connection changes
if [ "$LAST_COUNT" -ne "$COUNT" ]; then
    CHECK_NOW=$(sed -n '4p' "$STATUS_FILE")
    # if check now is activated
    if [ "$CHECK_NOW" -eq 1 ]; then
        # trick timer to check now
        DELAY=0
        # update count
        sed -i "3s/.*/$COUNT/" "$STATUS_FILE"
    fi
    # if no connections available
    if [ "$COUNT" -eq 0 ]; then
        # update connection status
        sed -i "2s/.*/$connection_unhealthy/" "$STATUS_FILE"
    else
        # update connection status
        sed -i "2s/.*/$connection_changed/" "$STATUS_FILE"
        # activate check now
        sed -i "4s/.*/1/" "$STATUS_FILE"
    fi
fi

# Get the current time in seconds since the epoch
CURRENT_TIME=$(date +%s)

# If the status file exists, read the last check time (first line)
if [ -f "$STATUS_FILE" ]; then
    LAST_CHECK=$(sed -n '1p' "$STATUS_FILE")
else
    LAST_CHECK=0
fi

# If the time difference is greater than the delay, run the connection check
if [ $((CURRENT_TIME - LAST_CHECK)) -ge $DELAY ]; then
    # Perform the connection health check
    check_connection_health
    # Update current timestamp
    sed -i "1s/.*/$CURRENT_TIME/" "$STATUS_FILE"
fi

# Output the cached connection status without blocking line updates
if [ -f "$STATUS_FILE" ]; then
    # Read the status (second line of the file)
    sed -n '2p' "$STATUS_FILE"
else
    echo "$script_init" # Default status if the file doesn't exist
    # Store both the current timestamp and the status in the same file
    printf '%s\n%s\n%s\n%s' "0" "$script_init" "0" "1" >"$STATUS_FILE"
fi
