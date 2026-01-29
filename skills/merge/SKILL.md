---
name: merge
description: Safely merge a PR after verifying migrations and deploy requests
---

# Merge

Safely merge a PR by verifying database migrations are properly handled before merging. This prevents the common mistake of merging PRs with migrations that haven't been deployed to PlanetScale.

## Usage

- `/merge` - Verify migrations and merge current PR
- `/merge <pr-number>` - Verify and merge a specific PR

## Steps

### 1. Identify the PR

```bash
# Get current branch
git rev-parse --abbrev-ref HEAD

# Get PR number for current branch
gh pr view --json number -q '.number'
```

If no PR exists for current branch, stop and inform the user.

### 2. Check for Migration Files

```bash
# Check if PR has any migration files
gh pr diff --name-only | grep -E '^backend/db/migrate/.*\.rb$'
```

If **no migration files** found, skip to Step 6 (no deploy request needed).

### 3. Verify schema.rb is Updated

If migration files exist:

```bash
# Check if schema.rb is also in the diff
gh pr diff --name-only | grep -E '^backend/db/schema\.rb$'
```

**If schema.rb is NOT in the diff but migrations are:**

```
## Migration Check Failed

You have migration files but schema.rb wasn't updated.

### Problem
- Migration files found: `db/migrate/20260128220939_add_something.rb`
- But `db/schema.rb` is not in the PR diff

### Fix
1. Run `rails db:migrate` locally
2. Commit the updated `schema.rb`
3. Push to the PR
4. Run `/merge` again
```

**STOP here - do not proceed.**

### 4. Check for PlanetScale Deploy Requests

If migrations exist and schema.rb is updated, check the PR comments for deploy request links:

```bash
# Get PR comments mentioning deploy requests
gh pr view --json comments -q '.comments[].body' | grep -i "deploy request"
```

Look for:
- Staging deploy request URL
- Prod deploy request URL

### 5. Ask for Deploy Confirmation

Present the user with deploy request status and ask for confirmation:

```
## Migration Deployment Check

This PR contains database migrations.

### Deploy Requests Found
- Staging: https://app.planetscale.com/whop/whop-staging/deploy-requests/123
- Prod: https://app.planetscale.com/whop/whop/deploy-requests/456

### Before merging, confirm:
1. Have you approved and merged the **staging** deploy request?
2. Have you approved and merged the **prod** deploy request?
3. Did you **skip the revert period** on prod?

Type "yes" to confirm you've completed all deploy steps.
```

Use `AskUserQuestion` tool to get confirmation. **Do not proceed until user confirms.**

If no deploy request comments found:

```
## Warning: No Deploy Requests Found

This PR has migrations but I couldn't find deploy request links in the PR comments.

Possible reasons:
1. CI hasn't run yet - wait for CI to complete
2. schema.rb wasn't changed - run `rails db:migrate` and commit
3. Deploy requests failed to create - check CI logs

### Actions
- Check the PR's CI status for "staging db migrations" and "prod db migrations" jobs
- Look for deploy request links in CI output or PR comments

Type "yes" if you've verified deploy requests are merged, or "no" to abort.
```

### 6. Merge the PR

Only after confirmation (or if no migrations):

```bash
gh pr merge --squash --delete-branch
```

### 7. Report Results

```
## Merge Complete

PR #123 has been merged to main.

### Summary
- Branch: john/add-user-indexes
- Migrations: 1 file(s)
- Deploy requests: Confirmed merged
- Merge method: Squash

The branch has been deleted.
```

Or if aborted:

```
## Merge Aborted

PR was not merged. Please complete the deploy request steps first:

1. Go to PlanetScale and approve/merge the deploy requests
2. Skip the revert period on prod
3. Run `/merge` again
```

## Quick Reference

| Check | Required? | Action if Failed |
|-------|-----------|------------------|
| PR exists | Yes | Stop - create PR first |
| Migrations present | Check | If yes, verify schema.rb |
| schema.rb updated | If migrations | Stop - run `rails db:migrate` |
| Deploy requests | If migrations | Ask user to confirm merged |
| User confirmation | If migrations | Stop - wait for confirmation |

## Important Rules

1. **NEVER merge with migrations unless user confirms deploy requests are done**
2. **NEVER merge if schema.rb is missing when migrations exist**
3. **Always use squash merge** - keeps history clean
4. **Delete branch after merge** - keeps repo clean
5. **This skill exists because forgetting to deploy causes production issues**

## Why This Skill Exists

PlanetScale requires deploy requests to be approved and merged BEFORE the code PR is merged. If you merge code with migrations before the deploy request:

1. The migration file exists in main
2. But PlanetScale doesn't have the schema change
3. Deploy fails or the app crashes because it expects tables/columns that don't exist

This skill prevents that by requiring explicit confirmation that deploy requests are done.
