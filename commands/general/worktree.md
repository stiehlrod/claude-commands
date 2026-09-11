---
name: worktree
description: Provides context about working in a git worktree branch. Use when you need to understand worktree-specific git operations.
---

# Git Worktree Context

You are working in a **git worktree branch**, not a regular branch in the main repository.

## Important Reminders

1. **Comparing branches**: When comparing this branch to main, use the full ref path or fetch first:
   ```bash
   git fetch origin main
   git log origin/main..HEAD --oneline
   git diff origin/main...HEAD --stat
   ```

2. **The main branch may not exist locally** in this worktree - always reference `origin/main`

3. **To see worktree info**:
   ```bash
   git worktree list
   ```

4. **Current branch context**: Run `git log --oneline -10` to see recent commits on THIS branch only

## Worktree Setup

After a new worktree is created, you may need to bootstrap it with any gitignored files the app needs to run (e.g. `.env`, encryption keys, IDE configs). Approaches vary by project:

- If your repo provides a setup script (commonly `bin/setup-worktree` or similar), run it on the new worktree path.
- Otherwise, manually copy any required gitignored files from the main checkout to the new worktree.
- If the project has no such files, no setup is needed.

## Before Running Git Commands

- Use `origin/main` instead of `main` for comparisons
- Don't assume the working tree has all branches available locally
- The worktree is isolated - changes here don't affect other worktrees until pushed
