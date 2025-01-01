#!/usr/bin/env python3
import subprocess

# Define colors for the status
COLOR_ON = "#00FF00"  # Green
COLOR_OFF = "#FF0000"  # Red
COLOR_TAMU = "#8A1202" # Maroon
COLOR_SURF = "#05F8FC" # Surfshark

result = subprocess.run(['nmcli -t -f TYPE,NAME connection show --active'], 
                        stdout=subprocess.PIPE, 
                        text=True, 
                        shell=True)

output_lines = result.stdout.strip().split('\n')
res = ""
if output_lines:
    for l in output_lines:
        if 'cscotun0' in l:
            res = "TAMU"
        elif 'surfshark' in l:
            res = "Surfshark"


# Path to your iface script
iface_script = f"{subprocess.getoutput('echo $HOME')}/.config/i3/i3blocks-contrib/iface/iface"

try:
    # Run the iface script and capture its output
    result = subprocess.run([iface_script], stdout=subprocess.PIPE, text=True, shell=True)
    iface_output = result.stdout.strip()
    
    if iface_output and len(iface_output) > 3:
        if res == "Surfshark":
            # Ethernet is connected
            print("󱙳 Aargh!")           # Full Text
            print("󱙳 Aargh!")           # Short Text??
            print(COLOR_SURF)     
        else:
            # Ethernet is connected
            print("󰈀 ON")           # Short/Full Text
            print("󰈀 ON")           # Full Text
            print(COLOR_ON)      

    else:
        if res == "TAMU":
            # Ethernet is disconnected
            print("󰖂 TAMU")          # Short/Full Text
            print("󰖂 TAMU")          # Full Text
            print(COLOR_TAMU)    
        else:
            # Ethernet is disconnected
            print("󰈀 OFF")          # Short/Full Text
            print("󰈀 OFF")          # Full Text
            print(COLOR_OFF)    
except Exception as e:
    # Handle errors gracefully
    print("ERROR")
    print("ERROR")
    print("#FF0000")  # Red color for errors
