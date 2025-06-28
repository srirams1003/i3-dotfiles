#!/bin/sh
# NOTE: this command sets the external monitor to be the primary, as set by the flag
xrandr --output eDP-1 --mode 1366x768 --pos 0x156 --rotate normal --output HDMI-1 --primary --mode 1920x1080 --rate 75 --pos 2718x0 --rotate normal
