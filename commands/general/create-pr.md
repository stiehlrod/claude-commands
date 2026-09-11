---
name: create-pr
description: Create a new pull request for the current branch. Generates title and description based on commits and changes.
---

# Create Pull Request

Create a new pull request for the current branch. This skill is a shortcut that bundles **commit any pending work** + **create the PR** into one command.

## Instructions

1. **Check prerequisites**:
   - Get current branch name: `git branch --show-current`
   - Check if PR already exists: `gh pr view 2>/dev/null`. If a PR already exists, inform the user and suggest using `/update-pr` instead. **Stop here.**

2. **Commit any uncommitted changes** (if `git status --porcelain` is non-empty):
   - Inspect modified and untracked files: `git status --short` and `git ls-files --others --exclude-standard`
   - Check for secrets or sensitive data in changed files (API keys, passwords, tokens, `.env` files, credentials). Warn the user and stop if any are detected.
   - Clean up debug statements in changed files (`puts`, `p`, `binding.pry`, `byebug`, `console.log`, `debugger`, etc.) — but only ones that look like temporary debugging output, not legitimate logging.
   - Run linters against the changed files only (e.g., `bundle exec rubocop <files>`, `yarn eslint <files>`). Fix any auto-fixable offenses; surface the rest to the user before committing.
   - Commit all changed files in logical, related groups using conventional commit messages (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `perf:`, `chore:` — with scope when meaningful, e.g. `feat(billing): ...`). Use `git add <specific paths>` for each group rather than `git add -A`. Match the repository's existing commit-message style (run `git log origin/main --oneline -10` to confirm).
   - If there are no uncommitted changes, skip this step.

3. **Gather context**:
   - Get commits since main: `git log origin/main..HEAD --oneline`
   - Get files changed: `git diff origin/main...HEAD --stat`

4. **Generate PR content**:
   - **Title**: Concise, imperative mood, max 72 chars (e.g., "Add user authentication flow")
   - **Description**: Follow the format below

5. **Create the PR**:
   ```bash
   gh pr create --title "Title here" --body "$(cat <<'EOF'
   ... description ...
   EOF
   )"
   ```

6. **Return the PR URL** to the user
7. **Run `/coderabbit`** to address any CodeRabbit review comments (and `/coderabbit-deferred` afterward to catch anything deferred)

## PR Description Format

```markdown
## Summary
- [Key change 1]
- [Key change 2]
- [Key change 3]

## Changes
[Brief description of what was done and why]

## Test Plan
- [ ] Tests pass locally
- [ ] Manual testing completed

---
Generated with [Claude Code](https://claude.com/claude-code)
```

## Notes

- If the branch hasn't been pushed, push it first with `git push -u origin <branch>`
- Default base branch is `main` unless specified otherwise
- Ask the user if they want to add reviewers or labels
