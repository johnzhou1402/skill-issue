# skill-issue

Reusable [Claude Code](https://claude.ai/code) skills, hooks, and configs for developers.

## Quick Start

```bash
# Clone the repo
git clone https://github.com/johnzhou1402/skill-issue.git ~/skill-issue

# Run setup in Claude Code
/setup
```

The setup wizard will:
- Configure your preferences
- Create necessary directories
- Set up symlinks to your `~/.claude`

## What's Included

### Skills

| Skill | Description |
|-------|-------------|
| `push` | Run quality checks before pushing to current branch |
| `push-pr` | Create a PR with quality checks and proper formatting |
| `end-day` | Generate standup summaries and capture PR feedback |
| `trivia` | Quiz yourself on your codebase from PR history |
| `linear-workflow` | Structured workflow for Linear tickets |
| `checklist-manifesto` | Run personalized quality checks before pushing |
| `add-checklist-item` | Capture PR feedback as checklist items |
| `setup` | First-time configuration wizard |

### Hooks

| Hook | Description |
|------|-------------|
| `pre-push-check.sh` | Block sensitive files, warn about stacked branches |

### Config

| File | Description |
|------|-------------|
| `statusline.sh` | Show branch, PR, Linear ticket with daily emoji |

## Prerequisites

**Required:**
- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated

**Optional:**
- [Linear MCP](https://mcp.linear.app) connected (for `linear-workflow`)
- [Resend](https://resend.com) API key (for email digests)

## Manual Installation

If you prefer not to use the setup wizard:

```bash
# Clone
git clone https://github.com/johnzhou1402/skill-issue.git ~/skill-issue

# Create symlinks
ln -sf ~/skill-issue/skills/push ~/.claude/skills/push
ln -sf ~/skill-issue/skills/push-pr ~/.claude/skills/push-pr
ln -sf ~/skill-issue/skills/end-day ~/.claude/skills/end-day
ln -sf ~/skill-issue/skills/trivia ~/.claude/skills/trivia
ln -sf ~/skill-issue/skills/linear-workflow ~/.claude/skills/linear-workflow
ln -sf ~/skill-issue/skills/checklist-manifesto ~/.claude/skills/checklist-manifesto
ln -sf ~/skill-issue/skills/add-checklist-item ~/.claude/skills/add-checklist-item
ln -sf ~/skill-issue/skills/setup ~/.claude/skills/setup
ln -sf ~/skill-issue/hooks/pre-push-check.sh ~/.claude/hooks/pre-push-check.sh
ln -sf ~/skill-issue/statusline.sh ~/.claude/statusline.sh

# Create config
mkdir -p ~/.claude/skills/end-day
cat > ~/.claude/skills/end-day/config.json << 'EOF'
{
  "standup_dir": "~/standups",
  "reviews_dir": "~/pr-feedback",
  "trivia_file": "~/trivia/questions.json",
  "resend_api_key": "",
  "email_to": "",
  "email_from": "onboarding@resend.dev"
}
EOF

# Add statusline to settings
# Edit ~/.claude/settings.json and add:
# "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }
```

## Configuration

Edit `~/.claude/skills/end-day/config.json`:

```json
{
  "standup_dir": "~/standups",
  "reviews_dir": "~/pr-feedback",
  "trivia_file": "~/trivia/questions.json",
  "resend_api_key": "re_xxx",
  "email_to": "you@example.com",
  "email_from": "onboarding@resend.dev"
}
```

## Usage

```bash
# Daily workflow
/end-day              # Generate standup, capture feedback, create trivia

# Pushing code
/push                 # Quality checks + push to current branch
/push-pr              # Quality checks + create PR

# Learning
/trivia               # Random question from your PR history
/trivia stats         # See your score

# Quality
/checklist-manifesto  # Run your personalized checks
/add-checklist-item   # Add new check from PR feedback

# Linear
/linear-workflow      # Structured ticket workflow
```

## Contributing

Found a bug or have an idea? Open an issue or PR!

## License

MIT
