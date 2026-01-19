---
name: add-checklist-item
description: Capture PR feedback as a checklist item for future checks
---

# Add Checklist Item

Turn PR review feedback into automated checklist items. The human determines what to check for - this skill just captures and organizes it.

## Usage

- `/add-checklist-item <PR URL>` - Fetch comments from a PR and create a checklist item
- `/add-checklist-item` - Prompt for PR URL

## Flow

### 1. Get PR URL

If not provided as argument, ask:
```
What PR has the feedback you want to capture?
> [user provides URL or number]
```

Parse the PR number from URL formats like:
- `https://github.com/owner/repo/pull/1399`
- `1399`
- `#1399`

### 2. Fetch Human Comments

Get all review comments from the PR:

```bash
# Get review comments (inline code comments)
gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | {author: .user.login, body: .body, path: .path, line: .line, url: .html_url}'

# Get general review comments
gh pr view {number} --json reviews --jq '.reviews[] | {author: .author.login, body: .body, state: .state}'
```

**Filter out bots** (case-insensitive):
- vercel, linear, github-actions, sentry, cursor, seer, dependabot, renovate, copilot

### 3. Display Comments

Present comments in a numbered list:

```
Found 3 human comments on PR #1399:

[1] @baked-dev on sign-up-page.tsx:1063-1085
    "would this not be cleaner in a useMutation? everything seems
    to be handled but doing async try/catch/finally is a lot to
    read vs onMutate, onSuccess, onError, onSettled"

[2] @mike on auth-helper.ts:42
    "consider using early return here instead of nested if"

[3] @sarah on types.ts:15
    "this type should be exported from the shared package"

Which comment to capture? [1/2/3]:
```

If no human comments found:
```
No human review comments found on PR #1399.
Maybe try a different PR?
```

### 4. Get the Lesson

After user selects a comment, ask:

```
What's the lesson? What should we check for going forward?

(Describe the pattern to watch for and what to do instead)
>
```

User writes their takeaway in plain language.

### 5. Generate Name

Suggest a kebab-case name based on the lesson:

```
Suggested name: try-catch-to-react-query

Accept this name or enter a different one: [press enter to accept]
>
```

### 6. Save Checklist Item

Save to `~/.claude/skills/checklist-manifesto/items/{name}.md`:

```markdown
---
name: try-catch-to-react-query
created: 2026-01-19
source_pr: https://github.com/whopio/whop-monorepo/pull/1399
reviewer: baked-dev
---

# Try-Catch to React Query

## Pattern to Check
When you see try-catch-finally blocks in React components handling async operations.

## What to Do
Check if a React Query hook (useMutation) would be cleaner. The hook provides
onMutate, onSuccess, onError, onSettled callbacks that are easier to read than
manual try-catch-finally.

Look for similar patterns elsewhere in the codebase for reference.

## Original Comment
> would this not be cleaner in a useMutation? everything seems to be handled
> but doing async try/catch/finally is a lot to read vs onMutate, onSuccess,
> onError, onSettled

— @baked-dev on sign-up-page.tsx:1063-1085
```

### 7. Confirm

```
✅ Saved checklist item: try-catch-to-react-query

This will now be checked by /checklist-manifesto before pushing.

Add another? [y/n]:
```

## Checklist Item Format

Each item in `checklist-manifesto/items/` should have:

| Field | Purpose |
|-------|---------|
| `name` | Kebab-case identifier |
| `created` | Date added |
| `source_pr` | Where the feedback came from |
| `reviewer` | Who gave the feedback |
| **Pattern to Check** | When this check applies |
| **What to Do** | The action to take |
| **Original Comment** | The raw feedback for context |

## Tips

- Keep patterns specific and actionable
- Focus on things AI can actually detect in code
- Good: "try-catch in React components" → check for useMutation
- Bad: "make code cleaner" → too vague
