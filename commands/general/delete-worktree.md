---
name: delete-worktree
description: Delete a specific git worktree from .claude/worktrees/. Checks for uncommitted changes, unpushed commits, and unmerged PRs before deleting.
---

# Delete Worktree

Delete a specific git worktree from `.claude/worktrees/`.

## Arguments

The user must provide a worktree name (the directory name inside `.claude/worktrees/`).

## Instructions

1. **Resolve the worktree path**:
   ```bash
   WORKTREE=".claude/worktrees/<name>"
   ABS_WORKTREE="$(pwd)/$WORKTREE"
   ```

2. **Verify it exists** using the machine-parseable porcelain format. `git worktree list` returns absolute paths, so match against the absolute path rather than substring-grepping the relative form:
   ```bash
   git worktree list --porcelain | awk -v target="$ABS_WORKTREE" '
     $1 == "worktree" && $2 == target { found = 1 }
     END { exit !found }
   '
   ```
   If the command exits non-zero, inform the user the worktree is not registered and stop.

3. **Check for safety issues** (run all checks from inside the worktree):

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

   c. **PR merge status** (check if a PR exists and whether it's merged):
   ```bash
   BRANCH=$(git -C "$WORKTREE" branch --show-current)
   gh pr view "$BRANCH" --json state -q '.state' 2>/dev/null
   ```

4. **If any safety issues found**, report them clearly to the user and ask for confirmation before proceeding. List each issue found.

5. **If safe or user confirms**, delete the worktree:
   ```bash
   git worktree remove "$WORKTREE" --force
   ```

6. **Delete the branch** if it's fully merged or user confirms:
   ```bash
   git branch -d <branch-name> 2>/dev/null || git branch -D <branch-name>
   ```

7. **Prune stale worktree metadata**:
   ```bash
   git worktree prune
   ```

8. **Report the result** to the user.
