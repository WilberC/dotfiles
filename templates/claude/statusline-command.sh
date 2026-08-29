#!/bin/bash
# Status line: current folder name, model status, context usage,
# and 5-hour rate-limit usage with time left to reset.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
[ -z "$cwd" ] && cwd=$(pwd)
folder=$(basename "$cwd")

model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')

ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

five_str=""
if [ -n "$five_pct" ]; then
  five_str=$(printf '%.0f%%' "$five_pct")
  if [ -n "$five_reset" ]; then
    now=$(date +%s)
    diff=$((five_reset - now))
    if [ "$diff" -gt 0 ]; then
      hrs=$((diff / 3600))
      mins=$(((diff % 3600) / 60))
      five_str="${five_str} (resets in ${hrs}h ${mins}m)"
    fi
  fi
fi

# Colors (dimmed, since status line is rendered dim by the terminal)
folder_color='\033[2;32m'   # dim green
model_color='\033[2;36m'    # dim cyan
label_color='\033[2;90m'    # dim gray
reset='\033[0m'

out=$(printf "${folder_color}%s${reset}" "$folder")

if [ -n "$model" ]; then
  out="${out}$(printf " ${label_color}|${reset} ${model_color}%s${reset}" "$model")"
  if [ -n "$effort" ]; then
    out="${out}$(printf " ${label_color}(%s)${reset}" "$effort")"
  fi
fi

if [ -n "$ctx_used" ]; then
  ctx_fmt=$(printf '%.0f%%' "$ctx_used")
  out="${out}$(printf " ${label_color}| ctx:${reset} %s" "$ctx_fmt")"
fi

if [ -n "$five_str" ]; then
  out="${out}$(printf " ${label_color}| 5h:${reset} %s" "$five_str")"
fi

printf '%s' "$out"
