---
name: start-ticket
description: Create a branch from a GitHub issue in the current worktree, then plan the implementation. Use when starting work on a ticket in an existing worktree. Pass a GitHub issue URL or number as argument.
argument-hint: '<issue URL or number>'
---

# Start Ticket

Create a new branch off main for a GitHub issue in the **current worktree**, then run `/work-ticket` to plan the implementation.

This combines branch creation + implementation planning into one command. Use it when you're already in a worktree and want to start working a ticket.

## Arguments

A GitHub issue URL or number (e.g., `#215`, `215`, or `https://github.com/{owner}/{repo}/issues/215`).

## Instructions

### 1. Parse the issue

Extract the issue number from the argument (strip URL prefix, `#`, etc.).

### 2. Fetch issue details

```bash
gh issue view <number> --json number,title,state
```

Verify the issue exists and is OPEN. If closed, warn the user and ask if they want to proceed.

### 3. Derive branch name

From the issue title:

- Lowercase
- Replace spaces and special characters with hyphens
- Strip leading/trailing hyphens
- Collapse consecutive hyphens
- Truncate to ~50 chars
- Examples:
  - `"BILLING-009: Phase-based streaming UI"` → `billing-009-phase-based-streaming-ui`
  - `"Add org-level context block"` → `add-org-level-context-block`

### 4. Check current state

```bash
git branch --show-current
git status --porcelain
```

- If there are uncommitted changes, warn the user and ask how to proceed (stash, commit, or abort).
- Note the current branch name for the user's reference.

### 5. Create the branch

```bash
git fetch origin main
git checkout -b <branch-name> origin/main
```

This creates a new branch off the latest `origin/main` in the current worktree.

If the branch already exists, inform the user and ask:

- Switch to the existing branch
- Delete and recreate from latest main
- Abort

### 6. Report

Tell the user:

- The new branch name
- The issue title and number
- That you're about to plan the implementation

### 7. Plan the implementation

Now plan the implementation inline:

1. Fetch the full issue body: `gh issue view <number> --json title,body,labels`
2. Explore the codebase to understand the surrounding patterns (read related files, grep for similar features)
3. Enter plan mode (Shift+Tab) and draft an implementation plan for review

## Verify ticket references during planning

When planning (step 7), verify the ticket's references against the actual codebase before relying on them. Ticket text was sometimes written via mass cascades or architectural review and may reference fields, methods, or classes that don't exist where the ticket claims they do.

For every field/method/class the ticket says to read from or call on a specific model:

1. **Grep first.** Confirm it exists at the named location before writing code that depends on it.
2. **If it doesn't exist**, distinguish:
   - **(a) Future work** — the producer ships in a later ticket. Stub it on the current model with a `TODO(<future-ticket>):` comment and a sensible default. Proceed.
   - **(b) Wrong location** — the field exists but on a different model (often a related one accessed via delegation, association, or a parent record). Wire the implementation to the real source; flag if the divergence is non-trivial before proceeding.
   - **(c) Genuinely missing everywhere** — file a follow-up ticket for the gap, propose where it should live, then stub and proceed.
3. **Watch for source/destination name conflation.** Snapshot columns (`*_snapshot`) are usually persistence destinations on audit / archival tables. The live SOURCE typically drops the `_snapshot` suffix and may live on a related model. If a ticket reads from a `*_snapshot` field as a SOURCE, that's suspicious — grep before implementing.

If your grep surfaces an error in the ticket text, flag it in your plan's "Ticket adjustments" section rather than silently working around it. Whoever wrote the ticket may need to update it to match codebase reality.

## Notes

- This skill assumes you're already in a worktree (or the main repo). It does NOT create a worktree — use `/create-worktree` for that.
- Always base the branch on `origin/main`, not local `main`.
- If the worktree is on a branch with uncommitted work, handle it safely before switching.
