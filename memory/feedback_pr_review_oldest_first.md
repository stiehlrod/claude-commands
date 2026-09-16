---
name: PR review - oldest PRs first
description: Sort PR review queue oldest-first (lowest PR number) to respect 24-hour SLA, not newest-first
type: feedback
---

Sort PR review queue by **oldest first** (lowest PR number = longest waiting). The 24-hour SLA starts when a PR has team approval and passing CI, so the oldest unreviewed PRs are most at risk of breaching SLA.

**Why:** PRs were being sorted newest-first, which meant older PRs could sit unreviewed while newer ones got attention. The SLA requires reviews within 24 hours of being ready.

**How to apply:** When presenting "next batch", sort results by PR number ascending (oldest first). Priority team members still float to the top within each batch, but among non-priority PRs, always review the oldest ones first.
