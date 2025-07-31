#!/bin/bash

sleep 3

# # NOTE: since I almost always use a single monitor setup, I run this block below to disable laptop internal display
# Check if external monitor is connected
if xrandr | grep "^DisplayPort-3 connected"; then
    # External monitor is connected
    xrandr --output eDP --off
	# xrandr --output DP-1 --auto --mode 1920x1080 --rate 75 --brightness 0.7
    xrandr --output DisplayPort-3 --auto --mode 1920x1080 --rate 75 --brightness 0.7
else
    # External monitor is not connected, enable laptop screen
    xrandr --output eDP --auto
fi


# nmcli device disconnect enxacde48001122 # disabling ethernet on startup
setxkbmap -option caps:swapescape
i3-msg restart

# bluetoothctl connect 08:EB:ED:4C:ED:1F # insignia mini sonic
bluetoothctl connect 08:EB:ED:D2:A8:E5 # insignia mini sonic (new MAC address?!)
# bluetoothctl connect 4C:FE:2E:28:70:72 # jvc ha-a3t
bluetoothctl connect E8:9E:13:09:D4:4D # wh-ch520

