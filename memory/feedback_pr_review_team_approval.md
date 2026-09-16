---
name: PR review - only team-approved PRs
description: When fetching next batch of PRs, only review PRs that already have team approval — skip PRs with no teammate approvals
type: feedback
---

Only review PRs that already have at least one team approval when doing "next batch" PR reviews. Skip PRs that have no teammate approvals yet.

**Why:** User preference — PRs without team approval aren't ready for backend support review yet.

**How to apply:** When filtering the next batch, add a filter requiring `len(approvers) > 0` (excluding bot approvals like copilot). Present only those PRs and proceed to review them.
