# Create directory structure
mkdir -p ~/.local/share/tmux/resurrect

# Copy all resurrect files
cp -r /home/sriram/.config/i3/tmux-resurrect-backup/* /home/sriram/.local/share/tmux/resurrect/

# Ensure proper symlink
cd /home/sriram/.local/share/tmux/resurrect/
ln -sf tmux_resurrect_20250927T073411.txt last

# Restore zsh history
cp /home/sriram/.config/i3/my_zsh_history /home/sriram/.zsh_history
