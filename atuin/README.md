# atuin config

`config.toml` → `~/.config/atuin/config.toml`.

Install on a new machine:

```bash
mkdir -p ~/.config/atuin && cp atuin/config.toml ~/.config/atuin/
```

**This is security-relevant, not cosmetic.** It holds `history_filter` — the regex list that
stops token-shaped commands reaching the atuin database — plus `secrets_filter = true` and
`auto_sync = false`. Install atuin without it and you get upstream defaults: no credential
filtering, and history that was only ever meant to stay on this machine.

It pairs with `HISTORY_IGNORE` in `.zshrc`, which stops the same patterns reaching
`~/.zsh_history`. Two layers, deliberately agreeing with each other — neither is trusted
alone.

Contains no secrets: regex patterns and display preferences.
