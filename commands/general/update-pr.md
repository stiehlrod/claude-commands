---
name: update-pr
description: Update the current branch's pull request title and description to accurately reflect the work done.
---

# Update PR Title and Description

Update the current branch's pull request title and description to accurately reflect the work done.

## Instructions

1. Get the current branch name and find the associated PR using `gh pr view`
2. Analyze all commits in the branch since it diverged from main:
   - Run `git log main..HEAD --oneline` to see all commits
   - Run `git diff main...HEAD --stat` to see files changed
3. Based on the commits and changes, generate:
   - A concise PR title (imperative mood, max 72 chars)
   - A detailed PR description with:
     - Summary section (2-4 bullet points of key changes)
     - If applicable, a "Breaking Changes" section
     - If applicable, a "Migration Notes" section
4. Update the PR using `gh pr edit` with the new title and description
5. Show the user the updated PR URL

## PR Description Format

```markdown
## Summary
- [Key change 1]
- [Key change 2]
- [Key change 3]

## Changes
[More detailed breakdown if needed]

## Test Plan
- [ ] Tests pass
- [ ] Manual verification completed

---
Generated with [Claude Code](https://claude.com/claude-code)
```
