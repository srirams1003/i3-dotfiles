# Create directory structure
mkdir -p ~/.local/share/tmux/resurrect

# Copy the backed-up state (last.txt + the claude-session -> tmux-pane map)
cp -r /home/sriram/.config/i3/tmux-resurrect-backup/* /home/sriram/.local/share/tmux/resurrect/

cd /home/sriram/.local/share/tmux/resurrect/

# The repo stores one snapshot under a stable name. tmux-resurrect expects a
# timestamped file plus a `last` symlink, so rehydrate that shape here.
if [ -f last.txt ]; then
	stamp="tmux_resurrect_$(date +%Y%m%dT%H%M%S).txt"
	cp -p last.txt "$stamp"
	rm -f last.txt
	ln -sf "$stamp" last
else
	# Backups taken before the stable-name change carry timestamped files.
	latest_file=$(ls -1 tmux_resurrect_*.txt 2>/dev/null | sort | tail -n1)
	[ -n "$latest_file" ] && ln -sf "$latest_file" last
fi

# Restore zsh history
cp /home/sriram/.config/i3/my_zsh_history /home/sriram/.zsh_history
