---
name: sync-permissions
description: Review captured commands and promote to permanent permissions
---

# Sync Permissions

Review commands you've run and add them as permanent permissions in skill-issue.

## Usage

- `/sync-permissions` - Review and promote captured commands

## How It Works

1. The `capture-commands.sh` hook logs every Bash command you run
2. This skill reads the log and compares against `permissions.json`
3. Shows you new commands not yet in your permanent permissions
4. Lets you select which ones to add

## Steps

### 1. Read Command Log

```bash
cat ~/skill-issue/command-log.jsonl 2>/dev/null | tail -100
```

### 2. Read Current Permissions

```bash
cat ~/skill-issue/permissions.json
```

### 3. Find New Patterns

For each logged command:
1. Extract the base command pattern (e.g., `npm run *`, `git checkout *`)
2. Check if it matches any existing permission in `permissions.json`
3. Collect unmatched patterns

### 4. Present Options

```
📋 NEW COMMANDS FOUND

These commands aren't in your permanent permissions yet:

  1. pnpm build
  2. docker compose up
  3. bin/rails console

Select which to add (comma-separated, or 'all', or 'skip'):
> 1,2
```

### 5. Generate Permission Patterns

Convert specific commands to glob patterns:
- `pnpm build` → `"Bash(pnpm *)"`
- `docker compose up` → `"Bash(docker compose *)"`
- `bin/rails console` → `"Bash(bin/rails *)"`

**Pattern rules:**
- Use `*` for arguments
- Keep the base command specific
- Group related commands (e.g., all `docker compose` variants)

### 6. Update permissions.json

Add new permissions to `~/skill-issue/permissions.json`:

```bash
# Read, add, write back
jq '.allow += ["Bash(pnpm *)", "Bash(docker compose *)"]' ~/skill-issue/permissions.json > /tmp/perms.json
mv /tmp/perms.json ~/skill-issue/permissions.json
```

### 7. Clear Processed Commands

```bash
# Clear the log after processing
> ~/skill-issue/command-log.jsonl
```

### 8. Report

```
✅ PERMISSIONS UPDATED

Added to ~/skill-issue/permissions.json:
  + Bash(pnpm *)
  + Bash(docker compose *)

Next steps:
  - Commit changes: cd ~/skill-issue && git add -A && git commit -m "Add permissions"
  - Sync to settings: /setup
```

## Quick Reference

| File | Purpose |
|------|---------|
| `~/skill-issue/command-log.jsonl` | Captured commands (from hook) |
| `~/skill-issue/permissions.json` | Permanent permissions (source of truth) |
| `~/.claude/settings.json` | Active permissions (synced via /setup) |

## Enabling the Hook

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/skill-issue/hooks/capture-commands.sh"
          }
        ]
      }
    ]
  }
}
```

Or run `/setup` which will configure this automatically.
