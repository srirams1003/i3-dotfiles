#!/bin/bash

# Toggle mute state for the default sink
pactl set-sink-mute @DEFAULT_SINK@ toggle

# Check the current mute status
is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o "yes")

# Send notification based on the mute status
if [ "$is_muted" == "yes" ]; then
    notify-send -u low -h string:x-canonical-private-synchronous:volume "Muted"
else
    notify-send -u low -h string:x-canonical-private-synchronous:volume "Unmuted"
fi

# Refresh i3status (if necessary)
pkill -RTMIN+10 i3blocks

