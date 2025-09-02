# # #!/bin/bash
# # maim --format=png --select "/tmp/myverytemporarypicture.png" && 
# # tesseract /tmp/myverytemporarypicture.png /tmp/myverytemporaryoutput && 
# # word=$(cat /tmp/myverytemporaryoutput.txt) &&
# # dict "$word" | zenity --text-info --title="Dictionary Definition" --width=1920 --height=1080
#
# #!/bin/bash
# maim --format=png --select "/tmp/myverytemporarypicture.png" && 
# tesseract /tmp/myverytemporarypicture.png /tmp/myverytemporaryoutput && 
# word=$(cat /tmp/myverytemporaryoutput.txt) &&
# goldendict "$word"
#

#!/bin/bash

# Take a screenshot of a selected area
maim --format=png --select "/tmp/myverytemporarypicture.png" && \

# Run OCR on the screenshot
tesseract /tmp/myverytemporarypicture.png /tmp/myverytemporaryoutput && \

# Read the recognized text
word=$(cat /tmp/myverytemporaryoutput.txt) && \

# Open a new Firefox window with Google search
firefox --new-window "https://www.google.com/search?q=$(echo "$word" | sed 's/ /+/g')" &

