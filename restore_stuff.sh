#!/usr/bin/env bash
# Rehydrate tmux-resurrect state from the repo's backup dir, if one exists.
set -u

SRC="$HOME/.config/i3/tmux-resurrect-backup"
DST="$HOME/.local/share/tmux/resurrect"
mkdir -p "$DST"

if [ ! -d "$SRC" ] || [ -z "$(ls -A "$SRC" 2>/dev/null)" ]; then
	cat >&2 <<'MSG'
restore_stuff.sh: nothing to restore.

  tmux-resurrect-backup/ is NOT in git (it is gitignored on purpose: saved
  layouts embed pane titles, which on a work machine are project and client
  names). It only exists on a machine that has already run backup_stuff.sh.

  On a fresh machine this is EXPECTED. You have no saved layouts yet.
  tmux-continuum will create one within @continuum-save-interval minutes
  (currently 5) of your first tmux session, and auto-restore works from then on.

  If tmux says "Tmux resurrect file not found!", that is the same situation,
  not a bug. Start tmux, open a couple of panes, wait 5 minutes, done.

  To force a save right now:  prefix + Ctrl-s
MSG
	exit 1
fi

cp -r "$SRC"/* "$DST"/ || { echo "restore_stuff.sh: copy failed" >&2; exit 1; }
cd "$DST" || exit 1

# The repo stores one snapshot under a stable name. tmux-resurrect expects a
# timestamped file plus a `last` symlink, so rehydrate that shape here.
if [ -f last.txt ]; then
	stamp="tmux_resurrect_$(date +%Y%m%dT%H%M%S).txt"
	cp -p last.txt "$stamp"
	rm -f last.txt
	ln -sf "$stamp" last
else
	latest_file=$(ls -1 tmux_resurrect_*.txt 2>/dev/null | sort | tail -n1)
	[ -n "$latest_file" ] && ln -sf "$latest_file" last
fi

# `-f` follows symlinks, so a dangling `last` fails resurrect's own check too.
if [ -L last ] && [ ! -f last ]; then
	echo "restore_stuff.sh: 'last' is a dangling symlink -> $(readlink last)" >&2
	exit 1
fi
echo "restore_stuff.sh: restored $(readlink -f last 2>/dev/null || echo '<none>')"
