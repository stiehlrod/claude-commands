---
name: PR review - only flag things in the diff
description: Only raise findings on code that is actually changed in the PR diff — never flag existing code that wasn't touched
type: feedback
originSessionId: 1ac14946-0c1e-4207-82c5-107d729b091f
---
Only flag issues that appear in the PR diff itself. If a problem exists in existing code that the PR did not change, do not include it in the review — the author can't post a GitHub comment on it and it's not their responsibility to fix in this PR.

**Why:** Findings outside the diff can't be commented on in GitHub and create wasted effort for both reviewer and author.

**How to apply:**
- Before including any finding, verify the relevant line is a `+` line (added) or clearly modified in the diff
- Do not flag: missing specs for code that predates the PR, N+1s or caching issues in unchanged methods, CODEOWNERS gaps for files the PR didn't touch, existing architectural patterns the PR didn't introduce
- Exception: if the PR *calls into* or *extends* existing code in a way that introduces a new problem, that's fair game — but reference the new diff line, not the old code
- If an existing problem is worth noting, frame it as a question or a heads-up, not a finding
