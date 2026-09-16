---
name: GHEC-US is the source of truth for ticket state, not legacy github.com
description: Query software/va.gov-team on va.ghe.com for current ticket state; the legacy department-of-veterans-affairs/va.gov-team repo is locked for migration and its data is stale
type: feedback
originSessionId: 301166d0-bad9-42c7-aab4-5a1e95222330
---
For any ticket query during/after the GHEC-US migration, always check `software/va.gov-team` on `va.ghe.com` first.

**Why:** The legacy `department-of-veterans-affairs/va.gov-team` repo on github.com is **locked for migration** — `gh issue comment` returns `GraphQL: Repository has been locked for migration (addComment)`. Its issue state (open/closed, checkbox state, comments) is **frozen as of the lock date** and may differ from the migrated copy on GHEC-US. On 2026-05-01 I audited Sprint 26 tickets via `gh issue list --repo department-of-veterans-affairs/va.gov-team` and built plans for tickets that were already CLOSED on GHEC-US, wasting effort and producing misleading framing in a downstream PR.

**How to apply:**
- For ticket reads (state, body, A/C boxes, comments): use `GH_HOST=va.ghe.com gh issue view <N> --repo software/va.gov-team` first; fall back to legacy only if the ticket isn't on GHEC-US yet.
- For ticket writes (comments, edits, closing): only the GHEC-US copy accepts writes.
- For sprint board / project boards: project #1335 still lives on github.com, so use github.com for *board* queries, but cross-reference each item's state against GHEC-US before acting.
- If a tool/bot defaults to github.com (e.g., `gh issue list --repo department-of-veterans-affairs/...`), explicitly add a GHEC-US re-check step before recommending action on any ticket.
