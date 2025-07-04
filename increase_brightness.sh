#!/bin/bash

# output="DP-1"  # Replace this with your monitor name (use `xrandr` to find it)
output="HDMI-1"  # Replace this with your monitor name (use `xrandr` to find it)
step=0.1       # Step size for brightness adjustment

current=$(xrandr --verbose | grep -m 1 -i brightness | awk '{print $2}')
new=$(echo "$current + $step" | bc)

# Ensure brightness doesn't exceed 1.0
if (( $(echo "$new > 1.0" | bc -l) )); then
    new=1.0
fi

xrandr --output "$output" --brightness "$new"

# Show notification with the new brightness level
brightness_percent=$(echo "$new * 100" | bc | awk '{printf "%.0f", $1}')
notify-send -u low -h string:x-canonical-private-synchronous:brightness "Brightness: ${brightness_percent}%"
