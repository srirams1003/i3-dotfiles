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

# Shell history (atuin) — replaces the old my_zsh_history copy
curl -sSL https://github.com/atuinsh/atuin/releases/latest/download/atuin-x86_64-unknown-linux-gnu.tar.gz \
  | tar xz -C /tmp && install -m755 $(find /tmp -name atuin -type f | head -1) ~/.local/bin/atuin
atuin import zsh                       # pick up anything already on this machine
~/.config/i3/scripts/atuin-migrate import <your-export>.db.gpg
