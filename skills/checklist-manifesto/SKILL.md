---
name: checklist-manifesto
description: Run parallel quality checks before pushing code
---

# Checklist Manifesto

Pre-push quality gate that runs your personalized checklist items. Items are small, trivial checks based on real PR feedback you've received.

## Usage

- `/checklist-manifesto` - Run all applicable checks on your changes
- `/checklist-manifesto list` - List all checklist items

## How It Works

1. Reads checklist items from `~/.claude/skills/checklist-manifesto/items/`
2. Gets your changed files
3. For each item, checks if the pattern applies
4. Reports findings

## Execution Steps

### 1. Load Checklist Items

Read all `.md` files from the `items/` directory:

```bash
ls ~/.claude/skills/checklist-manifesto/items/*.md
```

Parse each file to extract:
- Name (from frontmatter)
- Pattern to check (what triggers this check)
- What to do (the advice)

If no items found:
```
No checklist items yet!

Add items from your PR feedback:
  /add-checklist-item <PR URL>
```

### 2. Get Changed Files

Identify what files have changed:

```bash
# Changes not yet pushed
git diff --name-only origin/$(git branch --show-current)..HEAD 2>/dev/null || \
git diff --name-only HEAD~1
```

Also get the actual diff content for pattern matching:

```bash
git diff origin/$(git branch --show-current)..HEAD 2>/dev/null || \
git diff HEAD~1
```

### 3. Match Patterns to Changes

For each checklist item, determine if it applies based on:
- File paths changed (e.g., "React components" → `*.tsx` files)
- Code patterns in the diff (e.g., "try-catch-finally" in the diff)

### 4. Run Applicable Checks

For each applicable item, analyze the changed code:

1. Read the relevant files
2. Look for the pattern described in the checklist item
3. Determine if the advice applies

**Run checks in parallel** using multiple Task tool calls when there are multiple applicable items.

### 5. Report Findings

Output a summary:

```
## Checklist Manifesto Results

Checked 3 items against 5 changed files

### ✅ try-catch-to-react-query
No try-catch-finally blocks found in React components.

### ⚠️ early-return-pattern
Found nested if statements in auth-helper.ts:42-58
→ Consider using early return pattern for readability

### ✅ export-shared-types
All new types are properly exported.

---
1 suggestion found. Review before pushing.
```

Or if all clear:

```
## Checklist Manifesto Results

Checked 3 items against 5 changed files

✅ All checks passed!

Safe to push.
```

## List Mode

`/checklist-manifesto list` shows all items:

```
## Your Checklist Items

1. try-catch-to-react-query
   Pattern: try-catch-finally in React components
   Source: PR #1399, @baked-dev

2. early-return-pattern
   Pattern: Deeply nested if statements
   Source: PR #1245, @mike

3. export-shared-types
   Pattern: New type definitions
   Source: PR #1301, @sarah

Total: 3 items

Add more with: /add-checklist-item <PR URL>
```

## Item File Format

Items in `items/` follow this format:

```markdown
---
name: item-name
created: 2026-01-19
source_pr: https://github.com/owner/repo/pull/123
reviewer: username
---

# Item Name

## Pattern to Check
[When this check applies - file types, code patterns, etc.]

## What to Do
[The advice - what to look for, what to change]

## Original Comment
> [The original reviewer comment]

— @reviewer on file.tsx:123
```

## Adding Items

Use `/add-checklist-item` to add new items from PR feedback. This ensures all checklist items are grounded in real feedback you've received.

## Philosophy

Checklist items should be:
- **Trivial**: Small nits, not architectural decisions
- **Specific**: Clear pattern to match
- **Actionable**: AI can actually check for it
- **Personal**: Based on feedback YOU received

Bad items:
- "Make code cleaner" (too vague)
- "Refactor to use better architecture" (not trivial)

Good items:
- "Use useMutation instead of try-catch-finally in React"
- "Use early return instead of nested if statements"
- "Export types from shared package, not local files"
