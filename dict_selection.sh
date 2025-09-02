# # #!/bin/bash
# # selected_text=$(xclip -o -selection primary)
# # dict "$selected_text" | zenity --text-info --title="Dictionary Definition" --width=1920 --height=1080
#
# #!/bin/bash
# selected_text=$(xclip -o -selection primary)
# goldendict "$selected_text"

#!/bin/bash

# Get the highlighted text (from PRIMARY selection)
selected_text=$(xclip -o -selection primary)

# Launch Firefox with the search query
firefox --new-window "https://www.google.com/search?q=$(echo "$selected_text" | sed 's/ /+/g')" &

