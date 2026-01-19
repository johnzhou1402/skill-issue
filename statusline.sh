#!/bin/bash
input=$(cat)
DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Daily rotating emoji based on day of year
EMOJIS=("🌿" "🌸" "🌊" "🔥" "⚡" "🌙" "☀️" "🍀" "🎯" "🚀" "💫" "🌈" "🎨" "🎵" "🌺" "🍁" "❄️" "🌻" "🦋" "🐙")
DAY_OF_YEAR=$(date +%j | sed 's/^0*//')
EMOJI_INDEX=$((DAY_OF_YEAR % ${#EMOJIS[@]}))
EMOJI="${EMOJIS[$EMOJI_INDEX]}"

# Git branch
BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
if [ -z "$BRANCH" ]; then
  echo "$EMOJI 📁 ${DIR##*/}"
  exit 0
fi

# Extract Linear ticket from branch (matches patterns like PRO-123, ENG-456, etc.)
TICKET=$(echo "$BRANCH" | grep -oE '[A-Z]+-[0-9]+' | head -1)

# Get PR number if exists
PR=""
if command -v gh &> /dev/null; then
  PR_NUM=$(cd "$DIR" && gh pr view --json number -q .number 2>&1 | grep -E '^[0-9]+$')
  if [ -n "$PR_NUM" ]; then
    PR=" | PR #$PR_NUM"
  fi
fi

# Build output
OUTPUT="$EMOJI $BRANCH$PR"
if [ -n "$TICKET" ]; then
  OUTPUT="$OUTPUT | 📋 $TICKET"
fi
OUTPUT="$OUTPUT | 📁 ${DIR##*/}"

echo "$OUTPUT"
