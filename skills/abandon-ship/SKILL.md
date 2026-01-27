---
name: abandon-ship
description: Nuclear option - discard all changes, checkout main, and pull latest. Use when you need to start fresh.
---

# Abandon Ship

Discard all local changes and reset to the latest main branch. This is the nuclear option when you need to start completely fresh.

## Usage

- `/abandon-ship` - Reset everything and go back to main

## Steps

### 1. Warn the User

Before doing anything, warn:

> ⚠️ **WARNING**: This will permanently delete ALL uncommitted changes, stashes, and local commits not pushed to remote. This cannot be undone.
>
> Are you sure you want to abandon ship?

Use AskUserQuestion to confirm.

### 2. Reset Hard

```bash
git reset --hard
```

This discards all uncommitted changes (staged and unstaged).

### 3. Checkout Main

```bash
git checkout main
```

Switch to the main branch.

### 4. Pull Latest

```bash
git pull
```

Get the latest changes from remote.

### 5. Report Results

```
## Abandon Ship Complete

✅ Discarded all local changes
✅ Switched to main branch
✅ Pulled latest from origin

You're now on a clean main branch. Ready to start fresh!
```

## One-liner

If you want to run this manually:

```bash
git reset --hard && git checkout main && git pull
```
