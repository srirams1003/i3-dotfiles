#!/bin/bash
selected_text=$(xclip -o -selection primary)
dict "$selected_text" | zenity --text-info --title="Dictionary Definition" --width=1920 --height=1080
