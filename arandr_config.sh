#!/bin/sh
# NOTE: this command sets the external monitor to be the primary, as set by the flag
xrandr --output eDP --mode 1440x900 --pos 0x0 --rotate normal --output DisplayPort-3 --primary --mode 1920x1080 --rate 75 --pos 1568x0 --rotate normal

