# Backup current tmux resurrect state
BACKUP_DIR="/home/sriram/.config/i3/tmux-resurrect-backup"
SOURCE_DIR="/home/sriram/.local/share/tmux/resurrect"
mkdir -p "$BACKUP_DIR"

# Keep only the newest few snapshots. tmux-resurrect already prunes its own
# directory to 5 copies / 30 days; copying *.txt unconditionally defeated that
# and had accumulated 716 committed files (~46k lines) that no restore reads —
# restore_stuff.sh only ever follows the `last` symlink.
KEEP=5
rm -f "$BACKUP_DIR"/*.txt
ls -1t "$SOURCE_DIR"/tmux_resurrect_*.txt 2>/dev/null | head -n "$KEEP" \
	| xargs -r -I{} cp -p {} "$BACKUP_DIR/"

# Backup the claude-session -> tmux-pane map alongside the resurrect layout
cp -f "$SOURCE_DIR"/claude-sessions.tsv "$SOURCE_DIR"/claude-sessions.md "$BACKUP_DIR/" 2>/dev/null
# Pick `last` by NAME, not mtime. The filenames are tmux_resurrect_<ISO>.txt so a
# lexical sort is chronological, whereas mtime depends on the order cp happened to
# write them — which silently pointed `last` at the OLDEST snapshot once the copy
# switched to newest-first. `cp -p` above also preserves the real timestamps.
cd "$BACKUP_DIR" && latest_file=$(ls -1 tmux_resurrect_*.txt | sort | tail -n1) && ln -sf "$latest_file" last

# Backup zsh history, redacting anything token-shaped on the way in.
# Shell history collects credentials from `export TOKEN=...` style commands, and
# once one is committed it is in git history permanently — a rewrite to remove.
# The command itself is kept (it is the useful part); only the secret is masked.
cp /home/sriram/.zsh_history /home/sriram/.config/i3/my_zsh_history
sed -i -E \
	-e 's/\b(ghp_|gho_|ghu_|ghs_|ghr_|github_pat_|glpat-|xox[baprs]-|sk-(proj-)?|AKIA)[A-Za-z0-9_-]{16,}/\1<REDACTED>/g' \
	/home/sriram/.config/i3/my_zsh_history

