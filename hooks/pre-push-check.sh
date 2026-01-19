#!/bin/bash
# Pre-push quality check: ensure we're pushing clean, relevant commits

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only run on git push commands
if [[ ! "$command" =~ ^git\ push ]] && [[ ! "$command" =~ ^git\ -C\ [^[:space:]]+\ push ]]; then
  exit 0
fi

# Get current branch
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [[ -z "$current_branch" ]] || [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]]; then
  exit 0  # Let protect-main-branch.sh handle main/master
fi

# Find the merge base with main (where we branched from)
merge_base=$(git merge-base main HEAD 2>/dev/null || git merge-base master HEAD 2>/dev/null)
if [[ -z "$merge_base" ]]; then
  exit 0  # Can't determine, let it through
fi

errors=()
warnings=()

# === CHECK 1: Irrelevant/sensitive files ===
blocked_patterns=(
  ".env"
  ".env.*"
  "*.pem"
  "*.key"
  ".claude/settings.local.json"
  ".claude/history.jsonl"
  ".claude/statsig/*"
  ".claude/todos/*"
  ".claude/debug/*"
  ".DS_Store"
  "Thumbs.db"
  "*.log"
  "node_modules/*"
)

# Get files changed in our commits (not on remote yet)
remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
if [[ -n "$remote_branch" ]]; then
  changed_files=$(git diff --name-only "$remote_branch"..HEAD 2>/dev/null)
else
  # No upstream, compare to merge base
  changed_files=$(git diff --name-only "$merge_base"..HEAD 2>/dev/null)
fi

for file in $changed_files; do
  for pattern in "${blocked_patterns[@]}"; do
    if [[ "$file" == $pattern ]] || [[ "$file" == *"/$pattern" ]]; then
      errors+=("Blocked file: $file")
    fi
  done
done

# === CHECK 2: Commits from wrong base (stacked branches) ===
# Count commits since merge base
commit_count=$(git rev-list --count "$merge_base"..HEAD 2>/dev/null)

# Get commits that aren't ours (different author or from before our branch)
# Check if any commits between merge_base and HEAD are from merged PRs (have multiple parents)
stacked_commits=$(git log --oneline "$merge_base"..HEAD --merges 2>/dev/null | wc -l | tr -d ' ')
if [[ "$stacked_commits" -gt 0 ]]; then
  warnings+=("Branch may include merge commits from another branch ($stacked_commits merge commits found)")
fi

# Check if we have a suspicious number of commits
if [[ "$commit_count" -gt 20 ]]; then
  warnings+=("Large number of commits ($commit_count) - did you branch off another feature branch?")
fi

# Check if any commits are from a different author (might indicate stacked branch)
my_email=$(git config user.email)
other_authors=$(git log --format='%ae' "$merge_base"..HEAD 2>/dev/null | grep -v "$my_email" | grep -v "noreply@anthropic.com" | sort -u)
if [[ -n "$other_authors" ]]; then
  warnings+=("Commits from other authors detected - verify this is intentional:")
  for author in $other_authors; do
    warnings+=("  - $author")
  done
fi

# === OUTPUT ===
if [[ ${#errors[@]} -gt 0 ]]; then
  echo "❌ PRE-PUSH BLOCKED:" >&2
  for err in "${errors[@]}"; do
    echo "  $err" >&2
  done
  echo "" >&2
  echo "Remove these files from your commits before pushing." >&2
  exit 2
fi

if [[ ${#warnings[@]} -gt 0 ]]; then
  echo "⚠️  PRE-PUSH WARNINGS:" >&2
  for warn in "${warnings[@]}"; do
    echo "  $warn" >&2
  done
  echo "" >&2
  echo "Review the above and ensure you're pushing the right changes." >&2
  # Don't block, just warn
fi

exit 0
