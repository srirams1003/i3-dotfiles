# Create directory structure
mkdir -p ~/.local/share/tmux/resurrect

# Copy all resurrect files
cp -r /home/sriram/.config/i3/tmux-resurrect-backup/* /home/sriram/.local/share/tmux/resurrect/

# Ensure proper symlink (dynamic)
cd /home/sriram/.local/share/tmux/resurrect/
latest_file=$(ls -t tmux_resurrect_*.txt | head -n1)
ln -sf "$latest_file" last

# Restore zsh history
cp /home/sriram/.config/i3/my_zsh_history /home/sriram/.zsh_history

# Restore Firefox profile
pkill firefox
rm -rf ~/.mozilla/firefox
cp -r /home/sriram/.config/i3/firefox-backup/* ~/.mozilla/firefox/
chown -R $USER:$USER ~/.mozilla/firefox
