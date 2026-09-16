---
name: PR review - COMMENTED ≠ done
description: A prior COMMENTED review on a PR does not mean it's been reviewed for the current session — it still needs a full review if not formally APPROVED
type: feedback
originSessionId: 1ac14946-0c1e-4207-82c5-107d729b091f
---
A PR where Jennica-Stiehl has a COMMENTED review state is NOT done. Only a formal APPROVED (or CHANGES_REQUESTED) review counts as "reviewed." Do not skip PRs just because there are prior COMMENTED reviews.

**Why:** PRs like #29618 were incorrectly skipped because they had COMMENTED state from a previous session, even though they still needed a full review and GitHub approval.

**How to apply:**
- When checking `myReview` state, only skip a PR if the state is `APPROVED` or `CHANGES_REQUESTED`
- `COMMENTED` state means comments were left but no formal review decision was made — treat as unreviewed
- Always check the actual review state before excluding a PR from the batch
