#!/bin/bash
# Captures tool usage to a log file for later review
# Hook: PostToolUse

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}')

# Only log Bash commands (most common permission requests)
if [ "$TOOL_NAME" = "Bash" ]; then
  COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // empty')
  if [ -n "$COMMAND" ]; then
    # Extract the base command (first word)
    BASE_CMD=$(echo "$COMMAND" | awk '{print $1}')
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    LOG_FILE="$HOME/skill-issue/command-log.jsonl"

    # Append to log (jsonl format)
    echo "{\"timestamp\":\"$TIMESTAMP\",\"command\":\"$COMMAND\",\"base\":\"$BASE_CMD\"}" >> "$LOG_FILE"
  fi
fi

# Always exit 0 - don't block anything
exit 0
