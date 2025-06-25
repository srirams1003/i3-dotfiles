#!/bin/bash

chosen=$(echo -e " Lock\n Logout\n Suspend\n Reboot\n Shutdown" | rofi -dmenu -i -p "Power" -theme "/usr/share/rofi/themes/Adapta-Nokto.rasi")

case "$chosen" in
    " Lock") loginctl lock-session ;;
    " Logout") i3-msg exit ;;
    " Suspend") systemctl suspend ;;
    " Reboot") systemctl reboot ;;
    " Shutdown") systemctl poweroff ;;
esac

