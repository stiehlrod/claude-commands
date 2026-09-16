---
name: collab-review GitHub post length
description: What to post to GitHub for collab-review comments — minimal, no full review content
type: feedback
originSessionId: e69ca51c-97a3-472c-a87c-edc248404f37
---
Only post actionable items to the GitHub ticket. Do not post the full review.

**Why:** The full review (BLUF, verification tables, positive observations, discussion notes) is for internal use. GitHub comments should be short and scannable for the team.

**How to apply:**
- If there are findings: post heading + actionable items only + brief closing note
- If there are NO findings (no-concerns review): post just the heading + one-liner summary. Nothing else. No tables, no positive observations, no closing note.

Example of a correct no-concerns post:
```
## Backend Engineering Feedback for Staging Review

No backend engineering concerns — this is a static content/CMS-only initiative with no vets-api impact.
```
