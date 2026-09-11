---
name: delete-all-worktrees
description: Delete all git worktrees from .claude/worktrees/. Checks each for uncommitted changes, unpushed commits, and unmerged PRs before deleting.
---

# Delete All Worktrees

Delete all git worktrees from `.claude/worktrees/`.

## Instructions

1. **List all worktrees registered under `.claude/worktrees/`** using the machine-parseable porcelain format. `git worktree list` returns absolute paths, so resolve the target prefix to its absolute form before matching:
   ```bash
   ABS_PREFIX="$(pwd)/.claude/worktrees/"
   git worktree list --porcelain | awk -v prefix="$ABS_PREFIX" '
     $1 == "worktree" && index($2, prefix) == 1 { print $2 }
   '
   ```
   If none found, inform the user and stop.

2. **For each worktree**, run safety checks:

   a. **Uncommitted changes**:
   ```bash
   git -C "$WORKTREE" status --porcelain
   ```

   b. **Unpushed commits** (compare to remote tracking branch):
   ```bash
   git -C "$WORKTREE" log --oneline @{u}..HEAD 2>/dev/null
   ```
   If no upstream, check if any commits exist beyond origin/main:
   ```bash
   git -C "$WORKTREE" log --oneline origin/main..HEAD
   ```

   c. **PR merge status**:
   ```bash
   BRANCH=$(git -C "$WORKTREE" branch --show-current)
   gh pr view "$BRANCH" --json state -q '.state' 2>/dev/null
   ```

3. **Present a summary table** to the user showing each worktree and its status:
   - Worktree name
   - Branch name
   - Uncommitted changes (yes/no)
   - Unpushed commits (count or none)
   - PR status (merged/open/closed/none)
   - Safe to delete? (yes/no)

4. **If any worktrees have safety issues**, list them and ask the user for confirmation before proceeding. The user can choose to:
   - Delete all anyway
   - Delete only the safe ones
   - Cancel

5. **Delete the confirmed worktrees**:
   ```bash
   git worktree remove "<path>" --force
   ```

6. **Delete branches** for removed worktrees:
   ```bash
   git branch -d <branch-name> 2>/dev/null || git branch -D <branch-name>
   ```

7. **Prune stale worktree metadata**:
   ```bash
   git worktree prune
   ```

8. **Report the result** — how many worktrees were deleted, any that were skipped.
