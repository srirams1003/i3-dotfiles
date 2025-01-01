#!/usr/bin/env python3
import subprocess

# Define colors for the status
COLOR_ON = "#00FF00"  # Green
COLOR_OFF = "#FF0000"  # Red

# Path to your iface script
iface_script = f"{subprocess.getoutput('echo $HOME')}/.config/i3/i3blocks-contrib/iface/iface"

try:
    # Run the iface script and capture its output
    result = subprocess.run([iface_script], stdout=subprocess.PIPE, text=True, shell=True)
    iface_output = result.stdout.strip()
    
    if iface_output and len(iface_output) > 3:
        # Ethernet is connected
        print("ON")           # Short/Full Text
        print("ON")           # Full Text
        print(COLOR_ON)       # Green Color
    else:
        # Ethernet is disconnected
        print("OFF")          # Short/Full Text
        print("OFF")          # Full Text
        print(COLOR_OFF)      # Red Color
except Exception as e:
    # Handle errors gracefully
    print("ERROR")
    print("ERROR")
    print("#FF0000")  # Red color for errors
