#!/usr/bin/env bash
input=$(cat)

user=$(whoami)
host=$(hostname -s)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$cwd" ] && cwd=$(pwd)
dir=$(basename "$cwd")

model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Git branch (skip optional locks to avoid blocking)
branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)
fi

# Build status line using printf for color support
# user@host  dir  [branch]  model  ctx%
printf "\033[32m%s@%s\033[0m \033[34m%s\033[0m" "$user" "$host" "$dir"

if [ -n "$branch" ]; then
  printf " \033[33m(%s)\033[0m" "$branch"
fi

if [ -n "$model" ]; then
  printf " \033[36m%s\033[0m" "$model"
fi

if [ -n "$remaining" ]; then
  printf " \033[35mctx:%.0f%%\033[0m" "$remaining"
fi

printf "\n"
