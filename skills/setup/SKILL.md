---
name: setup
description: Configure skill-issue for first-time setup
---

# Setup

First-time setup wizard for skill-issue. Walks you through configuring each skill.

## Usage

- `/setup` - Run the setup wizard

## Prerequisites Check

Before starting, verify:

```bash
# Check gh CLI
gh --version

# Check gh auth
gh auth status
```

**Required:**
- `gh` CLI installed and authenticated

**Optional:**
- Linear connected (for linear-workflow skill)

If gh is not set up:
```
❌ GitHub CLI (gh) is required but not found.

Install it:
  brew install gh
  gh auth login

Then run /setup again.
```

## Setup Flow

### Welcome

```
Welcome to skill-issue! 👋

This wizard will help you configure your skills.
Each skill is optional - skip any you don't need.

Let's get started!
```

### 1. Standup & End-of-Day

```
📝 STANDUPS & END-OF-DAY

The end-day skill generates daily PR summaries for standups,
captures PR feedback, and builds trivia questions from your work.

Enable standups? [y/n]: y

Where should standup files be saved?
Default: ~/standups
> [user input or enter for default]

Where should PR feedback be saved?
Default: ~/pr-feedback
> [user input or enter for default]

✅ Standup configured!
   Standups: ~/standups
   Feedback: ~/pr-feedback
```

If user says no:
```
⏭️  Skipping standup setup. You can run /setup again later.
```

### 2. Trivia

```
🎯 TRIVIA

Learn your codebase through quiz questions generated from your PRs.
Questions are created by the end-day skill.

Enable trivia? [y/n]: y

Where should trivia questions be stored?
Default: ~/trivia/questions.json
> [user input or enter for default]

✅ Trivia configured!
   Questions: ~/trivia/questions.json
```

### 3. Checklist Manifesto

```
📋 CHECKLIST MANIFESTO

Auto-check for small nits before pushing, based on PR feedback you've received.
Add items with /add-checklist-item.

Enable checklist checks? [y/n]: y

✅ Checklist manifesto enabled!
   Items stored in: ~/.claude/skills/checklist-manifesto/items/

   Tip: Run /add-checklist-item <PR URL> to add your first check.
```

### 4. Status Line

```
🎨 STATUS LINE

Show git branch, PR number, and Linear ticket in your Claude Code status bar.
Includes a daily rotating emoji!

Enable status line? [y/n]: y

✅ Status line enabled!
   Restart Claude Code to see it.
```

### 5. Pre-Push Hook

```
🛡️ PRE-PUSH HOOK

Automatically checks for sensitive files (.env, credentials) and
warns about potential issues before pushing.

Enable pre-push hook? [y/n]: y

✅ Pre-push hook enabled!
```

### 6. Linear Integration (Optional)

```
🔗 LINEAR INTEGRATION (optional)

The linear-workflow skill helps you work on Linear tickets.
Requires Linear MCP connection.

Set up Linear? [y/n]: y

Connect Linear MCP:
1. Go to Claude Code settings
2. Add MCP server: https://mcp.linear.app/sse
3. Authenticate when prompted

Is Linear connected? [y/n]: y

✅ Linear integration enabled!
```

### 7. Email Digest (Optional)

```
📧 EMAIL DIGEST (optional)

Get end-of-day summaries emailed to you.
Requires a Resend API key.

Set up email? [y/n]: y

Enter your Resend API key:
> re_xxxxx

Enter your email address:
> you@example.com

✅ Email digest configured!
```

If no:
```
⏭️  Skipping email setup. You can configure later in:
   ~/.claude/skills/end-day/config.json
```

## Save Configuration

Write config to `~/.claude/skills/end-day/config.json`:

```json
{
  "standup_dir": "~/standups",
  "reviews_dir": "~/pr-feedback",
  "trivia_file": "~/trivia/questions.json",
  "resend_api_key": "",
  "email_to": "",
  "email_from": "onboarding@resend.dev"
}
```

## Create Symlinks

Set up symlinks from `~/.claude` to the skill-issue repo:

```bash
# Skills (only the public ones)
ln -sf ~/skill-issue/skills/push-pr ~/.claude/skills/push-pr
ln -sf ~/skill-issue/skills/push ~/.claude/skills/push
ln -sf ~/skill-issue/skills/end-day ~/.claude/skills/end-day
ln -sf ~/skill-issue/skills/trivia ~/.claude/skills/trivia
ln -sf ~/skill-issue/skills/linear-workflow ~/.claude/skills/linear-workflow
ln -sf ~/skill-issue/skills/checklist-manifesto ~/.claude/skills/checklist-manifesto
ln -sf ~/skill-issue/skills/add-checklist-item ~/.claude/skills/add-checklist-item
ln -sf ~/skill-issue/skills/setup ~/.claude/skills/setup

# Hooks
ln -sf ~/skill-issue/hooks/pre-push-check.sh ~/.claude/hooks/pre-push-check.sh

# Status line
ln -sf ~/skill-issue/statusline.sh ~/.claude/statusline.sh
```

## Configure Permissions

Auto-configure `~/.claude/settings.json` so skills can run without manual approval prompts.

### 1. Read existing settings

```bash
cat ~/.claude/settings.json 2>/dev/null || echo '{}'
```

### 2. Build permissions list

**Core permissions (always added):**

```json
[
  "Bash(gh pr *)",
  "Bash(gh api *)",
  "Bash(git log *)",
  "Bash(date *)",
  "Bash(ls *)",
  "Bash(mkdir *)",
  "Read(~/.claude/skills/**)"
]
```

**Dynamic permissions based on user's configured directories:**

For each configured path (standup_dir, reviews_dir, trivia parent dir), add Read and Write permissions:

| Config Value | Permissions Added |
|--------------|-------------------|
| `standup_dir: ~/standups` | `Read(~/standups/**)`, `Write(~/standups/**)` |
| `reviews_dir: ~/pr-feedback` | `Read(~/pr-feedback/**)`, `Write(~/pr-feedback/**)` |
| `trivia_file: ~/trivia/questions.json` | `Read(~/trivia/**)`, `Write(~/trivia/**)` |

**If paths share a common parent**, consolidate them. For example, if all paths are under `~/devmaxxing/`:

```json
[
  "Read(~/devmaxxing/**)",
  "Write(~/devmaxxing/**)"
]
```

**If email is configured:**

```json
[
  "Bash(curl -X POST *api.resend.com*)"
]
```

### 3. Merge with existing settings

- Read existing `~/.claude/settings.json`
- Get existing `permissions.allow` array (or create empty array)
- Add new permissions only if not already present (avoid duplicates)
- Preserve all other settings (statusLine, mcpServers, etc.)

### 4. Write updated settings

Write the merged settings back to `~/.claude/settings.json`.

**Example final permissions array:**

```json
{
  "permissions": {
    "allow": [
      "Bash(gh pr *)",
      "Bash(gh api *)",
      "Bash(git log *)",
      "Bash(date *)",
      "Bash(ls *)",
      "Bash(mkdir *)",
      "Read(~/.claude/skills/**)",
      "Read(~/standups/**)",
      "Write(~/standups/**)",
      "Read(~/pr-feedback/**)",
      "Write(~/pr-feedback/**)",
      "Read(~/trivia/**)",
      "Write(~/trivia/**)",
      "Bash(curl -X POST *api.resend.com*)"
    ]
  }
}
```

### 5. Confirm to user

```
🔐 PERMISSIONS CONFIGURED

Added auto-allow rules so skills run without prompts:
  ✅ GitHub CLI (gh pr, gh api)
  ✅ Git commands (git log)
  ✅ File operations in your configured directories
  ✅ Resend API (if email configured)

You can review permissions in ~/.claude/settings.json
```

## Final Summary

```
🎉 Setup complete!

Enabled:
  ✅ Standups & end-of-day (~/standups)
  ✅ Trivia (~/trivia/questions.json)
  ✅ Checklist manifesto
  ✅ Status line
  ✅ Pre-push hook
  ✅ Linear integration
  ✅ Auto-permissions (no more manual approvals!)
  ⏭️  Email digest (skipped)

Quick start:
  /end-day        - Generate today's standup
  /trivia         - Quiz yourself
  /push           - Push with quality checks
  /push-pr        - Create a PR

Restart Claude Code to activate the status line.

Happy coding! 🚀
```

## Manual Configuration

Users can also manually edit `~/.claude/skills/end-day/config.json` after setup.
