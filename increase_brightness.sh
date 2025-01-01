#!/bin/bash

output="DP-1"  # Replace this with your monitor name (use `xrandr` to find it)
step=0.1       # Step size for brightness adjustment

current=$(xrandr --verbose | grep -m 1 -i brightness | awk '{print $2}')
new=$(echo "$current + $step" | bc)

# Ensure brightness doesn't exceed 1.0
if (( $(echo "$new > 1.0" | bc -l) )); then
    new=1.0
fi

xrandr --output "$output" --brightness "$new"

