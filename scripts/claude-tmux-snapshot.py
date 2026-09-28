#!/usr/bin/env python3
"""Snapshot the claude-session -> tmux-pane map so it survives a reboot.

Claude Code already records the owning pane in ~/.claude/sessions/<pid>.json as
  "tmux": "<session_name>:@<window_id>.%<pane_id>"
Those ids die with the tmux server, so while tmux is alive we resolve them to
session:window_index.pane_index -- which is exactly the key tmux-resurrect
restores panes under.

Wired to @resurrect-hook-post-save-all, so the map is always written in the same
breath as the resurrect layout it belongs to.
"""

import argparse
import glob
import json
import os
import subprocess
import sys
import time

SESSIONS_DIR = os.environ.get("CLAUDE_SESSIONS_DIR") or os.path.expanduser("~/.claude/sessions")
OUT_DIR = os.path.expanduser("~/.local/share/tmux/resurrect")
TSV = os.path.join(OUT_DIR, "claude-sessions.tsv")
MD = os.path.join(OUT_DIR, "claude-sessions.md")
PREV_TSV = os.path.join(OUT_DIR, "claude-sessions.prev.tsv")
PREV_MD = os.path.join(OUT_DIR, "claude-sessions.prev.md")

# pane_current_command for a pane that is running claude
CLAUDE_COMMANDS = {"claude", "node"}

PANE_FMT = "\t".join(
    [
        "#{pane_id}",
        "#{session_name}",
        "#{window_index}",
        "#{pane_index}",
        "#{pane_current_command}",
        "#{pane_current_path}",
    ]
)


def tmux(*args):
    bin_ = os.environ.get("TMUX_BIN", "tmux").split()
    return subprocess.run(bin_ + list(args), capture_output=True, text=True)


def live_panes():
    """pane_id -> (session, win_idx, pane_idx, current_command, current_path)"""
    r = tmux("list-panes", "-a", "-F", PANE_FMT)
    if r.returncode != 0:
        return None  # no server, or tmux unavailable
    panes = {}
    for line in r.stdout.splitlines():
        f = line.split("\t")
        if len(f) != 6:
            continue
        panes[f[0]] = (f[1], f[2], f[3], f[4], f[5])
    return panes


def pid_is_claude(pid):
    """Alive AND actually claude -- guards against pid reuse."""
    try:
        with open(f"/proc/{pid}/cmdline", "rb") as fh:
            return b"claude" in fh.read()
    except OSError:
        return False


def clean(s):
    return " ".join(str(s or "").replace("\t", " ").split())


def collect():
    panes = live_panes()
    if panes is None:
        return None

    rows = {}  # coord -> row
    for path in glob.glob(os.path.join(SESSIONS_DIR, "*.json")):
        try:
            with open(path) as fh:
                d = json.load(fh)
        except (OSError, ValueError):
            continue

        if d.get("kind") != "interactive":
            continue
        tmux_ref, pid, sid = d.get("tmux"), d.get("pid"), d.get("sessionId")
        if not (tmux_ref and pid and sid):
            continue
        if not pid_is_claude(pid):
            continue

        pane_id = tmux_ref.rsplit(".", 1)[-1]
        if pane_id not in panes:
            continue
        sess, win, pane, cmd, _path = panes[pane_id]
        if cmd not in CLAUDE_COMMANDS:
            continue

        coord = f"{sess}:{win}.{pane}"
        row = {
            "session": sess,
            "window": win,
            "pane": pane,
            "session_id": sid,
            "cwd": d.get("cwd") or "",
            "name": clean(d.get("name")),
            "name_source": d.get("nameSource") or "",
            "pane_id": pane_id,
            "updated_at": int(d.get("updatedAt") or d.get("startedAt") or 0),
        }
        prev = rows.get(coord)
        if prev is None or row["updated_at"] > prev["updated_at"]:
            rows[coord] = row

    return [rows[k] for k in sorted(rows, key=lambda c: (c.split(":")[0], c))], panes


def write_tsv(rows):
    tmp = TSV + ".tmp"
    with open(tmp, "w") as fh:
        fh.write("# session\twindow\tpane\tsession_id\tcwd\tname\n")
        fh.write(f"# generated {time.strftime('%Y-%m-%d %H:%M:%S')} by claude-tmux-snapshot.py\n")
        for r in rows:
            fh.write(
                "\t".join(
                    [r["session"], r["window"], r["pane"], r["session_id"], r["cwd"], r["name"]]
                )
                + "\n"
            )
    os.replace(tmp, TSV)


def render_md(rows):
    out = [
        "# claude code sessions to restore in tmux panes and windows",
        "",
        f"_snapshot {time.strftime('%Y-%m-%d %H:%M:%S')} — {len(rows)} live session(s)_",
        "",
    ]
    cur = None
    for r in rows:
        if r["session"] != cur:
            cur = r["session"]
            out += ["", f"## {cur}", ""]
        label = r["name"] or "(unnamed)"
        if r["name_source"] == "derived":
            label += "  _(auto-named)_"
        cwd = r["cwd"].replace(os.path.expanduser("~"), "~")
        out.append(f"- [ ] `{r['window']}.{r['pane']}` — {label}")
        out.append(f"      - `cd {cwd} && claude --resume {r['session_id']}`")
    out.append("")
    return "\n".join(out)


def write_md(rows):
    tmp = MD + ".tmp"
    with open(tmp, "w") as fh:
        fh.write(render_md(rows))
    os.replace(tmp, MD)


def read_existing():
    """Rows already on disk, as dicts. Tolerates a missing/short file."""
    out = []
    try:
        fh = open(TSV)
    except OSError:
        return out
    with fh:
        for ln in fh:
            if ln.startswith("#") or not ln.strip():
                continue
            f = ln.rstrip("\n").split("\t")
            if len(f) < 5:
                continue
            out.append(
                {
                    "session": f[0], "window": f[1], "pane": f[2],
                    "session_id": f[3], "cwd": f[4],
                    "name": f[5] if len(f) > 5 else "",
                    "name_source": "", "pane_id": "", "updated_at": 0,
                }
            )
    return out


def merge(fresh, panes):
    """Union fresh rows with still-pending rows already on disk.

    After a reboot every ex-claude pane is back as a plain shell, so `fresh` is
    near-empty while the map is at its most valuable. Replacing wholesale
    destroys it. A row is dropped only on positive evidence: its pane is gone,
    or something newer occupies that pane, or the same session reappeared
    elsewhere.
    """
    live_coords = {f"{s}:{w}.{p}" for (s, w, p, _c, _pp) in panes.values()}
    merged = {f"{r['session']}:{r['window']}.{r['pane']}": r for r in fresh}
    fresh_sids = {r["session_id"] for r in fresh}
    for r in read_existing():
        coord = f"{r['session']}:{r['window']}.{r['pane']}"
        if coord in merged:
            continue          # a live session owns that pane now
        if coord not in live_coords:
            continue          # the pane itself is gone
        if r["session_id"] in fresh_sids:
            continue          # same session came back in a different pane
        merged[coord] = r     # still pending restore -- keep it
    return [merged[k] for k in sorted(merged, key=lambda c: (c.split(":")[0], c))]


def existing_row_count():
    try:
        with open(TSV) as fh:
            return sum(1 for ln in fh if ln.strip() and not ln.startswith("#"))
    except OSError:
        return 0


def keep_previous():
    """Retain the last non-empty map as a second safety net."""
    import shutil

    if existing_row_count() == 0:
        return  # never archive an empty map over a good one
    for src, dst in ((TSV, PREV_TSV), (MD, PREV_MD)):
        try:
            if os.path.exists(src):
                shutil.copy2(src, dst)
        except OSError:
            pass


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--dry-run", action="store_true", help="print, write nothing")
    ap.add_argument("--print", dest="do_print", action="store_true", help="print the checklist")
    ap.add_argument(
        "--replace",
        action="store_true",
        help="hard-reset the map to exactly what is live now (drops pending rows)",
    )
    ap.add_argument(
        "--force",
        action="store_true",
        help="write even when that would replace a populated map with an empty one",
    )
    args = ap.parse_args()

    collected = collect()
    if collected is None:
        print("claude-tmux-snapshot: no tmux server; nothing to do", file=sys.stderr)
        return 0
    rows, panes = collected
    if not args.replace:
        rows = merge(rows, panes)
    if not rows:
        print("claude-tmux-snapshot: no live claude panes found", file=sys.stderr)

    if args.do_print:
        print(render_md(rows))
        return 0
    if args.dry_run:
        print(f"would write {len(rows)} row(s) to {TSV}")
        for r in rows:
            print(
                f"  {r['session']}:{r['window']}.{r['pane']}  {r['session_id'][:8]}  "
                f"[{r['name_source'] or '-'}] {r['name'][:60]}"
            )
        return 0

    os.makedirs(OUT_DIR, exist_ok=True)

    # Boot-time guard. tmux comes back before claude does, so a save that fires
    # during (or just before) the resurrect restore sees zero claude panes. Never
    # let that wipe a good map -- that is precisely the morning you need it.
    had = existing_row_count()
    if not rows and had and not args.force:
        print(
            f"claude-tmux-snapshot: refusing to replace {had} saved row(s) with an "
            f"empty map (no live claude panes); use --force to override",
            file=sys.stderr,
        )
        return 0

    if rows:
        keep_previous()
    write_tsv(rows)
    write_md(rows)
    return 0


if __name__ == "__main__":
    sys.exit(main())
