---
name: PR review: always verify GitHub approval state before listing pending PRs
description: Always query GitHub for actual approval state instead of tracking from session memory
type: feedback
originSessionId: 61d2142a-573d-49bc-b3f2-767267021d21
---
Always check GitHub for actual approval state before listing PRs as "pending your approval." Query `gh pr view --json reviews` filtered by `Jennica-Stiehl` + `APPROVED` state. Do not rely on session memory to track what has/hasn't been approved — it gets stale and wastes the user's time.

**Why:** User pointed out that most "pending" PRs had already been approved on GitHub, making the list useless and wasteful.

**How to apply:** At the end of each batch, run `gh pr view --json reviews` for each reviewed PR and only list ones where Jennica-Stiehl has 0 APPROVED reviews.
