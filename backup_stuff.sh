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

# Shell history is deliberately NOT backed up here any more.
#
# It collects credentials from `export TOKEN=...` commands and, on a work
# machine, thousands of lines naming internal hosts, clusters and clients. Once
# committed that is permanent, and this repo is meant to be public. Redaction
# caught the tokens but could never catch the rest.
#
# Cross-machine history is a sync problem, not a version-control one: use atuin
# (end-to-end encrypted sync) instead. See README.md.
