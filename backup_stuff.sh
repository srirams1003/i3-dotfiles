# Backup current tmux resurrect state
BACKUP_DIR="/home/sriram/.config/i3/tmux-resurrect-backup"
SOURCE_DIR="/home/sriram/.local/share/tmux/resurrect"
mkdir -p "$BACKUP_DIR"

# Back up exactly ONE snapshot, under a stable name.
#
# A reinstall only ever restores the latest layout, and tmux-resurrect already
# keeps its own 5-copy/30-day window in SOURCE_DIR for local rollback. Copying
# timestamped files here meant the tracked set shifted on every run — with this
# script on an hourly timer that left the repo permanently dirty, which is how
# the old version accumulated 716 committed files nothing ever read.
#
# One stable filename means git shows a change only when the layout actually
# changed, and the diff is readable.
rm -f "$BACKUP_DIR"/tmux_resurrect_*.txt "$BACKUP_DIR"/last
newest=$(ls -1 "$SOURCE_DIR"/tmux_resurrect_*.txt 2>/dev/null | sort | tail -n1)
[ -n "$newest" ] && cp -p "$newest" "$BACKUP_DIR/last.txt"

# Backup the claude-session -> tmux-pane map alongside the resurrect layout
cp -f "$SOURCE_DIR"/claude-sessions.tsv "$SOURCE_DIR"/claude-sessions.md "$BACKUP_DIR/" 2>/dev/null

# Backup zsh history, redacting anything token-shaped on the way in.
# Shell history collects credentials from `export TOKEN=...` style commands, and
# once one is committed it is in git history permanently — a rewrite to remove.
# The command itself is kept (it is the useful part); only the secret is masked.
cp /home/sriram/.zsh_history /home/sriram/.config/i3/my_zsh_history
sed -i -E \
	-e 's/\b(ghp_|gho_|ghu_|ghs_|ghr_|github_pat_|glpat-|xox[baprs]-|sk-(proj-)?|AKIA)[A-Za-z0-9_-]{16,}/\1<REDACTED>/g' \
	/home/sriram/.config/i3/my_zsh_history

