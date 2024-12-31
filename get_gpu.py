import subprocess

# Run the command and capture the output
result = subprocess.run(['~/.config/i3/i3blocks-contrib/gpu-load/gpu-load'], 
                        stdout=subprocess.PIPE, 
                        text=True, 
                        shell=True)

# Split the output into lines and process the first line
output_lines = result.stdout.strip().split('\n')
if output_lines:
    # Extract the first number (used RAM)
    # print(output_lines[0][:40])
    # print(output_lines[0].split())
    res = output_lines[0].split()
    print(res[0], res[1])
    # print(output_lines[0].split('/')[0])
    # used_ram = output_lines[0].split()[0]
    # print("Used RAM:", used_ram)

