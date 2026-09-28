# Restoring Claude Code sessions into the tmux panes that owned them

## Why this works

Claude Code already records its owning pane. `~/.claude/sessions/<pid>.json`:

```json
{"pid":11173,"sessionId":"99c86917-…","cwd":"/home/sriram/reskin/microservice-voice-agents",
 "tmux":"reskin:@14.%52","name":"krishna voice agents microservice work","nameSource":"user"}
```

`@14` / `%52` are tmux *ids* — they die with the server. So while tmux is alive we
resolve them to `session:window_index.pane_index`, which is exactly the key
tmux-resurrect restores panes under.

The snapshot is taken from `@resurrect-hook-post-save-all`, i.e. in the same breath
as the resurrect layout dump — so the map and the layout always describe the same
instant and the indices cannot disagree.

## Pieces

| Path | Role |
|---|---|
| `claude-tmux-snapshot.py` | live sessions → `~/.local/share/tmux/resurrect/claude-sessions.{tsv,md}` |
| `claude-tmux-restore.sh` | replays the map into restored panes |
| `claude-panes` | CLI: `show` / `save` / `list` / `prime` / `launch` / `log` |
| `~/.config/i3/.tmux.conf` | hooks, options, keybindings (lines ~75–91) |
| `~/.claude/settings.json` | SessionStart + SessionEnd hooks re-snapshot immediately |
| `backup_stuff.sh` | carries the map into `tmux-resurrect-backup/` |

## Keys

| Key | Does |
|---|---|
| `prefix + C-a` | launch every mapped session (types + Enter, staggered 2s) |
| `prefix + C-p` | re-prime (types, no Enter) |
| `prefix + C-n` | popup the generated checklist |
| `prefix + C-s` / `C-r` | resurrect's own save / restore (unchanged) |

## Modes

`set -g @claude-restore-mode 'prime'` (default) types the command and stops.
Change to `'launch'` to auto-run. `'dry-run'` reports only.

Also: `@claude-restore-delay` (4s, wait for restored shells to be prompt-ready),
`@claude-restore-stagger` (2s between launches), `@continuum-save-interval` (5 min).

## Safety properties

- **Never writes to a busy pane.** Skips any pane whose `pane_current_command`
  isn't a shell. Run against the live server today and it skips all 20.
- **Exact pane targeting.** `tmux display-message -p -t <target>` *silently falls
  back to a nearby pane* when the target doesn't exist (`ctest:9.0` resolved to
  `ctest:1.0`). `list-panes -t` errors correctly, so the probe uses that and then
  matches the coordinate back. `send-keys -t` does NOT fall back — it errors.
- **cwd guard.** Pane path must equal the recorded cwd. In `launch` the row is
  skipped on mismatch; in `prime` it is typed but flagged.
- **Liveness.** A session counts only if `/proc/<pid>/cmdline` still contains
  `claude` (pid-reuse proof) AND its pane still exists AND that pane runs claude.
  182 session files on disk, ~20 real.
- Every run appends to `~/.local/share/tmux/resurrect/claude-restore.log`.

## After a reboot

continuum restores the layout → `post-restore-all` fires → each ex-claude pane has
`cd <cwd> && claude --resume <id>` sitting at the prompt, and the pane is titled
with the session name so `choose-tree` reads like the checklist. Press Enter in the
panes you want. `prefix + C-a` to start them all.

Run it a few reboots. If `skipped … cwd-mismatch` stays 0, flip
`@claude-restore-mode` to `'launch'`.

## When the map is written

Three independent paths, all of which produce the same file:

| Trigger | Path |
|---|---|
| `prefix + C-s` | `save.sh` -> `post-save-all` -> snapshot (immediate) |
| continuum timer (5 min) | the same `save.sh` (`@resurrect-save-script-path`) |
| claude `SessionStart` / `SessionEnd` | snapshot directly, ~3s after open/close |

`prefix + C-a` / `C-p` pass `--no-delay`: the 8s `@claude-restore-delay` exists for
the boot path, where restored shells are still starting. On a keypress the shells
are obviously ready, and 8s of silence reads as a broken binding.

## Manual fallback

If the automation misfires, the checklist is on disk in four places — every one of
them survives a reboot:

```
~/.local/share/tmux/resurrect/claude-sessions.md        # live map, regenerated every 5 min
~/.local/share/tmux/resurrect/claude-sessions.prev.md   # previous good map
~/.config/i3/tmux-resurrect-backup/claude-sessions.md   # dotfiles backup (backup_stuff.sh)
~/CLAUDE-SESSIONS-RESTORE.md                            # dead-obvious copy
```

Each entry is a ready-to-paste `cd <dir> && claude --resume <id>`. Session ids stay
valid as long as the transcript exists in `~/.claude/projects/<escaped-cwd>/`.
`claude --resume` with no id opens the picker; `claude -c` continues the newest
session in the current directory.

## Two guards against losing the map

- **Empty-map guard.** tmux comes back before claude does, so a continuum save
  during the restore sees zero claude panes. `claude-tmux-snapshot.py` refuses to
  replace a populated map with an empty one (`--force` overrides). Without this the
  map would be wiped on exactly the morning it is needed.
- **Merge, never replace.** *(the bug that bit on the first real reboot,
  2026-09-28)* The snapshot used to mirror "what is running right now". After a
  reboot two sessions were resumed, a continuum save fired five minutes later,
  and the map was overwritten 20 rows -> 2 — so `prefix + C-a` correctly reported
  `launch 0, skipped 2 busy`. The map is at its most valuable exactly when it
  looks emptiest. It now merges: a row is dropped only when its pane is gone,
  when a live claude session owns that pane, or when the same session id
  reappeared elsewhere. `--replace` forces a hard reset to live state.
- **`.prev` fallback.** Every non-empty snapshot archives the outgoing map to
  `claude-sessions.prev.{tsv,md}`, and `claude-tmux-restore.sh` falls back to it if
  the live map is missing or empty.
