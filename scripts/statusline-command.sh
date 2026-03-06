#!/usr/bin/env bash
# Claude Code status line — PS1-style with context bar and compaction counter
# Cross-platform: Linux and Windows (Git Bash / MSYS2)

input=$(cat)

# Pure bash JSON value extraction (no jq needed)
get_json_val() {
  local key="$1"
  echo "$input" | sed -n "s/.*\"${key}\":\([^,}]*\).*/\1/p" | tr -d ' "'
}

cwd=$(get_json_val "cwd" | sed 's/\\\\/\//g')
[ -z "$cwd" ] && cwd=$(pwd)

# Context window metrics
used_pct=$(get_json_val "used_percentage")
window_size=$(get_json_val "context_window_size")
cost_usd=$(get_json_val "total_cost_usd")
session_id=$(get_json_val "session_id")

# Track compaction count per session via state file
compact_count=0
if [ -n "$session_id" ] && [ -n "$used_pct" ]; then
  state_dir="${TMPDIR:-/tmp}"
  state_file="${state_dir}/claude-statusline-${session_id}"
  if [ -f "$state_file" ]; then
    prev_pct=$(sed -n '1p' "$state_file")
    compact_count=$(sed -n '2p' "$state_file")
    [ -z "$compact_count" ] && compact_count=0
    # If usage dropped by 15%+ from previous reading, a compaction occurred
    if [ -n "$prev_pct" ] && [ "$prev_pct" -gt 0 ] 2>/dev/null; then
      drop=$((prev_pct - used_pct))
      [ "$drop" -ge 15 ] && compact_count=$((compact_count + 1))
    fi
  fi
  printf '%s\n%s\n' "$used_pct" "$compact_count" > "$state_file"
fi

# Build context bar
context_bar=""
if [ -n "$used_pct" ] && [ -n "$window_size" ] && [ "$window_size" -gt 0 ] 2>/dev/null; then
  max_k=$((window_size / 1000))
  used_k=$((window_size * used_pct / 100 / 1000))

  # Bar color based on usage percentage
  if [ "$used_pct" -le 50 ]; then
    BAR_COLOR='\033[37m'  # white
  elif [ "$used_pct" -le 75 ]; then
    BAR_COLOR='\033[33m'  # yellow
  else
    BAR_COLOR='\033[31m'  # red
  fi

  # Build bar: 10 chars wide, filled proportionally
  bar_width=10
  filled=$((used_pct * bar_width / 100))
  [ "$filled" -gt "$bar_width" ] && filled=$bar_width
  empty=$((bar_width - filled))
  bar=$(printf '%0.s█' $(seq 1 $filled 2>/dev/null))
  [ "$empty" -gt 0 ] && bar="${bar}$(printf '%0.s░' $(seq 1 $empty 2>/dev/null))"
  # Fallback if seq produced nothing (0%)
  [ -z "$bar" ] && bar="░░░░░░░░░░"

  context_bar=" ${BAR_COLOR}${bar}\033[0m ${used_k}k/${max_k}k ${used_pct}% [${compact_count}]"
fi

# Append cost if available
if [ -n "$cost_usd" ]; then
  context_bar="${context_bar} \$${cost_usd}"
fi

# Colors (ANSI)
GREEN='\033[32m'
PURPLE='\033[35m'
YELLOW='\033[33m'
CYAN='\033[36m'
RESET='\033[0m'

# user@host
USER_HOST="$(whoami)@$(hostname -s 2>/dev/null || hostname)"

# Platform indicator: MSYSTEM on Windows/Git Bash, or kernel name on Linux/macOS
if [ -n "$MSYSTEM" ]; then
  PLATFORM="$MSYSTEM"
else
  PLATFORM=$(uname -s 2>/dev/null || echo "Unknown")
fi

# Git branch info
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  [ -n "$branch" ] && git_branch=" ($branch)"
fi

printf "${GREEN}%s ${PURPLE}%s ${YELLOW}%s${CYAN}%s${RESET}\n%b${RESET}" \
  "$USER_HOST" "$PLATFORM" "$cwd" "$git_branch" "$context_bar"
