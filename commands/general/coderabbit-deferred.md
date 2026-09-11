---
name: coderabbit-deferred
description: Scan PR review comments (CodeRabbit + others) for deferred work, dismissed suggestions, and follow-up items. Cross-references with existing GitHub issues to find untracked items. Run after /coderabbit to catch what was punted.
argument-hint: "<PR number or URL> (defaults to current branch's PR)"
---

# CodeRabbit Deferred Items

Find everything that was punted, dismissed, or marked for follow-up in a PR's review comments. Cross-reference with GitHub issues to surface untracked items.

## Why This Exists

PR reviews (especially from CodeRabbit) surface valid improvements that get deferred with "not addressing in this PR" or "follow-up". These items are easy to forget. This skill catches them.

## Usage

```
/coderabbit-deferred              # scan current branch's PR
/coderabbit-deferred 388          # scan PR #388
/coderabbit-deferred https://github.com/{owner}/{repo}/pull/388
```

## Instructions

### Step 1: Resolve the PR

```bash
# If argument provided, use it. Otherwise detect from current branch:
gh pr view --json number,title,url 2>/dev/null
```

If no PR is found and no argument was given, ask the user.

### Step 2: Fetch All Review Comments

Fetch both PR review comments (inline on code) and issue-level comments:

```bash
# Inline review comments (on specific lines of code)
gh api repos/{owner}/{repo}/pulls/{pr}/comments --paginate

# Issue-level comments (general discussion)
gh api repos/{owner}/{repo}/issues/{pr}/comments --paginate
```

### Step 3: Identify Deferred Items

Scan ALL comments (from all authors — CodeRabbit, humans, bots) for signals that work was deferred. Look for these patterns:

**Deferral signals** (comment suggests deferring):
- "defer", "deferred", "deferring"
- "follow-up", "followup", "follow up"
- "future PR", "separate PR", "next PR", "dedicated PR"
- "not addressing", "not in this PR", "out of scope"
- "TODO", "FIXME" (in review comments, not code)
- "track this", "open an issue", "create a ticket"
- "known issue", "known limitation"
- "intentionally deferred", "punted", "parking"
- "later", "eventually", "down the road"
- "optimization for later", "future optimization"
- "v2", "phase 2"

**Dismissal signals** (reviewer suggestion was declined):
- "not applicable", "N/A for this PR"
- "agreed but", "valid but", "fair point but"
- "should be a separate", "should change both"
- "cross-cutting concern"
- "would break", "would require"

**Resolution signals** (item was addressed — skip these):
- "Addressed in commit", "Fixed in", "Resolved in"
- "✅ Addressed", "✅ Confirmed"
- Comment is marked as resolved/outdated in the PR

For each deferred item, extract:
1. **What**: The suggested improvement or concern (1-2 sentence summary)
2. **Why deferred**: The reason given for not addressing it now
3. **Who raised it**: CodeRabbit, human reviewer, author
4. **File**: The file path and line number (if inline comment)
5. **Author reply**: The author's response (if any)

### Step 4: Cross-Reference with GitHub Issues

For each deferred item, search for an existing tracking issue:

```bash
# Search for issues that might track this item
gh issue list --repo {owner}/{repo} --state open --search "{keywords}" --json number,title,url
```

Use keywords extracted from the deferred item (file name, concept, specific terms).

Classify each item:
- **Tracked**: An open issue exists that covers this item
- **Untracked**: No issue found — this item could slip through the cracks

### Step 5: Output Report

Print the report in this format:

```markdown
## Deferred Items — PR #{number}

**PR:** {title} ({url})
**Comments scanned:** {count}
**Deferred items found:** {count}
**Untracked (need tickets):** {count}

---

### Untracked Items (Action Required)

These were deferred but have no GitHub issue. Create tickets or address them.

| # | Item | File | Raised By | Why Deferred |
|---|------|------|-----------|--------------|
| 1 | {description} | `{file}:{line}` | {author} | {reason} |
| 2 | ... | | | |

### Tracked Items

These are deferred AND have a corresponding GitHub issue.

| # | Item | File | Issue | Status |
|---|------|------|-------|--------|
| 1 | {description} | `{file}:{line}` | #{issue_number} | Open |
| 2 | ... | | | |

### Resolved Items (Already Fixed)

These were flagged in review but addressed in later commits on this branch.

| # | Item | File | Resolved In |
|---|------|------|-------------|
| 1 | {description} | `{file}:{line}` | {commit_sha} |
```

### Step 6: Offer to Create Tickets

If there are untracked items, ask:

> **{N} untracked deferred items found.** Want me to create GitHub issues for them?

If the user says yes, use `gh issue create` for each untracked item with:
- Title: concise description of the deferred work
- Body: context from the review comment, link to the PR comment, file/line reference
- Label: (none unless user specifies)

## Notes

- **Be conservative**: Only flag items that are clearly deferred work. Don't flag style disagreements, informational comments, or resolved discussions.
- **Group related items**: If multiple comments discuss the same deferred concern, consolidate them into one item.
- **Include context**: The "Why Deferred" column should capture the actual reason, not just "deferred". E.g., "Cross-cutting concern — should apply to all 3 providers uniformly" is useful. "Not in this PR" alone is not.
- **Check CodeRabbit learnings**: CodeRabbit's "Learnings added" blocks often contain the clearest summary of what was deferred and why. Use these as the primary source when present.
