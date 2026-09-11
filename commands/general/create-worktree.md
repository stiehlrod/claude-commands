---
name: create-worktree
description: Create a new git worktree from a GitHub issue or a descriptive name. Pass a GitHub issue URL/number or a plain string as argument.
---

# Create Worktree

Create a new git worktree in `.claude/worktrees/`.

## Arguments

The user provides one of:
- A GitHub issue URL or number (e.g., `#193`, `193`, or full URL)
- A plain descriptive string (e.g., `"Refactor billing service (wt-billing-refactor)"`)

## Instructions

### 1. Determine the input type

- If the argument looks like a GitHub issue (number, `#number`, or URL containing `/issues/`), follow the **Issue flow**.
- Otherwise, follow the **Name flow**.

---

### Issue flow

1. **Normalize the input to a bare issue number.** The argument may be `193`, `#193`, or a full URL like `https://github.com/{owner}/{repo}/issues/193`. Strip the `#` prefix and extract the number from URLs before calling `gh`.

2. **Fetch issue details**:
   ```bash
   gh issue view <number> --json number,title,state
   ```

3. **Derive the branch name** from the issue title (see naming rules below).

4. Continue to **Common steps**.

---

### Name flow

1. **Derive the branch name** from the provided string (see naming rules below).

2. Continue to **Common steps**.

---

### Naming rules

- Lowercase the input
- Replace spaces and special characters with hyphens
- Strip leading/trailing hyphens
- Collapse consecutive hyphens
- Truncate to a reasonable length (~50 chars)
- Examples:
  - `"BILLING-003: Subscription table + model"` → `billing-003-subscription-table-model`
  - `"Refactor billing service (wt-billing-refactor)"` → `wt-billing-refactor`
  - `"my feature branch"` → `my-feature-branch`
- If the string contains a parenthesized short name like `(wt-billing-refactor)`, prefer the parenthesized value as the branch name.

---

### Common steps

1. **Fetch latest main**:
   ```bash
   git fetch origin main
   ```

2. **Create the worktree**:
   ```bash
   git worktree add .claude/worktrees/<branch-name> -b <branch-name> origin/main
   ```

3. **Bootstrap the worktree with required local files** (if your project has any gitignored files the app needs, e.g. `.env`, encryption keys, IDE configs):
   - If your repo provides a setup script (commonly `bin/setup-worktree` or similar), run it:
     ```bash
     bin/setup-worktree .claude/worktrees/<branch-name>
     ```
   - Otherwise, manually copy any required gitignored files from the main checkout to the new worktree (your project's README typically lists which files are needed).
   - If the project has no such files, skip this step.

4. **Report the result** to the user:
   - Worktree path
   - Branch name
   - The issue title and number (if from an issue), or the original string (if from a name)

## Notes

- Always base on `origin/main`, never local `main`
- The worktree directory is `.claude/worktrees/` (already gitignored)
- If the branch already exists, inform the user and ask how to proceed
- If the worktree path already exists, inform the user and ask how to proceed
