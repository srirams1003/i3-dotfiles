# i3-dotfiles

My full Linux desktop environment, versioned. Clones directly to `~/.config/i3`, which is
also where most of these files are read from — so there is no install step for the i3 side,
only a few symlinks for the things X and zsh expect in `$HOME`.

i3wm + i3blocks, Alacritty, zsh/powerlevel10k, tmux, rofi, picom, dunst.

>**Deliberately not in this repo:** shell history, tmux session layouts, clipboard
> exports, TLS material, and anything naming a machine, employer or client. Those either
> cannot be redacted meaningfully or have no business being versioned. See
> [What is not here](#what-is-not-here).

---

## Branch per machine

There is no single `main` that works everywhere. Each branch is a whole environment tuned
to one machine — different monitor layouts, brightness backends, audio sinks, package
managers, and in one case a completely different OS.

| Branch | Machine |
|---|---|
| `main` / `2026-master-branch` | primary Linux desktop |
| `wsl2-work` | WSL2 under Windows 11 (work laptop) |
| `arch`, `fedora`, `new_fedora` | Arch / Fedora installs |
| `macos` | macOS (see also `*_mac.sh` brightness variants) |
| `multipass` | Multipass VM |
| `linux-mint-on-VM-with-host-as-windows11` | Linux Mint guest on a Windows 11 host |

Pick the branch for the box you are on. They are intentionally divergent, not stale copies
of each other.

### `common` — the shared base

Measured against `origin/main`, the active branches (`main`, `2026-master-branch`,
`wsl2-work`) differ in only **11 files**; `arch`, `fedora` and `macos` differ in ~50 and are
effectively archived. So most edits are not machine-specific at all, and without a shared
base each one needs cherry-picking three ways.

`common` tracks `origin/main` and is where **shared** changes go first:

```bash
git switch common
# edit .tmux.conf / backup_stuff.sh / scripts/ / a note …
git commit -am "…"

git switch wsl2-work && git merge common     # repeat per active machine branch
```

| Genuinely machine-specific — never on `common` | Everything else |
|---|---|
| `config`, `i3blocks.conf`, `startup.sh`, `picom.conf`, `.alacritty.toml`, `.zshrc`, `raise_volume.sh`, `lower_volume.sh`, `increase_brightness.sh`, `decrease_brightness.sh` | the other 41 tracked files — `.tmux.conf`, `.p10k.zsh`, `backup_stuff.sh`, `restore_stuff.sh`, `scripts/`, the blocklets, the audio/dict helpers, every note |

`.zshrc` is on the machine-specific side because each box has different aliases — but that
means genuinely portable parts of it (history hygiene, for instance) still have to be
copied by hand. Worth splitting into `.zshrc` + a shared `.zshrc.common` if that keeps
biting.

---

## Install

The bootstrap lives in the companion repo
[`srirams1003/dotfiles`](https://github.com/srirams1003/dotfiles): `firstScript.sh` then
`secondScript.sh`. The second one clones this repo into place and creates the symlinks:

```bash
git clone https://github.com/srirams1003/i3-dotfiles.git ~/.config/i3
ln -sf ~/.config/i3/.zshrc    ~/.zshrc
ln -sf ~/.config/i3/.p10k.zsh ~/.p10k.zsh
ln -sf ~/.config/i3/.tmux.conf ~/.tmux.conf
```

`commands_to_run_after_reinstall.md` is the post-reinstall checklist.

---

## Layout

### Window manager and desktop

| File | Purpose |
|---|---|
| `config` | i3wm — `Mod4` as mod, Alacritty on `$mod+Return`, autostart via `startup.sh` |
| `i3blocks.conf` / `i3status.conf` | status bar; blocklets below |
| `i3blocks-contrib/` | vendored upstream blocklet collection (`cpu_usage`, `temperature`, `weather_NOAA`, `shutdown_menu`, …) |
| `picom.conf` | compositor |
| `dunstrc` | notification daemon |
| `config.rasi` | rofi theme |
| `.alacritty.toml` | terminal |

### Custom i3blocks blocklets

Small Python scripts the bar calls directly, alongside the vendored ones:

| Script | Shows | Status |
|---|---|---|
| `get_used_ram.py` | memory | active (`[memory]`) |
| `get_gpu.py` | GPU load | active (`[gpu-load]`) |
| `get_song.py` | now playing | active (`[mediaplayer]`) |
| `ethernet_status.py` | link state | **commented out** in `i3blocks.conf:94` |

The rest of the bar — `disk_usage`, `cpu_usage`, `temperature`, `weather_NOAA`, `battery`,
`shutdown_menu` — comes from `i3blocks-contrib/` or `/usr/share/i3blocks`.

### Shell and multiplexer

| File | Purpose |
|---|---|
| `.zshrc` | oh-my-zsh, p10k, fzf, kubectl aliases, podman-as-docker aliases |
| `.p10k.zsh` | prompt theme |
| `.tmux.conf` | `C-Space` prefix, vi copy-mode, resurrect + continuum, claude session restore |

### Hardware and session scripts

Bound to keys in `config`, or run at startup:

| Script | Does |
|---|---|
| `startup.sh` | run at login: picks the display (external `DisplayPort-3` at 2560x1440@60 if connected, else `eDP`), swaps caps↔escape, restarts i3, reconnects two bluetooth audio devices, reopens reference PDFs in okular |
| `arandr_config.sh` | monitor layout; makes the external display primary |
| `set_mouse_sensitivity.sh` | libinput accel for a Razer DeathAdder |
| `raise_volume.sh` / `lower_volume.sh` / `mute_unmute.sh` | PulseAudio volume |
| `sink-switch.sh` / `toggle_sink.sh` | move audio between output sinks |
| `increase_brightness.sh` / `decrease_brightness.sh` | backlight (`_mac.sh` variants target `eDP` on Apple hardware) |
| `dict_selection.sh` | Google the current X primary selection in a new Firefox window |
| `dict_screenshot.sh` | `maim` a screen region → `tesseract` OCR → Google the extracted text |

### Backup and restore

Paired scripts — one writes into this repo, the other reads back out after a reinstall:

| Pair | Covers |
|---|---|
| `backup_stuff.sh` / `restore_stuff.sh` | tmux resurrect state, on this machine only |
| `backup_personal_folders.sh` / `restore_personal_folders.sh` | personal directories over rsync |

`tmux-resurrect-backup/` is written locally but **not versioned** — saved layouts embed
pane titles, which on a work machine are project and client names. So tmux layouts survive
a reboot, but do not travel to a new machine. That is a deliberate trade: the layouts
reference absolute paths that would not exist there anyway.

**`backup_stuff.sh` runs hourly**, via a systemd user timer rather than by hand:

```bash
systemctl --user list-timers backup-dotfiles.timer
systemctl --user start backup-dotfiles.service   # run one now
journalctl --user -u backup-dotfiles.service     # what happened
```

Units live in `~/.config/systemd/user/backup-dotfiles.{service,timer}`. `Persistent=true`,
so a machine that was asleep or shut down runs the missed occurrence instead of skipping
it — the failure mode that previously left the committed history five months stale.

### Notes kept alongside the config

`commands_to_run_after_reinstall.md`, `apt-mark-hold-t2-lts-kernel.md`,
`multipass_vs_vbox_kvm_intel_modprobe.txt`, `convert_mkv_to_mp4_using_ffmpeg.txt`,
`electronics-embedded-todo.md`.


---

## Restoring Claude Code sessions with tmux

`scripts/` restores not just the tmux layout but the **Claude Code session that was running
in each pane**. Claude records its owning pane in `~/.claude/sessions/<pid>.json`; a
snapshot resolves that to `session:window.pane` while tmux is alive, and a restore hook
types `claude --resume <id>` back into that exact pane after a reboot.

| Key | Does |
|---|---|
| `prefix + C-a` | launch every mapped session |
| `prefix + C-p` | re-prime (types the command, no Enter) |
| `prefix + C-n` | popup the generated checklist |
| `prefix + C-s` / `C-r` | tmux-resurrect's own save / restore |

`claude-panes` is the CLI (`show`, `save`, `list`, `prime`, `launch`, `log`).
Full writeup, including the failure modes it guards against:
[`scripts/README-claude-tmux.md`](scripts/README-claude-tmux.md).

---

## What is not here

This repo is public, so a few things are kept out of it permanently rather than redacted:

| Not versioned | Why |
|---|---|
| shell history | names internal hosts, clusters and clients; see [Shell history](#shell-history-atuin) |
| `tmux-resurrect-backup/` | saved layouts embed pane titles = project and client names |
| CopyQ clipboard exports | arbitrary captured content, unreviewable |
| copyparty config | contained a TLS private key |
| `~/.zshrc.local` | cluster names, cloud projects, Windows paths, lab hosts |

Machine- and employer-specific shell config belongs in `~/.zshrc.local`, which `.zshrc`
sources if present and git never sees.

---

## Shell history (atuin)

[atuin](https://atuin.sh) replaces the old committed `my_zsh_history`. History lives in a
local SQLite DB with far better recall than autosuggestions — fuzzy search, filter by
directory, host or exit status — on `Ctrl-R`.

Up-arrow stays bound to zsh's own history (`--disable-up-arrow`) and zsh still writes
`~/.zsh_history`, so `zsh-autosuggestions` behaves exactly as before.

**Sync is deliberately off** (`auto_sync = false`); nothing leaves the machine. atuin's
hosted sync is end-to-end encrypted and safe in a technical sense, but it would still put
an employer's infrastructure command log on a third party.

Moving machines is an explicit, encrypted, serverless step:

```bash
scripts/atuin-migrate export         # -> ~/atuin-history-<date>.db.gpg, AES-256
scripts/atuin-migrate verify <file>  # decrypt and count, without importing
scripts/atuin-migrate import <file>  # merge into this machine
```

gpg symmetric encryption, chosen because gpg is already on essentially every distro.
Import merges on primary key, so it is idempotent and two machines' histories combine
rather than overwrite.

Credentials are filtered at two layers that agree: `HISTORY_IGNORE` in `.zshrc` keeps them
out of `~/.zsh_history`, and `history_filter` + `secrets_filter` in
`~/.config/atuin/config.toml` keep them out of the atuin DB. Verified: 10,380 commands
imported, zero credential-shaped entries stored.
