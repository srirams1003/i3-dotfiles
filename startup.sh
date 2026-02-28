#!/bin/bash

sleep 3

xrandr --output HDMI-A-0 --auto --mode 1920x1080 --rate 180 --brightness 0.5

setxkbmap -option caps:swapescape
i3-msg restart


# TODO: reinstate this code block when needed
# # Open PDF documents in background
# flatpak run org.kde.okular ~/Documents/books/stm32f4_HAL_manual.pdf &
# sleep 1
# flatpak run org.kde.okular ~/Documents/books/stm32f446re_reference_manual.pdf &
# sleep 1
# flatpak run org.kde.okular ~/Documents/books/stm32f446re_datasheet.pdf &
