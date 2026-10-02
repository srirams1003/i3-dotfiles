# Create directory structure
mkdir -p ~/.local/share/tmux/resurrect

# Copy all resurrect files
cp -r /home/sriram/.config/i3/tmux-resurrect-backup/* /home/sriram/.local/share/tmux/resurrect/

# Ensure proper symlink
cd /home/sriram/.local/share/tmux/resurrect/
ln -sf tmux_resurrect_20250927T073411.txt last


# Enable the hourly backup timer (tmux session state + zsh history)
mkdir -p ~/.config/systemd/user
ln -sf ~/.config/i3/systemd-user/backup-dotfiles.service ~/.config/systemd/user/
ln -sf ~/.config/i3/systemd-user/backup-dotfiles.timer   ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now backup-dotfiles.timer
