---
name: setup
description: Configure claude-skills for first-time setup
---

# Setup

First-time setup wizard for claude-skills. Walks you through configuring each skill.

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
Welcome to claude-skills! 👋

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

Set up symlinks from `~/.claude` to the claude-skills repo:

```bash
# Skills (only the public ones)
ln -sf ~/claude-skills/skills/push-pr ~/.claude/skills/push-pr
ln -sf ~/claude-skills/skills/push ~/.claude/skills/push
ln -sf ~/claude-skills/skills/end-day ~/.claude/skills/end-day
ln -sf ~/claude-skills/skills/trivia ~/.claude/skills/trivia
ln -sf ~/claude-skills/skills/linear-workflow ~/.claude/skills/linear-workflow
ln -sf ~/claude-skills/skills/checklist-manifesto ~/.claude/skills/checklist-manifesto
ln -sf ~/claude-skills/skills/add-checklist-item ~/.claude/skills/add-checklist-item
ln -sf ~/claude-skills/skills/setup ~/.claude/skills/setup

# Hooks
ln -sf ~/claude-skills/hooks/pre-push-check.sh ~/.claude/hooks/pre-push-check.sh

# Status line
ln -sf ~/claude-skills/statusline.sh ~/.claude/statusline.sh
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
