#!/bin/bash

# Get current volume as a percentage
current=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)

# Calculate the new volume
step=5
new=$((current + step))

# # Ensure volume does not exceed 100%
# if [ "$new" -gt 100 ]; then
#     new=100
# fi

# Set the new volume
pactl set-sink-volume @DEFAULT_SINK@ "$new%" && pkill -RTMIN+10 i3blocks

notify-send -u low -h string:x-canonical-private-synchronous:volume "Volume: ${new}%"
