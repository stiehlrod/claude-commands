---
name: PR review: use three-bucket tracking, not flat "pending approval" list
description: Distinguish between needs-re-review, needs-GitHub-review-posted, and done — don't lump them together
type: feedback
originSessionId: 61d2142a-573d-49bc-b3f2-767267021d21
---
After each PR review batch, show three buckets instead of a flat "pending approval" list:

1. **🔄 Needs re-review** — PRs where Jennica-Stiehl has a COMMENTED or CHANGES_REQUESTED review on GitHub AND the PR `updatedAt` is newer than her review `submittedAt`. These need a second look to see if the author addressed her feedback.

2. **⏳ Needs GitHub review posted** — PRs reviewed in this Claude Code session but where Jennica-Stiehl has no review on GitHub yet (reviews[] for her login is empty). Conditional approvals go here until she posts them.

3. **✅ Done** — PRs where she has APPROVED on GitHub. Don't track these at all.

**Why:** User pointed out that listing all reviewed PRs as "pending your approval" conflates waiting-on-author with not-yet-reviewed, and is not actionable. Also wastes time reminding her about PRs where she's already waiting for the author to respond.

**How to apply:** After presenting reviews, run `gh pr view --json reviews,updatedAt` for each tracked PR, check Jennica-Stiehl's review state and submittedAt vs PR updatedAt, then sort into the three buckets above. Only show buckets that have content.
