#!/bin/bash
MYDIR="$(dirname "$(readlink -f "$0")")"
PASSWORD="DEFAULT_EMPTY_VALUE"
TRAP_ENABLED=false

cleanup() {
    if $TRAP_ENABLED; then
        echo "Performing cleanup..."
        
        # Stop SSH and kill connections
        if systemctl is-active --quiet sshd; then
            echo "Terminating SSH connections..."
            if $HASPASSWORD; then
                echo "$PASSWORD" | sudo -S pkill -9 sshd 2>/dev/null
                echo "$PASSWORD" | sudo -S systemctl stop sshd 2>/dev/null
            else
                sudo pkill -9 sshd 2>/dev/null
                sudo systemctl stop sshd 2>/dev/null
            fi
        fi

        # Restore sleep settings
        echo "Restoring sleep mode..."
        if $HASPASSWORD; then
            echo "$PASSWORD" | sudo -S systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target 2>/dev/null
        else
            sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target 2>/dev/null
        fi

        # Verify result
        if pgrep -x "sshd" >/dev/null; then
            zenity --error --title="Error" --text="Failed to stop SSH connections!" --timeout=3 2>/dev/null
        else
            zenity --info --title="Status" --text="All SSH connections terminated" --timeout=3 2>/dev/null
        fi
    fi
    exit 0
}

trap cleanup EXIT INT TERM HUP

# Get IP addresses (exclude localhost)
ip4=$(/sbin/ip -o -4 addr show | awk '{print $4}' | cut -d/ -f1 | grep -v '^127\.0\.0\.1$' | sort -u | tr '\n' ' ')
ip6=$(/sbin/ip -o -6 addr show | awk '{print $4}' | cut -d/ -f1 | grep -v '^::1$' | sort -u | tr '\n' ' ')

# Check sudo password requirement
if sudo -n true 2>/dev/null; then
    HASPASSWORD=false
else
    HASPASSWORD=true
fi

# Request password if needed
if $HASPASSWORD && [ "$PASSWORD" == "DEFAULT_EMPTY_VALUE" ]; then
    while true; do
        PASSWORD=$(zenity --password --title="sudo Password" --text="Enter your sudo password:")
        if [[ -z "$PASSWORD" ]]; then
            zenity --error --text="Password cannot be empty!"
            exit 1
        fi
        
        # Validate password
        if ! echo "$PASSWORD" | sudo -S true 2>/dev/null; then
            zenity --error --text="Wrong password!"
            continue
        fi
        break
    done
fi

# Start SSH and disable sleep
echo "Starting SSH server..."
if $HASPASSWORD; then
    echo "$PASSWORD" | sudo -S systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target >/dev/null
    echo "$PASSWORD" | sudo -S systemctl start sshd >/dev/null
else
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target >/dev/null
    sudo systemctl start sshd >/dev/null
fi

# Wait for SSH startup
TIMEOUT=10
while ! pgrep -x "sshd" >/dev/null && [ $TIMEOUT -gt 0 ]; do
    sleep 0.5
    ((TIMEOUT--))
done

if [ $TIMEOUT -eq 0 ]; then
    zenity --error --title="Error" --text="Failed to start SSH server!"
    exit 1
fi

TRAP_ENABLED=true

# Show connection info
message=$(printf "SSH server is running. Sleep mode disabled.\n\nIPv4 addresses: %s\nIPv6 addresses: %s\n\nPort: 22\nUsername: sdcard or deck\n\nClose window to stop SSH" "$ip4" "$ip6")
zenity --info --title="SSH Server Status" --text="$message" --no-wrap --ok-label="Stop SSH"

cleanup
