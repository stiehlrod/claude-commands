---
name: wrap-ticket
description: Pre-merge skill that wraps up your work on a ticket — documents the implementation on the linked GitHub issue, posts pivots/changes made during development, and adds "Closes #N" to the PR body so GitHub auto-closes the issue when the PR merges. Does NOT merge the PR itself.
argument-hint: "<issue number or URL>"
---

# Wrap Ticket (Pre-Merge)

Document the implementation on the linked GitHub issue and connect it to the PR. Run this **before merging** — it wraps up your side of the work; the actual issue closure happens automatically when the PR merges.

## Usage

```
/wrap-ticket 191
/wrap-ticket https://github.com/{owner}/{repo}/issues/191
```

If no argument is provided, attempt to detect the issue from:
1. The PR body (look for `#NNN` references or `Closes #NNN`)
2. The branch name (e.g., `BILLING-001` in branch name -> search issues)
3. Ask the user if none found

---

## Instructions

### Step 1: Gather Context

Run these commands **in parallel**:

```bash
# Branch and PR info
git branch --show-current
gh pr view --json number,title,body,url

# Determine the branch base. Prefer merge-base against origin/main (reliable
# after rebases and across worktrees). Fall back to the oldest reflog entry
# only if merge-base isn't available (e.g., shallow clone with no main ref).
BASE=$(git merge-base origin/main HEAD 2>/dev/null \
       || git reflog show HEAD --format='%H' | tail -1)

# Guard against the rare case where both methods fail — using an empty BASE
# would produce malformed `git log ..HEAD` syntax.
if [ -z "$BASE" ]; then
  echo "Could not determine branch base. Check git state (shallow clone? missing origin/main? corrupt reflog?)." >&2
  exit 1
fi

# All commits in this branch
git log --oneline --reverse "$BASE"..HEAD

# Files changed
git diff "$BASE"..HEAD --stat
```

Read the issue:
```bash
gh issue view <NUMBER> --json title,body,url
```

### Step 2: Build the Implementation Plan Comment

Analyze the commits and changed files to write a **concise implementation plan** that documents what was actually built. This is the canonical record of the work.

#### Structure

```markdown
## Implementation Plan

**PR:** #<pr-number>
**Branch:** `<branch-name>`

### 1. [Component/Layer Name] (`path/to/key/file.rb`)

- What was added/changed and why
- Key design decisions (associations, validations, patterns used)
- Constants, configuration, or schema details worth noting

### 2. [Next Component] (`path/to/file`)

- ...

### 3. [Tests] (`spec/path/to/spec.rb`)

- What's covered: validations, scopes, edge cases, etc.
- Approximate line count if substantial
```

#### Rules for the Implementation Plan

- **Be specific**: name classes, methods, columns, indexes — not vague descriptions
- **Be concise**: 1-2 bullets per component, not paragraphs
- **Group logically**: by layer (migration, model, service, controller, views, tests) or by feature area
- **Include key decisions**: patterns chosen, tradeoffs made, scope boundaries
- **Skip boilerplate**: don't document obvious Rails conventions (timestamps, etc.)

### Step 3: Detect and Document Pivots

Compare the original issue requirements (from Step 1) against what was actually built. Look for:

1. **Scope changes** — features added or deferred vs. the original ticket
2. **Design pivots** — different approach than what was specified (e.g., JSONB instead of separate table)
3. **Review-driven changes** — fixes from code review or review pipeline (security, auth, design, test improvements)
4. **Discovered requirements** — things not in the ticket that turned out to be necessary

If there are **meaningful pivots** (not trivial tweaks), write a separate follow-up comment:

```markdown
## Implementation Notes — Deviations & Additions

### Changes from Original Plan

1. **[What changed]** — [Why]
   - Original: [what the ticket said]
   - Actual: [what was built instead]

2. **[Added scope]** — [Why it was necessary]

### Review Pipeline Fixes

If a review pipeline was run, summarize fixes:

| Review | Issues | Key Fix |
|--------|--------|---------|
| [Review name] | N | [One-line summary] |

### Deferred Items

- [Anything explicitly punted to a follow-up ticket, with ticket ref if created]
```

**Skip this comment entirely** if implementation matched the ticket exactly.

### Step 4: Link the Issue from the PR

1. Read the current PR body
2. Check if it already contains `Closes #N`, `Fixes #N`, or `Resolves #N` for this issue
3. If not, append to the PR body:

```markdown

## Linked Issue

Closes #<issue-number>
```

Use `gh pr edit <pr-number> --body "..."` to update.

### Step 5: Post the Comments

Post comments in order:

```bash
# 1. Implementation plan (always)
gh issue comment <NUMBER> --body "$(cat <<'PLAN_EOF'
...implementation plan...
PLAN_EOF
)"

# 2. Pivots/changes (only if meaningful deviations exist)
gh issue comment <NUMBER> --body "$(cat <<'PIVOT_EOF'
...pivot notes...
PIVOT_EOF
)"
```

### Step 6: Post Review Reports to PR

Post the contents of `.claude/reviews/<branch-name>/` as comments **on the PR** (not the issue) for historical documentation.

1. **Check if the reviews directory exists**:
   ```bash
   BRANCH=$(git branch --show-current)
   REVIEWS_DIR=".claude/reviews/$BRANCH"
   ls "$REVIEWS_DIR" 2>/dev/null
   ```
   If it doesn't exist, skip this step entirely.

2. **Post top-level files as one comment**: Read all `.md` files directly in `$REVIEWS_DIR` (not in subdirectories). Concatenate them in sorted order with `---` separators between files. Post as a single PR comment with a heading like `## Review Pipeline Reports`.

3. **Post each subfolder as a separate comment**: For each subdirectory (e.g., `run-1/`, `run-2/`), read all `.md` files in that subfolder, concatenate in sorted order with `---` separators, and post as a separate PR comment with a heading like `## Review Pipeline Reports (run-1)`.

4. **Use temp files** to avoid heredoc escaping issues:
   ```bash
   # Write concatenated content to a temp file
   # Then post:
   gh pr comment <PR_NUMBER> --body-file /tmp/review_comment.md
   ```

5. **Order**: Post top-level first, then subfolders in sorted order.

### Step 7: Report to User

Print a summary:

```
Done. Issue #<N> documented and linked.

- Implementation plan: <comment URL>
- Pivots/changes: <comment URL or "none — matched ticket">
- Review reports: <N comments posted to PR or "no reviews found">
- PR link: <PR URL> (Closes #<N>)
```

---

## Important Notes

- **Idempotent**: If the implementation plan comment already exists (check existing comments first with `gh api repos/{owner}/{repo}/issues/{number}/comments`), ask the user before posting a duplicate
- **Don't over-document**: The issue comment is a summary, not a design doc. Engineers will read the PR diff for details.
- **Pivots are valuable**: These comments create an audit trail of _why_ the implementation diverged from the plan. Future engineers reading the ticket will understand the context.
- **Use conventional references**: Always use `#NNN` format for cross-references so GitHub auto-links them
