#!/bin/sh
count=$(ip a | grep -E -c 'state (UP|UNKNOWN)')
if [ "$count" -gt 0 ]; then
    # Check if tun exists
    if ip a | grep -E 'ppp|tun' >/dev/null 2>&1; then
        # Extract the interface name (first three letters) and IP address of the interface
        interface=$(ip a | grep -E 'ppp|tun' -A 2 | awk '/^[0-9]+:/{print substr($2, 1, 3); exit}')
        ip_address=$(ip a | grep -E 'ppp|tun' -A 2 | awk '/inet /{print $2; exit}')
        # Print the interface name and its IP address
        printf '󰩠 %s %s:%s' "$count" "$interface" "$ip_address"
    else
        # Extract the interface name (first three letters) and IP address of the first interface with state UP
        interface=$(ip a | grep -A 2 'state UP' | awk '/^[0-9]+:/{print substr($2, 1, 3); exit}')
        ip_address=$(ip a | grep -A 2 'state UP' | awk '/inet /{print $2; exit}')
        # Print the interface name and its IP address
        printf '󰩠 %s %s:%s' "$count" "$interface" "$ip_address"
    fi
else
    printf '󰩠 %s' "$count"
fi
