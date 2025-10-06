# Backup current tmux resurrect state
BACKUP_DIR="/home/sriram/.config/i3/tmux-resurrect-backup"
SOURCE_DIR="/home/sriram/.local/share/tmux/resurrect"
mkdir -p "$BACKUP_DIR"
rm -f "$BACKUP_DIR"/*.txt
cp "$SOURCE_DIR"/*.txt "$BACKUP_DIR/"
cd "$BACKUP_DIR" && latest_file=$(ls -t tmux_resurrect_*.txt | head -n1) && ln -sf "$latest_file" last

# Backup zsh history
cp /home/sriram/.zsh_history /home/sriram/.config/i3/my_zsh_history

