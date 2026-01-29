---
name: end-day
description: Auto-generate standup summaries and save PR feedback (today + catch up past 3 days)
---

# End Day

Generate standup summary, save PR feedback, and email yourself a digest. Fully automatic - just run `/end-day` with no arguments.

## Usage

- `/end-day` - Process today + catch up on any missing days from the past 3 days

## Configuration

Read paths from `~/.claude/skills/end-day/config.json`:

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

If config doesn't exist, prompt user to run `/setup` first.

## Steps

### 0. Pull latest skill-issue

Before anything else, pull the latest version of skill-issue to ensure we have the most up-to-date skills:

```bash
cd ~/.claude/skills && git pull
```

If this fails (e.g., uncommitted changes), warn the user but continue with the rest of the workflow.

### 1. Determine time windows (timezone-aware)

Get the user's local timezone and calculate UTC cutoffs for today and past 3 days:

```bash
# Get timezone
date +%Z  # e.g., EST, PST

# Get local date
LOCAL_DATE=$(date +%Y-%m-%d)

# Calculate UTC offset (EST = -5, PST = -8, etc.)
# Midnight local time converted to UTC = start of that day for PR filtering
```

**Calculate UTC cutoffs for each day:**

| Day | Local Midnight | UTC Equivalent (EST example) |
|-----|----------------|------------------------------|
| Today | Jan 7 00:00 EST | Jan 7 05:00 UTC |
| Yesterday | Jan 6 00:00 EST | Jan 6 05:00 UTC |
| 2 days ago | Jan 5 00:00 EST | Jan 5 05:00 UTC |
| 3 days ago | Jan 4 00:00 EST | Jan 4 05:00 UTC |

### 2. Check which days need processing

For each of the past 3 days + today, check if output files exist and are complete:

```bash
# Check if standup file exists and has content
ls {standup_dir}/YYYY-MM-DD.md

# Check if daily review file exists
ls {reviews_dir}/daily/YYYY-MM-DD.md
```

**A day needs processing if:**
- Standup file is missing
- Standup file exists but has 0 PRs (empty day that might now have PRs)
- Review file is missing when there were PRs with human feedback

### 3. Get PRs from GitHub for all days that need processing

```bash
# Get all recent PRs (covers past 3 days + today)
gh pr list --author @me --state all --limit 100 --json number,title,headRefName,updatedAt,state,isDraft,reviewDecision,url
```

**Filter PRs by day using UTC timestamps:**

For each day that needs processing, filter PRs where:
- `updatedAt >= [day's midnight in UTC]` AND
- `updatedAt < [next day's midnight in UTC]`

**Today is special:** Filter `updatedAt >= [today's midnight UTC]` with no upper bound (up to current time).

### 4. Generate Standup Summary (for each day that needs processing)

For each PR, gather context and write a leadership-friendly summary:

```bash
# PR details
gh pr view <number> --json title,body,state,isDraft,reviewDecision,statusCheckRollup

# Commits on this branch
git log main..<branch> --no-merges --oneline
```

**Status mapping:**

- `state=MERGED` → 🟢 **Merged**
- `state=CLOSED` → 🔴 **Closed**
- `isDraft=true` → ⚪ **Draft**
- `reviewDecision=CHANGES_REQUESTED` → 🟠 **Changes Requested**
- `reviewDecision=APPROVED` + CI passing → 🟢 **Ready to Merge**
- `reviewDecision=REVIEW_REQUIRED` → 🟡 **Ready for Review**

**For each PR, write:**

- **What**: 1-2 sentence business impact (not technical details)
- **Status**: From mapping above
- **Next**: What happens next?

**Writing style:**

- Lead with impact, not implementation
- No jargon - your manager should understand it
- Bad: "Added a migration to store plaid balances"
- Good: "Creators can now see their real bank balance when setting up payouts"

Write to `{standup_dir}/YYYY-MM-DD.md`

### 5. Save PR Feedback

For each PR with human review comments:

```bash
# General reviews
gh pr view <number> --json reviews,comments

# Inline code comments
gh api repos/{owner}/{repo}/pulls/<number>/comments
```

**Filter to human reviewers only** (ignore bots: vercel, linear, github-actions, sentry, cursor, seer)

For each human comment, extract and analyze:

- Reviewer name
- File path and line numbers (if inline)
- Comment text
- **Intention**: What is the reviewer really asking for?
- **Category**: Style | Logic | Performance | Security | Testing | Naming | Architecture
- **Lesson**: What general principle can you learn?

Write to `{reviews_dir}/daily/YYYY-MM-DD.md`

### 6. Append to Feedback History

Also append each comment to the persistent history file `{reviews_dir}/history.md`.

**Format for history file:**

```markdown
## YYYY-MM-DD

### PR #123 - PR Title
**From**: reviewer
**Category**: Architecture
**File**: path/to/file.rb:42

> "The actual comment text"

**Lesson**: What you learned from this feedback.

---
```

**Rules:**
- Only append NEW comments (check if PR # + reviewer + comment already exists)
- Add a date header if this is the first entry for that date
- Keep chronological order (newest at bottom)

### 7. Generate Trivia Questions

For each human review comment (from step 5), generate one trivia question based on the lesson learned.

**Transform feedback into questions:**

Take the lesson you extracted from each comment and turn it into a question that tests whether you've internalized the feedback.

**Examples:**

| Comment | Lesson | Trivia Question | Answer |
|---------|--------|-----------------|--------|
| "Use decimal, not float for money" | Financial columns need decimal precision | "What database type should be used for financial columns?" | "decimal with precision 10, scale 2 - never float (precision issues)" |
| "This should be async" | Slack webhooks shouldn't block requests | "Should Slack webhook calls use process_inline?" | "No - remove process_inline to make it async and not block the request" |
| "Add company_id argument" | Don't use deprecated context[:current_company] | "How should mutations get the current company?" | "Via explicit company_id argument, not context[:current_company] (deprecated)" |

**Save to `{trivia_file}`:**

```json
{
  "questions": [
    {
      "id": "q-2026-01-07-001",
      "question": "What database type should be used for financial columns?",
      "answer": "decimal with precision 10, scale 2 - never float (precision issues)",
      "system": "database_patterns",
      "source_pr": "PR #612",
      "source_file": "backend/db/migrate/xxx.rb",
      "reviewer": "jackson",
      "added_date": "2026-01-07",
      "times_asked": 0,
      "times_correct": 0
    }
  ]
}
```

**Rules:**
- One question per human comment (not per PR)
- Only from merged PRs
- Skip trivial comments (typos, formatting nits)
- Question should test the principle, not the specific code
- Don't duplicate existing questions (check by similarity)

### 8. Send Email Digest (if configured)

Read config from `~/.claude/skills/end-day/config.json`. If `resend_api_key` is empty, skip email.

```json
{
  "resend_api_key": "re_xxx",
  "email_to": "you@email.com",
  "email_from": "onboarding@resend.dev"
}
```

Send email via Resend API:

```bash
curl -X POST 'https://api.resend.com/emails' \
  -H 'Authorization: Bearer <resend_api_key>' \
  -H 'Content-Type: application/json' \
  -d '{
    "from": "<email_from>",
    "to": "<email_to>",
    "subject": "🌙 End of Day: YYYY-MM-DD",
    "html": "<email_content>"
  }'
```

**Email style:**

- Use emojis liberally (🌙 🟢 🟡 🟠 🔴 💬 💡 ⏳ 📝)
- Casual, easy-to-read tone
- Status colors: 🟢 Merged, 🟡 Ready for Review, 🟠 Changes Requested, 🔴 Closed
- Card-style layout with rounded backgrounds for each PR
- Quote blocks for reviewer comments
- "💡 Takeaway:" for lessons learned

**Email structure:**

```text
🌙 End of Day: [Day of week], [Date]

📋 What I worked on (N PRs)
  - [emoji] PR Title
    Status: ...
    [casual 1-2 sentence summary]
    [next step indicator]

💬 Feedback I got (N comments)
  - [reviewer] on PR #X
    "[quoted comment]"
    💡 Takeaway: [lesson]
```

### 9. Report Summary

Print to terminal:

```text
End of day complete for YYYY-MM-DD

Standup:
  - N PRs summarized
  - Saved to {standup_dir}/YYYY-MM-DD.md

Feedback:
  - N human comments saved
  - Saved to {reviews_dir}/daily/YYYY-MM-DD.md
  - Appended N new comments to {reviews_dir}/history.md

Trivia:
  - N new questions generated
  - Total questions in bank: M
  - Saved to {trivia_file}

Email sent to you@email.com ✓
```
