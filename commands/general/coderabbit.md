---
name: coderabbit
description: Pull down all CodeRabbit PR review comments, address valid ones with atomic commits, then post a summary report to the PR.
argument-hint: "<PR number (optional — auto-detects from current branch)>"
user-invocable: true
---

# CodeRabbit Review

Fetch all CodeRabbit review comments from the current PR, triage them, fix valid issues with atomic commits, and post a summary report.

## Instructions

### Step 1: Detect PR

If an argument is provided, use it as the PR number. Otherwise:

```bash
gh pr view --json number --jq '.number'
```

### Step 2: Fetch CodeRabbit Comments

Fetch all review comments on the PR and filter to CodeRabbit's:

```bash
# Get all review comments (inline code comments)
gh api repos/{owner}/{repo}/pulls/{pr}/comments \
  --jq '.[] | select(.user.login == "coderabbitai[bot]") | {id, path, line, body, diff_hunk}'

# Get all issue-level comments (top-level PR comments)
gh api repos/{owner}/{repo}/issues/{pr}/comments \
  --jq '.[] | select(.user.login == "coderabbitai[bot]") | {id, body}'
```

Parse all comments. CodeRabbit review comments may be inline (on specific lines) or top-level (summary comments). Focus on **actionable review comments** — skip the summary/walkthrough comments.

### Step 3: Triage Each Comment

For each actionable CodeRabbit comment, classify it:

- **WILL_FIX**: Valid issue — implement the fix
- **WONT_FIX**: Not applicable, incorrect, or conflicts with project conventions — document why
- **ALREADY_ADDRESSED**: The code already handles this — document why

Use your judgment. Consider:
- Does the suggestion align with project patterns (CLAUDE.md, existing code)?
- Is it a real bug/risk, or a style preference?
- Does it conflict with an intentional design decision?
- Is the suggestion actually correct for this codebase?

### Step 4: Fix Valid Issues

For each WILL_FIX comment:

1. Read the relevant file(s)
2. Implement the fix
3. Run linters on changed files (`bundle exec rubocop`, `npx eslint`)
4. Create an atomic commit:

```
fix: {short description of fix}

Addresses CodeRabbit review comment on {file}:{line}.
{Brief explanation of the change.}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

### Step 5: Push Changes

After all fixes are committed:

```bash
git push
```

### Step 6: Post Summary Report

Post a single comment to the PR summarizing all CodeRabbit comments and their disposition:

```markdown
## CodeRabbit Review — Triage Report

### Addressed

| # | File | Comment | Fix | Commit |
|---|------|---------|-----|--------|
| 1 | `path/to/file.rb:45` | Summary of comment | What was done | `abc1234` |

### Not Addressed

| # | File | Comment | Reason |
|---|------|---------|--------|
| 1 | `path/to/file.rb:12` | Summary of comment | Why it was skipped |

### Statistics

- Total comments: N
- Addressed: N
- Not addressed: N
```

Use `gh pr comment {pr} --body-file /tmp/coderabbit_report.md` to post.

### Step 7: Reply to and Resolve CodeRabbit Comments

For each **inline** CodeRabbit comment (ones with a `path` and `line`), reply and resolve:

1. **Reply** with the disposition using the REST API:

```bash
# For WILL_FIX comments:
gh api repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies \
  -f body="Fixed in \`{commit_sha}\`. {brief description of fix}"

# For WONT_FIX comments:
gh api repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies \
  -f body="Not applicable — {reason}"

# For ALREADY_ADDRESSED comments:
gh api repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies \
  -f body="Already handled — {reason}"
```

2. **Resolve the thread** via GraphQL. First get the thread node IDs, then resolve each:

```bash
# Get all review threads and their node IDs
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            comments(first: 1) {
              nodes { body, path, line: originalLine }
            }
          }
        }
      }
    }
  }
' -f owner="{owner}" -f repo="{repo}" -F pr={pr}

# Resolve each unresolved thread by matching path/line to our processed comments
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: { threadId: $threadId }) {
      thread { isResolved }
    }
  }
' -f threadId="{thread_node_id}"
```

Match threads to processed comments by `path` and `line`. Only resolve threads that belong to CodeRabbit comments we triaged.

**Skip** top-level summary/walkthrough comments — don't reply to or resolve those.

### Step 8: Report to User

Print a summary:
```
Done. CodeRabbit review processed.

- Total comments: N
- Fixed: N
- Skipped: N (with reasons)
- Commits: N
- Report posted: <comment URL>
```
