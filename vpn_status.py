import subprocess

result = subprocess.run(['nmcli -t -f TYPE,NAME connection show --active'], 
                        stdout=subprocess.PIPE, 
                        text=True, 
                        shell=True)

output_lines = result.stdout.strip().split('\n')
if output_lines:
    res = ""
    for l in output_lines:
        if 'cscotun0' in l:
            res = "󰖂"
        elif 'surfshark' in l:
            res = "󱙳"

    print(res)
