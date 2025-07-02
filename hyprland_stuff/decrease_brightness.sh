#!/bin/bash

monitor=1          # DDC device number
step=10            # Step size for brightness decrease
min=0              # Minimum allowed brightness

# Get current and max brightness using -t (tab-separated)
read -r _ _ _ current max <<< "$(ddcutil -d "$monitor" getvcp 10 -t 2>/dev/null)"

# Fallback or error check
if [[ -z "$current" || -z "$max" ]]; then
    notify-send "Brightness" "Failed to read current brightness"
    exit 1
fi

# Calculate new brightness
new=$((current - step))
if [ "$new" -lt "$min" ]; then
    new=$min
fi

# Apply new brightness
ddcutil -d "$monitor" setvcp 10 "$new"

# Optional: Send notification
notify-send -u low -h string:x-canonical-private-synchronous:brightness "Brightness: ${new}%"
