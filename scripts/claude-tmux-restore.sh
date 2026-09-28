#!/usr/bin/env bash
# Replay the claude-session -> tmux-pane map written by claude-tmux-snapshot.py.
#
# Wired to @resurrect-hook-post-restore-all, so it runs once tmux-resurrect has
# rebuilt the layout. For every pane that held a claude session it types
#   cd <cwd> && claude --resume <session_id>
# into that exact pane.
#
# Modes:
#   prime   (default) type the command, do NOT press Enter -- you review, you Enter
#   launch            type it and press Enter, staggered
#   dry-run           report only, touch nothing
#
# Safety: never writes to a pane that is not sitting at a shell prompt.

set -uo pipefail

TSV_DEFAULT="$HOME/.local/share/tmux/resurrect/claude-sessions.tsv"
LOG="$HOME/.local/share/tmux/resurrect/claude-restore.log"

read -r -a TMUX_CMD <<< "${TMUX_BIN:-tmux}"
CLAUDE_CMD="${CLAUDE_CMD:-claude}"
TSV="$TSV_DEFAULT"
MODE=""
DELAY_OVERRIDE=""

while [ $# -gt 0 ]; do
	case "$1" in
		--prime)   MODE="prime" ;;
		--launch)  MODE="launch" ;;
		--dry-run|--list) MODE="dry-run" ;;
		--no-delay) DELAY_OVERRIDE="0" ;;
		--file)    TSV="$2"; shift ;;
		-h|--help) sed -n '2,20p' "$0"; exit 0 ;;
		*) echo "unknown flag: $1" >&2; exit 2 ;;
	esac
	shift
done

tm() { "${TMUX_CMD[@]}" "$@"; }

opt() { # opt <name> <default>
	local v
	v="$(tm show-option -gqv "$1" 2>/dev/null)"
	[ -n "$v" ] && printf '%s' "$v" || printf '%s' "$2"
}

if ! tm list-panes -a -F '#{pane_id}' >/dev/null 2>&1; then
	echo "claude-tmux-restore: no tmux server" >&2
	exit 0
fi

[ -n "$MODE" ] || MODE="$(opt @claude-restore-mode prime)"
DELAY="${DELAY_OVERRIDE:-$(opt @claude-restore-delay 4)}"
STAGGER="$(opt @claude-restore-stagger 2)"

rows_in() { awk '!/^[[:space:]]*(#|$)/ { n++ } END { print n + 0 }' "$1" 2>/dev/null || echo 0; }

# Fall back to the archived map if the live one is missing or somehow empty.
if [ ! -r "$TSV" ] || [ "$(rows_in "$TSV")" -eq 0 ]; then
	PREV="${TSV%.tsv}.prev.tsv"
	if [ -r "$PREV" ] && [ "$(rows_in "$PREV")" -gt 0 ]; then
		echo "claude-tmux-restore: $TSV empty/missing, falling back to $PREV" >&2
		TSV="$PREV"
	else
		echo "claude-tmux-restore: no usable map at $TSV" >&2
		exit 0
	fi
fi

# Let restored shells finish starting (p10k instant prompt, gitstatusd) before
# typing into them. A prime that races the shell loses characters.
if [ "$MODE" != "dry-run" ] && [ "$DELAY" != "0" ]; then
	sleep "$DELAY"
fi

# Say something immediately: a launch staggers a couple of seconds per pane, and
# silence is indistinguishable from a broken keybinding.
if [ "$MODE" != "dry-run" ]; then
	n_rows="$(rows_in "$TSV")"
	tm display-message "claude: ${MODE}ing ${n_rows} pane(s)…" 2>/dev/null
fi

is_shell() {
	case "$1" in
		zsh|bash|sh|fish|dash|ksh) return 0 ;;
		*) return 1 ;;
	esac
}

n_ok=0; n_missing=0; n_busy=0; n_cwdmiss=0
declare -a REPORT=()

while IFS=$'\t' read -r sess win pane sid cwd name; do
	case "$sess" in ''|'#'*) continue ;; esac
	[ -n "${sid:-}" ] || continue
	target="${sess}:${win}.${pane}"

	# NOTE: `display-message -p -t` silently falls back to a nearby pane when the
	# target does not exist (ctest:9.0 resolves to ctest:1.0). `list-panes -t`
	# errors correctly, and matching the coord back guarantees the right pane.
	probe="$(tm list-panes -t "$target" \
		-F '#{session_name}:#{window_index}.#{pane_index}	#{pane_current_command}	#{pane_current_path}' 2>/dev/null \
		| awk -F'\t' -v want="$target" '$1 == want { print $2 "\t" $3; exit }')"
	if [ -z "$probe" ]; then
		n_missing=$((n_missing + 1)); REPORT+=("MISSING  $target  $name"); continue
	fi
	cur_cmd="${probe%%	*}"
	cur_path="${probe#*	}"

	if ! is_shell "$cur_cmd"; then
		n_busy=$((n_busy + 1)); REPORT+=("BUSY($cur_cmd)  $target  $name"); continue
	fi

	mismatch=0
	if [ -n "$cwd" ] && [ "$cur_path" != "$cwd" ]; then
		mismatch=1
	fi
	if [ "$mismatch" = 1 ] && [ "$MODE" = "launch" ]; then
		n_cwdmiss=$((n_cwdmiss + 1))
		REPORT+=("CWD-MISMATCH(skipped)  $target  pane=$cur_path want=$cwd"); continue
	fi

	line="cd ${cwd} && ${CLAUDE_CMD} --resume ${sid}"

	if [ "$MODE" = "dry-run" ]; then
		flag=""; [ "$mismatch" = 1 ] && flag="  [cwd-mismatch]"
		REPORT+=("WOULD-SEND  $target  $line$flag")
		n_ok=$((n_ok + 1)); continue
	fi

	[ -n "$name" ] && tm select-pane -t "$target" -T "$name" 2>/dev/null
	# Clear the line first so a re-prime (prefix + C-p) after a partially-typed
	# attempt REPLACES it instead of appending. zsh main keymap here is emacs,
	# so C-u is kill-whole-line; on an empty prompt it is a no-op.
	tm send-keys -t "$target" C-u 2>/dev/null
	tm send-keys -t "$target" -l "$line" 2>/dev/null

	if [ "$MODE" = "launch" ]; then
		tm send-keys -t "$target" Enter 2>/dev/null
		[ "$STAGGER" != "0" ] && sleep "$STAGGER"
	fi

	[ "$mismatch" = 1 ] && n_cwdmiss=$((n_cwdmiss + 1))
	n_ok=$((n_ok + 1))
	REPORT+=("$(echo "$MODE" | tr '[:lower:]' '[:upper:]')  $target  $name")
done < "$TSV"

summary="claude: ${MODE} ${n_ok}"
[ "$n_busy" -gt 0 ]    && summary="$summary, skipped ${n_busy} busy"
[ "$n_missing" -gt 0 ] && summary="$summary, ${n_missing} pane(s) gone"
[ "$n_cwdmiss" -gt 0 ] && summary="$summary, ${n_cwdmiss} cwd-mismatch"
[ "$MODE" = "prime" ] && [ "$n_ok" -gt 0 ] && summary="$summary — press Enter in each pane"

{
	echo "=== $(date '+%Y-%m-%d %H:%M:%S')  mode=$MODE  map=$TSV"
	printf '%s\n' "${REPORT[@]}"
	echo "--- $summary"
} >> "$LOG"

if [ "$MODE" = "dry-run" ]; then
	printf '%s\n' "${REPORT[@]}"
	echo "--- $summary"
else
	tm display-message "$summary" 2>/dev/null
fi

exit 0
