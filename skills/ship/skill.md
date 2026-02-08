---
name: ship
description: Ship changes - create branch, PR, and auto-merge in one command
---

# Ship

Ship your changes end-to-end: create a branch, open a PR, and merge it automatically.

## Usage

- `/ship` - Ship all staged/unstaged changes
- `/ship "fix login bug"` - Ship with a custom commit message

## Steps

### 1. Check for Changes

```bash
git status
```

If there are no changes (staged or unstaged), abort with a message.

### 2. Get GitHub Username

```bash
gh api user --jq '.login'
```

### 3. Create Branch Name

Generate a branch name from:
- The provided message, OR
- The nature of the changes (infer from modified files)

**Format:** `<github-username>/<short-kebab-case-description>`

Example: `johnzhou/fix-login-redirect`

### 4. Stash, Create Fresh Branch, Apply

```bash
# Stash current changes
git stash push -m "ship-temp"

# Get latest main
git checkout main
git pull origin main

# Create new branch
git checkout -b <branch-name>

# Apply changes
git stash pop
```

### 5. Stage and Commit

**Exclude these files - NEVER commit them:**
- `.claude/settings.local.json`
- `*.local.json`
- `.env*`
- `.vercel/project.json`

```bash
# Stage all relevant changes
git add -A

# Unstage any excluded files
git reset HEAD .claude/settings.local.json 2>/dev/null || true
git reset HEAD '*.local.json' 2>/dev/null || true

# Commit
git commit -m "$(cat <<'EOF'
<Commit message>

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### 6. Push and Create PR

```bash
# Push branch
git push -u origin <branch-name>

# Create PR
gh pr create --title "<PR title>" --body "$(cat <<'EOF'
## Summary
<Brief description of changes>

## Changes
<Bulleted list of what changed>

---
Generated with Claude Code
EOF
)"
```

### 7. Auto-Merge PR

```bash
# Enable auto-merge (squash)
gh pr merge --auto --squash

# Or if auto-merge is not enabled on the repo, merge directly:
gh pr merge --squash
```

**Note:** If CI is required, `--auto` will wait for checks to pass. If no CI or auto-merge isn't enabled, it merges immediately.

### 8. Clean Up

```bash
# Switch back to main
git checkout main
git pull origin main

# Delete local branch
git branch -d <branch-name>
```

### 9. Report Result

```
Shipped Successfully!
=====================

Branch: johnzhou/fix-login-redirect
PR: https://github.com/org/repo/pull/XXX
Status: Merged (or Auto-merge enabled)

You're back on main with latest changes.
```

## Quick Reference

| Step | Command | Notes |
|------|---------|-------|
| Check changes | `git status` | Abort if nothing to ship |
| Stash | `git stash push -m "ship-temp"` | Save work |
| Fresh branch | `git checkout main && git pull` | Start clean |
| Create branch | `git checkout -b <name>` | From latest main |
| Apply | `git stash pop` | Restore changes |
| Stage | `git add -A` | Stage everything |
| Commit | `git commit` | With co-author |
| Push | `git push -u origin` | Set upstream |
| Create PR | `gh pr create` | With description |
| Merge | `gh pr merge --squash` | Squash merge |
| Cleanup | `git checkout main && git pull` | Back to main |

## Flags

- `--draft` - Create as draft PR (don't auto-merge)
- `--no-merge` - Create PR but don't merge (same as `/push-pr`)

## Error Handling

**"No changes to ship"**
- Check that you have uncommitted changes with `git status`

**"Merge conflicts"**
- The stash pop may conflict. Resolve manually, then continue.

**"PR checks failing"**
- Auto-merge will wait. Check CI status with `gh pr checks`

**"Cannot merge - reviews required"**
- Repo requires reviews. PR is created but not merged.
- Get a review, then run `gh pr merge --squash`
