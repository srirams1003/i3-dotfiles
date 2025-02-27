#!/bin/bash
maim --format=png --select "/tmp/myverytemporarypicture.png" && 
tesseract /tmp/myverytemporarypicture.png /tmp/myverytemporaryoutput && 
word=$(cat /tmp/myverytemporaryoutput.txt) &&
dict "$word" | zenity --text-info --title="Dictionary Definition" --width=1920 --height=1080
