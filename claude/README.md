# Claude Code configuration

Split by whether a file can be public.

## Versioned here — no secrets

| File | Install | What it is |
|---|---|---|
| `statusline-command.sh` | `cp claude/statusline-command.sh ~/.claude/` + `chmod +x` | the custom status line; `settings.json` points at this path, so without it the status line silently breaks |
| `keybindings.json` | `cp claude/keybindings.json ~/.claude/` | custom key bindings |
| `mcp.json` | `cp claude/mcp.json ~/.claude/` | MCP servers (chrome-devtools) |
| `settings-hooks.json` | merge into `~/.claude/settings.json` | just the SessionStart/SessionEnd hooks that keep the claude↔tmux pane map fresh |

## NOT versioned — travels in the encrypted bundle

`~/.claude/settings.json` — permissions, enabled plugins, and a block of project
context naming internal services and clusters. Restored by
`scripts/machine-migrate import`.

If you are on a machine without the bundle, copy the four files above and merge
`settings-hooks.json` by hand; you lose your permissions and project context but the
tmux session restore works.

## The tmux session restore itself

Lives in `../scripts/`: `claude-tmux-snapshot.py`, `claude-tmux-restore.sh`,
`claude-panes`, plus the resurrect hooks and keybindings in `../.tmux.conf`.
Writeup: [`../scripts/README-claude-tmux.md`](../scripts/README-claude-tmux.md).
